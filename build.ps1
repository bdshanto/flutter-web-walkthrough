# Build script for Flutter Web with automatic version update
# This script updates version.json with new hash and timestamp before building

param(
    [string]$Version = "1.0.0"
)

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Flutter Web Build with Version Update" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Generate timestamp
$timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
$hash = "$Version-$timestamp"

Write-Host "Creating version.json..." -ForegroundColor Yellow
Write-Host "  Version: $Version" -ForegroundColor Gray
Write-Host "  Hash: $hash" -ForegroundColor Gray
Write-Host "  Timestamp: $timestamp" -ForegroundColor Gray

# Create version.json content
$versionJson = @{
    version = $Version
    hash = $hash
    timestamp = $timestamp
} | ConvertTo-Json -Depth 10

# Write to web/version.json
$versionPath = "web\version.json"
$versionJson | Out-File -FilePath $versionPath -Encoding UTF8 -NoNewline

Write-Host "Version file created successfully!" -ForegroundColor Green
Write-Host ""

# Clean previous build
Write-Host "Cleaning previous build..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host ""
Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Build for web
Write-Host ""
Write-Host "Building Flutter web app..." -ForegroundColor Yellow
flutter build web --release

# Copy version.json to build output
Write-Host ""
Write-Host "Copying version.json to build output..." -ForegroundColor Yellow
Copy-Item -Path $versionPath -Destination "build\web\version.json" -Force

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Build location: build\web\" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor Cyan
Write-Host "Hash: $hash" -ForegroundColor Cyan
