FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    valac \
    dpkg-dev \
    file \
    fakeroot \
    libgtk-3-dev \
    libgee-0.8-dev \
    libclutter-1.0-dev \
    libclutter-gtk-1.0-dev \
    libclutter-gst-3.0-dev \
    libwebkit2gtk-4.1-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
