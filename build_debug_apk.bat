@echo off
REM One-Click Debug APK Build Script for Flutter
REM This script builds a debug APK for Android testing

echo ========================================
echo Flutter Debug APK Build Script
echo ========================================
echo.

REM Check if Flutter is in PATH
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found in PATH
    echo Please run: setup_android.ps1 first
    pause
    exit /b 1
)

REM Display Flutter version
echo Checking Flutter installation...
flutter --version
echo.

REM Navigate to project directory
cd /d "%~dp0"
echo Current directory: %CD%
echo.

REM Clean previous builds
echo Cleaning previous builds...
flutter clean
echo.

REM Get dependencies
echo Installing dependencies...
flutter pub get
echo.

REM Check Android environment
echo Checking Android setup...
flutter doctor --android
echo.

REM Build debug APK
echo Building debug APK...
echo This may take 3-5 minutes...
echo.
flutter build apk --debug

if %errorlevel% neq 0 (
    echo.
    echo ========================================
    echo BUILD FAILED
    echo ========================================
    echo.
    echo Troubleshooting:
    echo 1. Run: setup_android.ps1 (as Administrator)
    echo 2. Restart your terminal
    echo 3. Run: flutter doctor
    echo 4. Try this script again
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo BUILD SUCCESSFUL
echo ========================================
echo.
echo APK Location: build\app\outputs\flutter-apk\app-debug.apk
echo.

REM Check if APK exists
if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo Debug APK file created successfully!
    echo.
    echo To install on Android device:
    echo 1. Enable USB debugging on your Android device
    echo 2. Connect device via USB
    echo 3. Run: flutter install
    echo.
    echo Or transfer APK to device and install manually
    echo.
    
    REM Ask if user wants to open the folder
    set /p openfolder="Open APK folder in Explorer? (Y/N): "
    if /i "%openfolder%"=="Y" (
        explorer "build\app\outputs\flutter-apk"
    )
) else (
    echo WARNING: APK file not found at expected location
)

echo.
pause
