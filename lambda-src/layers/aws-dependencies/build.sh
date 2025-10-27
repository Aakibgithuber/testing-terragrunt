#!/bin/bash
set -e

echo "🔨 Building AWS dependencies layer..."

BUILD_DIR="build/nodejs"
rm -rf build dist
mkdir -p "$BUILD_DIR" dist

# Create package.json with AWS SDK dependencies
cat > "$BUILD_DIR/package.json" <<EOF
{
  "name": "navirego-aws-dependencies-layer",
  "version": "1.0.0",
  "description": "AWS SDK packages for Navirego Lambda functions",
  "dependencies": {
    "@aws-sdk/client-s3": "^3.490.0",
    "@aws-sdk/client-secrets-manager": "^3.490.0",
    "@aws-sdk/client-sqs": "^3.490.0",
    "@aws-sdk/client-dynamodb": "^3.490.0",
    "@aws-sdk/lib-storage": "^3.490.0",
    "@aws-sdk/client-sns": "^3.490.0"
  }
}
EOF

# Install packages
echo "📦 Installing AWS SDK packages..."
cd "$BUILD_DIR"
npm install --production

# Remove unnecessary files
rm -rf .npm package-lock.json

# Create ZIP
echo "📦 Creating ZIP..."
cd ..
zip -r "../dist/aws-dependencies-layer.zip" nodejs/ -q

cd ..

echo ""
echo "✅ AWS dependencies layer built successfully!"
echo "📁 Output: dist/aws-dependencies-layer.zip"
echo "📦 Size: $(du -h dist/aws-dependencies-layer.zip | cut -f1)"