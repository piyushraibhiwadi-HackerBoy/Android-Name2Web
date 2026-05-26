# GitHub Repository Setup Helper
# This script helps you set up a GitHub repository for cloud APK builds

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GitHub Repository Setup Helper" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if git is available
$gitAvailable = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitAvailable) {
    Write-Host "ERROR: Git is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Install Git from: https://git-scm.com/download/win" -ForegroundColor Yellow
    pause
    exit 1
}

# Navigate to project directory
$projectPath = "d:\AI\company_email_scraper"
Set-Location $projectPath
Write-Host "Project directory: $projectPath" -ForegroundColor Green
Write-Host ""

# Check current git status
Write-Host "Checking git status..." -ForegroundColor Yellow
git status
Write-Host ""

# Show current remote
Write-Host "Current git remote:" -ForegroundColor Yellow
git remote -v
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Choose an option:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Create a NEW GitHub repository (recommended)" -ForegroundColor White
Write-Host "2. Use EXISTING repository (fix access issues)" -ForegroundColor White
Write-Host "3. Check current repository status only" -ForegroundColor White
Write-Host ""
$choice = Read-Host "Enter your choice (1, 2, or 3)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "Creating New GitHub Repository" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        
        $username = Read-Host "Enter your GitHub username"
        $repoName = Read-Host "Enter repository name (default: company_email_scraper)"
        if ([string]::IsNullOrWhiteSpace($repoName)) {
            $repoName = "company_email_scraper"
        }
        
        $newRemoteUrl = "https://github.com/$username/$repoName.git"
        
        Write-Host ""
        Write-Host "STEP 1: Create repository on GitHub" -ForegroundColor Yellow
        Write-Host "Go to: https://github.com/new" -ForegroundColor White
        Write-Host "Repository name: $repoName" -ForegroundColor White
        Write-Host "Make it private if desired" -ForegroundColor White
        Write-Host "DO NOT initialize with README, .gitignore, or license" -ForegroundColor Yellow
        Write-Host ""
        Read-Host "Press Enter after creating the repository on GitHub"
        
        Write-Host ""
        Write-Host "STEP 2: Update git remote" -ForegroundColor Yellow
        git remote set-url origin $newRemoteUrl
        git remote -v
        Write-Host ""
        
        Write-Host "STEP 3: Push to GitHub" -ForegroundColor Yellow
        git push -u origin main
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "SUCCESS! Repository created and pushed" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "Next steps:" -ForegroundColor Cyan
            Write-Host "1. Go to: https://github.com/$username/$repoName/actions" -ForegroundColor White
            Write-Host "2. Click 'Build Android APK' workflow" -ForegroundColor White
            Write-Host "3. Click 'Run workflow' button" -ForegroundColor White
            Write-Host "4. Wait 5-10 minutes for build" -ForegroundColor White
            Write-Host "5. Download APK from Artifacts section" -ForegroundColor White
            Write-Host ""
        } else {
            Write-Host ""
            Write-Host "ERROR: Failed to push to GitHub" -ForegroundColor Red
            Write-Host "Check your GitHub credentials and repository access" -ForegroundColor Yellow
        }
    }
    
    "2" {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "Fixing Existing Repository" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        
        Write-Host "Current remote: https://github.com/piyushraibhiwadi-HackerBoy/company_email_scraper.git" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Troubleshooting steps:" -ForegroundColor Yellow
        Write-Host "1. Check if you have access to this repository" -ForegroundColor White
        Write-Host "2. Go to: https://github.com/piyushraibhiwadi-HackerBoy/company_email_scraper" -ForegroundColor White
        Write-Host "3. If you don't have access, choose option 1 to create a new repo" -ForegroundColor White
        Write-Host ""
        Write-Host "If you have access, try these commands:" -ForegroundColor Yellow
        Write-Host "git remote -v" -ForegroundColor White
        Write-Host "git push -u origin main" -ForegroundColor White
        Write-Host ""
        
        $fixIt = Read-Host "Do you want to try pushing now? (Y/N)"
        if ($fixIt -eq "Y" -or $fixIt -eq "y") {
            git push -u origin main
            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "SUCCESS! Push completed" -ForegroundColor Green
                Write-Host "Go to GitHub Actions to trigger build" -ForegroundColor Cyan
            } else {
                Write-Host ""
                Write-Host "Push failed. Check your GitHub access." -ForegroundColor Red
            }
        }
    }
    
    "3" {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "Current Repository Status" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Git status:" -ForegroundColor Yellow
        git status
        Write-Host ""
        Write-Host "Git remote:" -ForegroundColor Yellow
        git remote -v
        Write-Host ""
        Write-Host "Git log (last 3 commits):" -ForegroundColor Yellow
        git log --oneline -3
        Write-Host ""
    }
    
    default {
        Write-Host "Invalid choice. Exiting." -ForegroundColor Red
    }
}

Write-Host ""
pause
