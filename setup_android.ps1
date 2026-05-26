# Android SDK Automatic Installation Script for Flutter
# This script downloads and configures Android SDK for Flutter builds
# Run as Administrator

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Android SDK Automatic Setup for Flutter" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

# Set paths
$androidSdkPath = "$env:LOCALAPPDATA\Android\Sdk"
$flutterPath = "C:\Users\Lenovo\Documents\flutter"
$tempPath = "$env:TEMP\android_sdk_setup"

Write-Host "Android SDK will be installed to: $androidSdkPath" -ForegroundColor Green
Write-Host "Flutter path: $flutterPath" -ForegroundColor Green
Write-Host ""

# Create directories
Write-Host "Creating directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$androidSdkPath" | Out-Null
New-Item -ItemType Directory -Force -Path "$tempPath" | Out-Null

# Download Command Line Tools
Write-Host "Downloading Android Command Line Tools..." -ForegroundColor Yellow
$cmdlineUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$cmdlineZip = "$tempPath\commandlinetools-win.zip"

try {
    Invoke-WebRequest -Uri $cmdlineUrl -OutFile $cmdlineZip -UseBasicParsing
    Write-Host "Download complete" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to download command line tools" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    pause
    exit 1
}

# Extract Command Line Tools
Write-Host "Extracting Command Line Tools..." -ForegroundColor Yellow
Expand-Archive -Path $cmdlineZip -DestinationPath "$tempPath\cmdline" -Force

# Move to correct location (commandlinetools -> cmdline-tools/latest)
Write-Host "Installing Command Line Tools..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$androidSdkPath\cmdline-tools\latest" | Out-Null
Get-ChildItem -Path "$tempPath\cmdline\cmdline-tools" -Recurse | Move-Item -Destination "$androidSdkPath\cmdline-tools\latest" -Force

# Set environment variables
Write-Host "Setting environment variables..." -ForegroundColor Yellow
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $androidSdkPath, "User")
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $androidSdkPath, "User")

# Add to PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$androidPaths = @(
    "$androidSdkPath\cmdline-tools\latest\bin",
    "$androidSdkPath\platform-tools",
    "$androidSdkPath\emulator"
)

foreach ($path in $androidPaths) {
    if ($currentPath -notlike "*$path*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$path", "User")
        $currentPath = "$currentPath;$path"
    }
}

# Refresh environment variables for current session
$env:ANDROID_SDK_ROOT = $androidSdkPath
$env:ANDROID_HOME = $androidSdkPath
$env:PATH = "$env:PATH;$androidSdkPath\cmdline-tools\latest\bin;$androidSdkPath\platform-tools;$androidSdkPath\emulator"

# Accept licenses
Write-Host "Accepting Android SDK licenses..." -ForegroundColor Yellow
$env:JAVA_HOME = "$flutterPath\jdk"
& "$flutterPath\bin\flutter" doctor --android-licenses

# Install required SDK components
Write-Host "Installing Android SDK components..." -ForegroundColor Yellow
& "$androidSdkPath\cmdline-tools\latest\bin\sdkmanager.bat" "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# Update local.properties
Write-Host "Updating Flutter local.properties..." -ForegroundColor Yellow
$localPropertiesPath = "$PSScriptRoot\android\local.properties"
if (Test-Path $localPropertiesPath) {
    Remove-Item $localPropertiesPath -Force
}
Add-Content -Path $localPropertiesPath -Value "sdk.dir=$androidSdkPath"

# Cleanup
Write-Host "Cleaning up temporary files..." -ForegroundColor Yellow
Remove-Item -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Android SDK Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: Restart your terminal/IDE for PATH changes to take effect" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Green
Write-Host "1. Close this PowerShell window" -ForegroundColor White
Write-Host "2. Open a new PowerShell window" -ForegroundColor White
Write-Host "3. Run: flutter doctor" -ForegroundColor White
Write-Host "4. Run: build_apk.bat" -ForegroundColor White
Write-Host ""
pause
