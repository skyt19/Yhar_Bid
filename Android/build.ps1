# Yharbid Android Build Script
# Usage: .\build.ps1 [debug|release]

param(
    [Parameter(Position=0)]
    [ValidateSet("debug", "release")]
    [string]$BuildType = "debug"
)

Write-Host "🚀 Building Yharbid Android APK ($BuildType mode)..." -ForegroundColor Cyan
Write-Host ""

# Set JAVA_HOME to JDK 23
$env:JAVA_HOME = "C:\Program Files\Java\jdk-23"
Write-Host "✅ JAVA_HOME set to: $env:JAVA_HOME" -ForegroundColor Green

# Check if google-services.json exists
$googleServicesPath = "android\app\google-services.json"
if (-Not (Test-Path $googleServicesPath)) {
    Write-Host "⚠️  WARNING: google-services.json not found!" -ForegroundColor Yellow
    Write-Host "   Location: $googleServicesPath" -ForegroundColor Yellow
    Write-Host "   See: android\app\README_FIREBASE.md for instructions" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        Write-Host "❌ Build cancelled." -ForegroundColor Red
        exit 1
    }
}

# Clean build artifacts
Write-Host ""
Write-Host "🧹 Cleaning build artifacts..." -ForegroundColor Cyan
flutter clean

# Get dependencies
Write-Host ""
Write-Host "📦 Getting dependencies..." -ForegroundColor Cyan
flutter pub get

# Build APK
Write-Host ""
Write-Host "🔨 Building APK ($BuildType)..." -ForegroundColor Cyan
if ($BuildType -eq "release") {
    flutter build apk --release
} else {
    flutter build apk --debug
}

# Check if build succeeded
$apkPath = "build\app\outputs\flutter-apk\app-$BuildType.apk"
if (Test-Path $apkPath) {
    Write-Host ""
    Write-Host "✅ Build successful!" -ForegroundColor Green
    Write-Host "📱 APK location: $apkPath" -ForegroundColor Cyan
    
    # Get file size
    $fileSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
    Write-Host "📊 APK size: $fileSize MB" -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "📲 To install on device:" -ForegroundColor Yellow
    Write-Host "   flutter install" -ForegroundColor White
    Write-Host "   OR" -ForegroundColor Yellow
    Write-Host "   adb install $apkPath" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "❌ Build failed! Check logs above for errors." -ForegroundColor Red
    exit 1
}
