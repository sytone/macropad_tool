FROM rust:1.90.0

# Install system dependencies for USB development
RUN apt-get update && apt-get install -y \
    # USB development libraries
    libusb-1.0-0-dev \
    libudev-dev \
    pkg-config \
    # Development tools
    build-essential \
    cmake \
    git \
    curl \
    # USB utilities for debugging
    usbutils \
    # Additional utilities
    vim \
    nano \
    tree \
    htop \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Set up Rust environment
ENV RUST_LOG=debug
ENV CARGO_HOME=/usr/local/cargo
ENV RUSTUP_HOME=/usr/local/rustup

# Install Rust components
RUN rustup component add clippy rustfmt rust-src

# Install cargo tools useful for development
RUN cargo install cargo-edit cargo-audit cargo-outdated

# Pre-build dependencies to leverage Docker layer caching
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs && \
    cargo build --release && \
    rm -rf src target/release/deps/macropad*

# Set up udev rules directory (for potential USB device rules)
RUN mkdir -p /etc/udev/rules.d

# Create a non-root user but keep root as default for USB access
RUN groupadd -r developer && useradd -r -g developer -m developer
RUN usermod -a -G plugdev developer

# Copy the udev rules file
COPY 80-macropad.rules /etc/udev/rules.d/80-macropad.rules

# Set working directory permissions
RUN chown -R developer:developer /workspace
RUN chmod -R 755 /workspace

CMD ["bash"]