#!/bin/bash
set -e

echo "🔨 Building heavy dependencies layer..."

BUILD_DIR="build/nodejs"
rm -rf build dist
mkdir -p "$BUILD_DIR" dist

# Create package.json with heavy libraries
cat > "$BUILD_DIR/package.json" <<EOF
{
  "name": "navirego-heavy-dependencies-layer",
  "version": "1.0.0",
  "description": "Heavy libraries for Navirego Lambda functions",
  "dependencies": {
    "ssh2-sftp-client": "^10.0.3",
    "ssh2": "^1.15.0"
  }
}
EOF

# Install packages
echo "📦 Installing heavy libraries..."
cd "$BUILD_DIR"
npm install --production

# Remove unnecessary files
rm -rf .npm package-lock.json

# Create ZIP
echo "📦 Creating ZIP..."
cd ..
zip -r "../dist/heavy-dependencies-layer.zip" nodejs/ -q

cd ..

echo ""
echo "✅ Heavy dependencies layer built successfully!"
echo "📁 Output: dist/heavy-dependencies-layer.zip"
echo "📦 Size: $(du -h dist/heavy-dependencies-layer.zip | cut -f1)"