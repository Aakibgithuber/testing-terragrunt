#!/bin/bash
set -e

LAYER_NAME="common-utils"
LAYER_DIR="$(pwd)"
BUILD_DIR="$LAYER_DIR/build"
DIST_DIR="$LAYER_DIR/dist"

echo "=========================================="
echo "🔨 Building Layer: $LAYER_NAME"
echo "=========================================="

# Clean previous builds
rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$BUILD_DIR/nodejs" "$DIST_DIR"

# Navigate to source directory
cd "$LAYER_DIR/nodejs"

# Install all dependencies (including devDependencies for building)
echo "📦 Installing dependencies..."
if [ -f package-lock.json ]; then
  npm ci
else
  npm install
fi

# # Run tests
# echo "🧪 Running tests..."
# npm test

# # Lint code
# echo "🔍 Linting..."
# npm run lint

# Build TypeScript
echo "🔨 Compiling TypeScript..."
npm run build

# Copy compiled files to build directory
echo "📋 Copying compiled files..."
cp -r dist "$BUILD_DIR/nodejs/"

# Copy package.json and package-lock.json
cp package.json package-lock.json "$BUILD_DIR/nodejs/"

# Install ONLY production dependencies in build directory
echo "📦 Installing production dependencies..."
cd "$BUILD_DIR/nodejs"
npm ci --production --ignore-scripts

# Remove unnecessary files
echo "🧹 Cleaning up..."
rm -rf .npm package-lock.json

# Create ZIP file
echo "📦 Creating ZIP package..."
cd "$BUILD_DIR"
zip -r "$DIST_DIR/${LAYER_NAME}-layer.zip" nodejs/ -q

cd "$LAYER_DIR"

# Show results
echo ""
echo "✅ Layer built successfully!"
echo "📁 Output: $DIST_DIR/${LAYER_NAME}-layer.zip"
echo "📦 Size: $(du -h "$DIST_DIR/${LAYER_NAME}-layer.zip" | cut -f1)"
echo ""