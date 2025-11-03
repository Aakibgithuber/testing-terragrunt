#!/bin/bash
set -e

echo "=========================================="
echo "🔨 Building All Lambda Layers"
echo "=========================================="

LAYERS=(
  "common-utils"
  "aws-dependencies"
  "heavy-dependencies"
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Your target S3 bucket (keep in GitHub secret TF_VAR_LAYERS_BUCKET_NAME)
S3_BUCKET="${TF_VAR_LAYERS_BUCKET_NAME:-navirego-lambda-layers-dev}"
S3_PREFIX="lambda-layers"

cd "$PROJECT_ROOT"

for layer in "${LAYERS[@]}"; do
  echo ""
  echo "=========================================="
  echo "Building layer: $layer"
  echo "=========================================="

  LAYER_DIR="lambda-src/layers/$layer"

  if [ ! -d "$LAYER_DIR" ]; then
    echo "⚠️  Layer directory not found: $LAYER_DIR"
    continue
  fi

  cd "$LAYER_DIR"

  if [ -f "build.sh" ]; then
    chmod +x build.sh
    ./build.sh
  else
    echo "❌ No build.sh found in $LAYER_DIR"
    exit 1
  fi

  cd "$PROJECT_ROOT"

  ZIP_PATH="lambda-src/layers/$layer/dist/${layer}-layer.zip"

  if [ -f "$ZIP_PATH" ]; then
    echo "📦 Uploading $ZIP_PATH to s3://$S3_BUCKET/$S3_PREFIX/$layer/"
    aws s3 cp "$ZIP_PATH" "s3://$S3_BUCKET/$S3_PREFIX/$layer/"
  else
    echo "❌ Zip not found for layer: $layer"
  fi
done

echo ""
echo "✅ All layers built and uploaded successfully!"
