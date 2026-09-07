<#
.SYNOPSIS
    Sets up the Blutter CI repo, copies Oxford Dictionary libs, and pushes to GitHub.
.DESCRIPTION
    Creates a new GitHub repo, copies the extracted .so files, and triggers the workflow.
#>

param(
    [string]$RepoName = "blutter-ci",
    [string]$GitHubUser = "mohammedsthree-debug",
    [switch]$UseLFS = $false
)

$ErrorActionPreference = "Stop"
$BlutterCIDir = $PSScriptRoot
$LibsDir = Join-Path $BlutterCIDir "libs"
$OxfordLibs = "C:\Users\ZETTA\.gemini\antigravity-ide\scratch\oxford_libs"

Write-Host "`n=== Blutter CI Setup ===" -ForegroundColor Cyan

# 1. Create libs directory and copy .so files
Write-Host "[1/5] Copying native libraries..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $LibsDir -Force | Out-Null
Copy-Item "$OxfordLibs\libapp.so" "$LibsDir\libapp.so" -Force
Copy-Item "$OxfordLibs\libflutter.so" "$LibsDir\libflutter.so" -Force

$libappSize = (Get-Item "$LibsDir\libapp.so").Length / 1MB
$libflutterSize = (Get-Item "$LibsDir\libflutter.so").Length / 1MB
Write-Host "  libapp.so: $([math]::Round($libappSize, 1)) MB" -ForegroundColor Green
Write-Host "  libflutter.so: $([math]::Round($libflutterSize, 1)) MB" -ForegroundColor Green

# 2. Initialize git repo
Write-Host "[2/5] Initializing git repo..." -ForegroundColor Yellow
Set-Location $BlutterCIDir

if (-not (Test-Path ".git")) {
    git init
    git branch -m main
}

# 3. Setup LFS if requested (for repos with large file limits)
if ($UseLFS) {
    Write-Host "[3/5] Setting up Git LFS..." -ForegroundColor Yellow
    git lfs install
    git lfs track "libs/*.so"
    git lfs track "apks/*.apk"
} else {
    Write-Host "[3/5] Skipping LFS (files under GitHub 100MB limit)..." -ForegroundColor Yellow
    # Remove LFS attributes since we're not using it
    if (Test-Path ".gitattributes") {
        Remove-Item ".gitattributes" -Force
    }
}

# 4. Commit everything
Write-Host "[4/5] Committing files..." -ForegroundColor Yellow
git add -A
git commit -m "feat: add Blutter CI workflow + Oxford Dictionary libs

- GitHub Actions workflow for automated Blutter analysis
- libapp.so (Dart AOT snapshot, $([math]::Round($libappSize, 1)) MB)
- libflutter.so (Flutter engine, $([math]::Round($libflutterSize, 1)) MB)
- Dart version: 3.11.5, android arm64, compressed-pointers
- Auto-greps for licensing/premium/purchase symbols"

# 5. Create GitHub repo and push
Write-Host "[5/5] Creating GitHub repo and pushing..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Run these commands to create the repo and push:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  gh repo create $RepoName --private --source . --push" -ForegroundColor White
Write-Host ""
Write-Host "Or manually:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Create repo at: https://github.com/new" -ForegroundColor White
Write-Host "     Name: $RepoName" -ForegroundColor White
Write-Host "     Private: Yes" -ForegroundColor White
Write-Host ""
Write-Host "  2. Then run:" -ForegroundColor White
Write-Host "     git remote add origin https://github.com/$GitHubUser/$RepoName.git" -ForegroundColor White
Write-Host "     git push -u origin main" -ForegroundColor White
Write-Host ""
Write-Host "  3. Trigger the workflow:" -ForegroundColor White
Write-Host "     Go to Actions tab -> 'Blutter Flutter Analysis' -> 'Run workflow'" -ForegroundColor White
Write-Host "     Set app_name: oxford_dictionary" -ForegroundColor White
Write-Host ""
Write-Host "=== Done! ===" -ForegroundColor Green
