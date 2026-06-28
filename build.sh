#!/bin/bash
set -euo pipefail

IMAGE_NAME="komorebi-builder"
OUTPUT_DIR="$(cd "$(dirname "$0")" && pwd)/output"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="/tmp/komorebi-build-$$"

cleanup() {
    rm -rf "$BUILD_DIR" 2>/dev/null || true
}
trap cleanup EXIT

echo "=== Komorebi Builder ==="
echo ""

# Step 1: Build (or rebuild) the Docker image
echo "[1/4] Building Docker image..."
docker build -t "$IMAGE_NAME" "$PROJECT_DIR"

# Step 2: Set up build directory
echo "[2/4] Preparing build directory..."
mkdir -p "$BUILD_DIR" "$OUTPUT_DIR"

# Step 3: Run build inside container
echo "[3/4] Compiling and generating .deb package..."
docker run --rm \
    -v "$PROJECT_DIR:/build/src:ro" \
    -v "$BUILD_DIR:/build/build:rw" \
    -v "$OUTPUT_DIR:/build/output:rw" \
    "$IMAGE_NAME" \
    bash -c '
        set -euo pipefail
        cd /build/build
        cmake -DCMAKE_INSTALL_PREFIX=/usr /build/src
        make -j"$(nproc)"
        cpack -G DEB
        cp -v ./*.deb /build/output/
        echo "BUILD_COMPLETE"
    '

# Step 4: Verify output
echo "[4/4] Verifying package..."
DEB_FILE=$(ls "$OUTPUT_DIR"/*.deb 2>/dev/null | head -1)

if [ -n "$DEB_FILE" ]; then
    echo ""
    echo "=== Build successful ==="
    echo "Package: $(basename "$DEB_FILE")"
    ls -lh "$DEB_FILE"
    echo ""
    echo "Install with: sudo apt install $DEB_FILE"
else
    echo ""
    echo "ERROR: No .deb package was generated."
    exit 1
fi
