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

  # Make build script executable
  if [ -f "build.sh" ]; then
    chmod +x build.sh
    ./build.sh
  else
    echo "❌ No build.sh found in $LAYER_DIR"
    exit 1
  fi

  cd "$PROJECT_ROOT"
done

echo ""
echo "=========================================="
echo "✅ All layers built successfully!"
echo "=========================================="
echo ""
echo "📦 Built layers:"
for layer in "${LAYERS[@]}"; do
  ZIP_FILE="lambda-src/layers/$layer/dist/${layer}-layer.zip"
  if [ -f "$ZIP_FILE" ]; then
    echo "  - $layer: $(du -h "$ZIP_FILE" | cut -f1)"
  fi
done