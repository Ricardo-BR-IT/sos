# Dockerfile for SOS V22 compilation environment
FROM ubuntu:22.04

# 1. Install Dependencies for OpenWrt ImageBuilder & Android SDK (Basic)
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential libncurses5-dev python3 python3-pip \
    unzip git wget curl file \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# 2. Setup Workdir
WORKDIR /workspace

# 3. Entrypoint
# Default command executes the build script if provided
CMD ["/bin/bash", "/workspace/installers/build_openwrt.sh"]
