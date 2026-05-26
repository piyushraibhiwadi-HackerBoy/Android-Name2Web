# Manual Android SDK Setup (Non-Admin Method)

Since the automatic setup requires Administrator privileges, here's a manual method that works without admin access.

## Method 1: Android Studio (Recommended - No Admin Required)

### Step 1: Download Android Studio
1. Go to: https://developer.android.com/studio
2. Download "Command line tools only" (NOT the full Android Studio)
3. Or download full Android Studio if you prefer GUI

### Step 2: Extract to User Directory
1. Download the command line tools ZIP
2. Extract to: `C:\Users\Lenovo\Android\Sdk`
   - Create the folder if it doesn't exist
   - No admin rights needed for user directory

### Step 3: Set Environment Variables (User Level)
1. Press `Win + R`, type: `sysdm.cpl`
2. Click "Advanced" tab
3. Click "Environment Variables"
4. Under "User variables" (not System):
   - Add new variable:
     - Name: `ANDROID_HOME`
     - Value: `C:\Users\Lenovo\Android\Sdk`
   - Add new variable:
     - Name: `ANDROID_SDK_ROOT`
     - Value: `C:\Users\Lenovo\Android\Sdk`
5. Edit "Path" variable under User variables:
   - Add: `C:\Users\Lenovo\Android\Sdk\cmdline-tools\latest\bin`
   - Add: `C:\Users\Lenovo\Android\Sdk\platform-tools`
   - Add: `C:\Users\Lenovo\Android\Sdk\emulator`

### Step 4: Install SDK Components
Open PowerShell (normal user, no admin needed):
```powershell
cd d:\AI\company_email_scraper
$env:ANDROID_HOME = "C:\Users\Lenovo\Android\Sdk"
$env:ANDROID_SDK_ROOT = "C:\Users\Lenovo\Android\Sdk"
$env:PATH = "$env:PATH;C:\Users\Lenovo\Android\Sdk\cmdline-tools\latest\bin;C:\Users\Lenovo\Android\Sdk\platform-tools"

# Accept licenses
flutter doctor --android-licenses

# Install required components
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

### Step 5: Update Flutter Configuration
```powershell
# Update local.properties
echo "sdk.dir=C:\Users\Lenovo\Android\Sdk" > android\local.properties
echo "flutter.sdk=C:\Users\Lenovo\Documents\flutter" >> android\local.properties
```

### Step 6: Verify Setup
```powershell
flutter doctor
```

### Step 7: Build APK
```powershell
.\build_apk.bat
```

## Method 2: Use Flutter's Built-in Android SDK Download

Flutter can download Android SDK components automatically:

```powershell
cd d:\AI\company_email_scraper

# Set Android SDK location to user directory
$env:ANDROID_HOME = "C:\Users\Lenovo\Android\Sdk"
New-Item -ItemType Directory -Force -Path "C:\Users\Lenovo\Android\Sdk"

# Update local.properties
echo "sdk.dir=C:\Users\Lenovo\Android\Sdk" > android\local.properties

# Try building - Flutter may prompt to download components
flutter build apk --debug
```

If Flutter prompts to accept licenses, run:
```powershell
flutter doctor --android-licenses
```

## Method 3: Use Chocolatey (If Available)

If you have Chocolatey package manager:

```powershell
# Install Android SDK (no admin needed for user scope)
choco install android-sdk -y

# Set environment variables
$env:ANDROID_HOME = "C:\ProgramData\chocolatey\lib\android-sdk"
```

## Method 4: Use Scoop (If Available)

If you have Scoop package manager:

```powershell
# Install Android SDK
scoop install android-sdk

# Set environment variables (Scoop does this automatically)
```

## Quick Test After Setup

```powershell
# Close and reopen PowerShell, then:
cd d:\AI\company_email_scraper
flutter doctor
flutter build apk --debug
```

## If All Methods Fail

Use the **cloud build method** instead - it's the fastest and requires no local setup:

1. Run: `.\setup_github_repo.ps1`
2. Create new GitHub repository
3. Push code
4. Trigger GitHub Actions build
5. Download APK

This takes ~15 minutes total and requires no Android SDK installation.
