# Macropad Tool Development Container

This repository includes a complete development container setup that allows you to develop and test the macropad tool in a consistent Linux environment, even on Windows. The setup includes USB device passthrough capabilities for flashing and communicating with macropad devices.

## Prerequisites

### Windows Requirements
- **Docker Desktop for Windows** - Install from [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
- **WSL2** - Ensure WSL2 is installed and enabled
- **Visual Studio Code** - Install from [https://code.visualstudio.com/](https://code.visualstudio.com/)
- **Dev Containers Extension** - Install the "Dev Containers" extension in VS Code

### Linux Requirements
TBD

## Quick Start

### 1. Clone and Open Repository
```bash
git clone <your-repo-url>
cd macropad_tool
code .
```

### 2. USB Device Setup (Windows - Required for flashing)

**Option A: Automated Setup Script**

Run the setup script as Administrator to configure USB passthrough:

```powershell
# Open PowerShell as Administrator
cd .devcontainer
.\setup-usb-windows.ps1
```

This script will:
- Install USBIPD-WIN for USB device sharing
- Detect connected macropad devices
- Attach the macropad to WSL for container access
- Verify Docker Desktop is running

**Option B: Manual USBIPD Setup**

If the automated setup doesn't work:

```powershell
# Install USBIPD-WIN
winget install --interactive --exact dorssel.usbipd-win

# List devices and find your macropad (vendor ID 0x1189)
usbipd list

# Bind device for sharing (replace 1-1 with your device's bus ID)
usbipd bind --busid 1-1

# Attach macropad device to WSL
usbipd attach --wsl --busid 1-1
```

### 3. Open in Development Container

1. VS Code should detect the devcontainer configuration
2. Click "Reopen in Container" when prompted, or:
3. Press `F1` → "Dev Containers: Reopen in Container"
4. Wait for container setup (first time takes 5-10 minutes)

### 4. Verify Setup

Once the container is running:

```bash
# Check if macropad is detected (look for vendor ID 1189)
lsusb | grep 1189

# Build the project
cargo build

# Test device communication
cargo run -- validate -d
```

## Development Environment

### What's Included

The development container includes:

- **Rust toolchain** (1.75+) with clippy, rustfmt, and rust-analyzer
- **USB libraries** (libusb-1.0, libudev) for device communication
- **Debugging tools** including LLDB debugger support
- **USB utilities** (lsusb, usbutils) for device debugging
- **Privileged access** for direct USB device communication

### VS Code Extensions

Pre-installed extensions for optimal development experience:

- Rust Analyzer (rust-lang.rust-analyzer)
- LLDB Debugger (vadimcn.vscode-lldb)
- Crates helper (serayuzgur.crates)
- TOML support (tamasfe.even-better-toml)
- Hex Editor (ms-vscode.hexeditor)

## Development Workflow

### Building and Running

```bash
# Build in debug mode
cargo build

# Build in release mode
cargo build --release

# Run with cargo
cargo run -- --help

# Format code
cargo fmt

# Run linter
cargo clippy

# Run tests
cargo test
```

### Device Configuration

Create or modify `mapping.ron` for your macropad configuration:

```bash
# Copy example configuration
cp mapping.ron my-config.ron

# Edit configuration
nano my-config.ron

# Validate configuration
cargo run -- validate -c my-config.ron

# Program with custom configuration
cargo run -- program -c my-config.ron
```

### USB Device Testing

```bash
# Validate configuration with connected device
cargo run -- validate -d

# Show supported keys
cargo run -- show-keys

# Program the device (requires privileged access)
cargo run -- program

# Shows the current stored configuration on the macropad
cargo run -- read

# Enable verbose logging for debugging
export RUST_LOG=trace
cargo run -- validate -d
```

## Troubleshooting

### USB Device Not Detected

1. **Verify USB passthrough**:
   ```bash
   # Inside container - should show vendor ID 1189
   lsusb
   lsusb | grep 1189
   
   # Check USB device permissions
   ls -la /dev/bus/usb/
   ```

2. **Check WSL2 USB binding** (if using USBIPD):
   ```powershell
   # On Windows host
   usbipd list
   usbipd bind --busid <your-device-busid>
   usbipd attach --wsl --busid <your-device-busid>
   ```

3. **Verify device detection**:
   ```bash
   # Check kernel messages for USB events
   dmesg | grep usb
   ```

### Container Issues

- **Rebuild container**: Press `F1` → "Dev Containers: Rebuild Container"
- **Clear Docker cache**: `docker system prune -a`
- **Check container logs**: View logs in VS Code terminal

### Permission Issues

The container runs as root by default for USB access. If needed:

```bash
# Switch to developer user
su developer

# Or run specific commands with sudo
sudo cargo run -- program
```

### Build Issues

```bash
# Clean build artifacts
cargo clean

# Update dependencies
cargo update

# Check for compilation issues
cargo check
```

## Advanced Configuration

### Custom USB Devices

For different macropad models or vendor IDs:

```bash
# Use custom vendor/product ID
cargo run -- validate -p 0x8890

# Use custom USB address
cargo run -- program --address 1:5

# List all connected devices
cargo run -- validate -d
```

### Environment Variables

The container sets these by default:

- `RUST_LOG=debug` - Enable debug logging
- `USBDK_ENABLED=1` - Enable USB development kit support

Override in `.devcontainer/devcontainer.json` if needed.

### Container Customization

Edit `.devcontainer/docker-compose.yml` to:
- Add additional USB devices
- Mount additional directories
- Configure different environment variables
- Add custom build arguments

## Container Architecture

### File Structure
```
.devcontainer/
├── devcontainer.json           # VS Code devcontainer configuration
├── Dockerfile                  # Container image definition
├── docker-compose.yml          # Service orchestration with USB access
├── setup.sh                   # Container setup script
├── setup-usb-windows.ps1      # Windows USB setup automation
└── README.md                  # This documentation
```

### Security Considerations

The container runs with elevated privileges for USB device access:

- `privileged: true` - Required for USB device access
- `device_cgroup_rules` - USB device permissions
- `/dev/bus/usb` mounting - Direct USB device access
- Root user access - For device permissions

**Important**: Only run trusted code in this environment and be cautious with USB device operations.

## Support and Resources

### Common Issues
- **Macropad Tool**: Check the main project documentation and GitHub issues
- **Dev Container**: Review VS Code dev containers documentation
- **USB Access**: Verify Docker/WSL2 USB passthrough configuration
- **Windows Docker**: Ensure Docker Desktop is running with WSL2 backend

### Useful Commands

```bash
# Check USB device details
lsusb -v -d 1189:

# Monitor USB events
dmesg -w | grep -i usb

# Test USB permissions
ls -la /dev/bus/usb/*/

# View container resource usage
docker stats
```

### Getting Help

1. Check the main project README for macropad tool usage
2. Review VS Code dev containers documentation for container issues
3. Consult Docker Desktop documentation for USB passthrough problems
4. Check project GitHub issues for known problems and solutions