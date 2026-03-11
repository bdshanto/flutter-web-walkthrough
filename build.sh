#!/bin/bash

# Build script for Flutter Web with automatic version update
# This script updates version.json with new hash and timestamp before building

VERSION=${1:-"1.0.0"}

echo "====================================="
echo "Flutter Web Build with Version Update"
echo "====================================="
echo ""

# Generate timestamp (milliseconds since epoch)
TIMESTAMP=$(date +%s%3N)
HASH="$VERSION-$TIMESTAMP"

echo "Creating version.json..."
echo "  Version: $VERSION"
echo "  Hash: $HASH"
echo "  Timestamp: $TIMESTAMP"

# Create version.json content
cat > web/version.json << EOF
{
  "version": "$VERSION",
  "hash": "$HASH",
  "timestamp": $TIMESTAMP
}
EOF

echo "Version file created successfully!"
echo ""

# Clean previous build
echo "Cleaning previous build..."
flutter clean

# Get dependencies
echo ""
echo "Getting dependencies..."
flutter pub get

# Build for web
echo ""
echo "Building Flutter web app..."
flutter build web --release

# Copy version.json to build output
echo ""
echo "Copying version.json to build output..."
cp web/version.json build/web/version.json

echo ""
echo "====================================="
echo "Build completed successfully!"
echo "====================================="
echo ""
echo "Build location: build/web/"
echo "Version: $VERSION"
echo "Hash: $HASH"
