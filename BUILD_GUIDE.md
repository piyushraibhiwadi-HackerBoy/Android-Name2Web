# APK Build Guide - Company Email Scraper

## Current Status
- ✅ Flutter 3.44.0 installed and configured
- ✅ Project dependencies resolved
- ❌ Android SDK missing (blocking local builds)
- ✅ Build automation scripts created
- ✅ Android configuration optimized

## Primary Method: Cloud Build via GitHub Actions (RECOMMENDED)

### Why Cloud Build?
- No Android SDK installation required
- Free and fast (~5-10 minutes)
- Automatic artifact downloads
- Works with any computer

### Step-by-Step Instructions:

#### 1. Fix GitHub Repository Access
The current GitHub repository is not accessible. You have two options:

**Option A: Create New GitHub Repository**
```powershell
# Go to https://github.com/new
# Create a new repository (can be private)
# Then run these commands:
cd d:\AI\company_email_scraper
git remote set-url origin https://github.com/YOUR_USERNAME/YOUR_NEW_REPO.git
git push -u origin main
```

**Option B: Fix Existing Repository**
- Go to https://github.com/piyushraibhiwadi-HackerBoy/company_email_scraper
- Check if you have access
- If not, create a new repository as shown in Option A

#### 2. Trigger Cloud Build
Once code is pushed to GitHub:
1. Go to your repository on GitHub
2. Click "Actions" tab
3. Click "Build Android APK" workflow
4. Click "Run workflow" → "Run workflow" button
5. Wait 5-10 minutes for build to complete

#### 3. Download APK
1. Go to Actions tab
2. Click on the completed workflow run
3. Scroll to "Artifacts" section
4. Download "release-apk"
5. Extract the ZIP file
6. Install `app-release.apk` on your Android device

## Secondary Method: Local Build with Android SDK

### Prerequisites
- Windows 10 or 11
- Administrator access
- Internet connection

### Step 1: Install Android SDK Automatically

**Run the PowerShell script (as Administrator):**
```powershell
# Right-click PowerShell → "Run as Administrator"
cd d:\AI\company_email_scraper
.\setup_android.ps1
```

**What this script does:**
- Downloads Android Command Line Tools (~100MB)
- Installs to %LOCALAPPDATA%\Android\Sdk
- Configures environment variables
- Accepts SDK licenses
- Installs required SDK components (platform-tools, Android 34, build-tools)

**After script completes:**
1. Close PowerShell window
2. Open new PowerShell window
3. Run: `flutter doctor`
4. Verify Android toolchain shows green checkmark

### Step 2: Build APK Locally

**Option A: Use One-Click BAT File (EASIEST)**
```powershell
cd d:\AI\company_email_scraper
.\build_apk.bat
```

**Option B: Manual Commands**
```powershell
cd d:\AI\company_email_scraper
flutter clean
flutter pub get
flutter build apk --release
```

**APK Location:**
`build\app\outputs\flutter-apk\app-release.apk`

### Step 3: Install on Android Device

**Method A: Direct USB Installation**
```powershell
# Enable USB debugging on your Android device
# Connect device via USB
flutter install
```

**Method B: Manual Transfer**
1. Copy `app-release.apk` to your Android device
2. Open file manager on Android device
3. Tap the APK file
4. Allow installation from unknown sources
5. Install the app

## Tertiary Method: Alternative Cloud Builders

If GitHub Actions doesn't work, try these free alternatives:

### Codemagic (Free Tier)
1. Go to https://codemagic.io
2. Sign up with GitHub
3. Connect your repository
4. Configure:
   - Flutter version: 3.44.0
   - Build type: APK
5. Start build
6. Download APK when complete

### GitLab CI (Free)
1. Go to https://gitlab.com
2. Create new project
3. Push code to GitLab
4. Create `.gitlab-ci.yml`:
```yaml
image: cirrusci/flutter:3.44.0

build_apk:
  script:
    - flutter pub get
    - flutter build apk --release
  artifacts:
    paths:
      - build/app/outputs/flutter-apk/app-release.apk
```
5. Push to trigger build
6. Download from pipeline artifacts

## Troubleshooting

### Issue: "No Android SDK found"
**Solution:** Run `setup_android.ps1` as Administrator

### Issue: "flutter command not found"
**Solution:** Flutter is installed but PATH needs refresh. Close and reopen PowerShell.

### Issue: "Repository not found" when pushing to GitHub
**Solution:** Create a new GitHub repository and update remote URL:
```powershell
git remote set-url origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

### Issue: Build fails in GitHub Actions
**Solution:** 
- Check Actions tab for error logs
- Ensure all files are committed
- Verify workflow file exists in `.github/workflows/`

### Issue: PowerShell script execution blocked
**Solution:** Run this command first:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue: APK won't install on Android device
**Solution:**
- Enable "Install unknown apps" in Android settings
- Allow installation from your file manager
- Try installing the debug APK instead: `.\build_debug_apk.bat`

## Quick Reference Commands

```powershell
# Check Flutter status
flutter doctor

# Clean build artifacts
flutter clean

# Get dependencies
flutter pub get

# Build debug APK (faster)
flutter build apk --debug

# Build release APK (optimized)
flutter build apk --release

# Install on connected device
flutter install

# Check connected devices
flutter devices
```

## File Locations

- **Project:** `d:\AI\company_email_scraper`
- **Flutter SDK:** `C:\Users\Lenovo\Documents\flutter`
- **Android SDK:** `%LOCALAPPDATA%\Android\Sdk` (after installation)
- **APK Output:** `build\app\outputs\flutter-apk\`
- **Setup Script:** `setup_android.ps1`
- **Build Scripts:** `build_apk.bat`, `build_debug_apk.bat`

## Recommended Workflow

**For fastest results (no local setup):**
1. Create/fix GitHub repository
2. Push code
3. Trigger GitHub Actions build
4. Download APK (~15 minutes total)

**For repeated local builds:**
1. Run `setup_android.ps1` once (as Administrator)
2. Use `build_apk.bat` for future builds (~5 minutes each)

## Support

If you encounter issues not covered here:
1. Check the error message carefully
2. Run `flutter doctor -v` for detailed diagnostics
3. Review GitHub Actions logs (if using cloud build)
4. Ensure all scripts are run from the project directory

## Success Indicators

✅ Flutter doctor shows green checkmarks for Flutter and Android
✅ `flutter build apk --release` completes without errors
✅ `app-release.apk` file exists in `build\app\outputs\flutter-apk\`
✅ APK installs successfully on Android device
✅ App launches and runs on device
