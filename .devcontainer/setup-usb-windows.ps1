# PowerShell script for setting up USB device access on Windows
# Run as Administrator

Write-Host "🔌 Macropad USB Device Setup for Docker" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script requires Administrator privileges" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Running with Administrator privileges" -ForegroundColor Green

# Check if USBIPD is installed
Write-Host "`n📋 Checking for USBIPD-WIN..." -ForegroundColor Yellow

if (Get-Command usbipd -ErrorAction SilentlyContinue) {
    Write-Host "✅ USBIPD-WIN is installed" -ForegroundColor Green
} else {
    Write-Host "❌ USBIPD-WIN not found. Installing..." -ForegroundColor Red
    try {
        winget install --interactive --exact dorssel.usbipd-win
        Write-Host "✅ USBIPD-WIN installed successfully" -ForegroundColor Green
        Write-Host "⚠️  Please restart your computer and run this script again" -ForegroundColor Yellow
        exit 0
    } catch {
        Write-Host "❌ Failed to install USBIPD-WIN. Please install manually from:" -ForegroundColor Red
        Write-Host "   https://github.com/dorssel/usbipd-win/releases" -ForegroundColor Cyan
        exit 1
    }
}

# List USB devices
Write-Host "`n📱 Scanning for USB devices..." -ForegroundColor Yellow
$usbDevices = usbipd list

Write-Host "`n🔍 All USB devices:" -ForegroundColor Cyan
$usbDevices

# Look for macropad devices (vendor ID 1189)
Write-Host "`n🎹 Looking for macropad devices (Vendor ID 1189)..." -ForegroundColor Yellow
$macropadDevices = $usbDevices | Select-String "1189"

if ($macropadDevices) {
    Write-Host "✅ Found macropad device(s):" -ForegroundColor Green
    $macropadDevices | ForEach-Object { Write-Host "   $_" -ForegroundColor White }
    
    # Extract bus ID from the first macropad device
    $busId = ($macropadDevices[0] -split '\s+')[0]
    
    # First bind the device
    Write-Host "`n🔗 Binding device $busId..." -ForegroundColor Yellow
    try {
        usbipd bind --busid $busId
        Write-Host "✅ Successfully bound device $busId" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Failed to bind device automatically" -ForegroundColor Yellow
        Write-Host "   Please run manually: usbipd bind --busid $busId" -ForegroundColor Cyan
    }
    
    # Then attach to WSL
    Write-Host "`n🔗 Attaching device $busId to WSL..." -ForegroundColor Yellow
    try {
        usbipd attach --wsl --busid $busId
        Write-Host "✅ Successfully attached macropad device to WSL" -ForegroundColor Green
        Write-Host "   Device $busId is now available in WSL/Docker containers" -ForegroundColor White
    } catch {
        Write-Host "⚠️  Failed to attach device automatically" -ForegroundColor Yellow
        Write-Host "   Please run manually: usbipd attach --wsl --busid $busId" -ForegroundColor Cyan
    }
} else {
    Write-Host "❌ No macropad devices found (Vendor ID 1189)" -ForegroundColor Red
    Write-Host "   Please ensure your macropad is connected and try again" -ForegroundColor Yellow
}

# Check Docker Desktop status
Write-Host "`n🐳 Checking Docker Desktop..." -ForegroundColor Yellow
$dockerProcess = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
if ($dockerProcess) {
    Write-Host "✅ Docker Desktop is running" -ForegroundColor Green
} else {
    Write-Host "❌ Docker Desktop not running. Please start Docker Desktop" -ForegroundColor Red
}

Write-Host "`n📝 Setup Summary:" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan
Write-Host "1. ✅ USBIPD-WIN installed" -ForegroundColor Green
if ($macropadDevices) {
    Write-Host "2. ✅ Macropad device found and attached" -ForegroundColor Green
} else {
    Write-Host "2. ❌ No macropad device detected" -ForegroundColor Red
}
if ($dockerProcess) {
    Write-Host "3. ✅ Docker Desktop running" -ForegroundColor Green
} else {
    Write-Host "3. ❌ Docker Desktop not running" -ForegroundColor Red
}

Write-Host "`n🚀 Next steps:" -ForegroundColor Yellow
Write-Host "1. Open VS Code in the macropad_tool directory" -ForegroundColor White
Write-Host "2. Click 'Reopen in Container' when prompted" -ForegroundColor White
Write-Host "3. Wait for the development container to build" -ForegroundColor White
Write-Host "4. Run 'cargo run -- validate -d' to test device connection" -ForegroundColor White

Write-Host "`n💡 Useful commands:" -ForegroundColor Cyan
Write-Host "   usbipd list                        - List all USB devices" -ForegroundColor White
Write-Host "   usbipd bind --busid <id>           - Bind device for sharing" -ForegroundColor White
Write-Host "   usbipd attach --wsl --busid <id>   - Attach device to WSL" -ForegroundColor White
Write-Host "   usbipd detach --busid <id>         - Detach device from WSL" -ForegroundColor White