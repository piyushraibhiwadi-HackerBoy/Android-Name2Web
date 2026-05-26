# Build APK Without Local Installation

## Option 1: GitHub Actions (Recommended - Free)

### Steps:

1. **Create GitHub Repository**
   - Go to https://github.com/new
   - Create a new repository (can be private)
   - Don't initialize with README (we have files already)

2. **Push Code to GitHub**
   ```powershell
   cd d:\AI\company_email_scraper
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
   git push -u origin main
   ```

3. **Trigger Build**
   - Go to your repository on GitHub
   - Click "Actions" tab
   - Click "Build Android APK" workflow
   - Click "Run workflow" button

4. **Download APK**
   - Wait for build to complete (~5-10 minutes)
   - Go to Actions tab → Click on the completed run
   - Scroll to "Artifacts" section
   - Download "release-apk"

### Requirements:
- GitHub account (free)
- Git installed (or use GitHub Desktop)

---

## Option 2: Codemagic (Free Tier)

### Steps:

1. Go to https://codemagic.io
2. Sign up with GitHub account
3. Connect your GitHub repository
4. Configure build settings:
   - Flutter version: 3.24.0
   - Build type: APK
5. Click "Start new build"
6. Download APK when complete

### Free Tier:
- 1 project
- 500 build minutes/month
- No credit card required

---

## Option 3: Bitrise (Free Tier)

### Steps:

1. Go to https://app.bitrise.io
2. Sign up with GitHub
3. Add app from GitHub
4. Configure workflow:
   - Add "Flutter Install" step
   - Add "Flutter Build" step
5. Start build
6. Download APK

### Free Tier:
- 1 app
- 10 builds/month
- 10 minutes/build

---

## Option 4: GitLab CI (Free)

### Steps:

1. Go to https://gitlab.com
2. Create new project
3. Push code to GitLab
4. Create `.gitlab-ci.yml` file:

```yaml
image: cirrusci/flutter:3.24.0

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

---

## Option 5: AppVeyor (Free for Open Source)

### Steps:

1. Go to https://www.appveyor.com
2. Sign up with GitHub
3. Add project
4. Configure build:
   - Install Flutter
   - Build APK
5. Download artifacts

---

## Recommendation: GitHub Actions

**Why GitHub Actions is best for you:**
- Completely free
- No account setup needed (if you have GitHub)
- Automatic builds on push
- Easy to download artifacts
- Works with private repositories
- No credit card required

**Total time to APK:** ~15-20 minutes
- 5 minutes: Git setup and push
- 10 minutes: Cloud build
- 2 minutes: Download APK

---

## Quick Start with GitHub Actions

If you have Git installed:

```powershell
cd d:\AI\company_email_scraper
git init
git add .
git commit -m "Initial commit"
git branch -M main
# Create repo on GitHub first, then:
git remote add origin https://github.com/YOUR_USERNAME/company_email_scraper.git
git push -u origin main
```

Then go to GitHub → Actions → Run workflow → Download APK.

---

## Troubleshooting

### Git not installed?
- Download from https://git-scm.com/download/win
- Or use GitHub Desktop: https://desktop.github.com

### Build fails?
- Check Actions tab for error logs
- Ensure all files are committed
- Verify workflow file is in `.github/workflows/` folder

### APK not downloading?
- Check "Artifacts" section in Actions
- Ensure build completed successfully
- Try downloading from a different browser
