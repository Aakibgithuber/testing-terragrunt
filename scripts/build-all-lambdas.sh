#!/bin/bash
set -e

echo "=========================================="
echo "🔨 Building All Lambda Functions"
echo "=========================================="

LAMBDAS=(
  "sftp_data_dump"
  "ai_category_finder"
  "push_to_db"
  "load_to_mongo"
  "find_diff_schema"
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MODULES_DIR="$PROJECT_ROOT/modules/lambda"

cd "$PROJECT_ROOT"

for lambda in "${LAMBDAS[@]}"; do
  LAMBDA_SRC="lambda-src/$lambda"

  if [ ! -d "$LAMBDA_SRC" ]; then
    echo "⚠️  Skipping $lambda (source not found)"
    continue
  fi

  echo ""
  echo "=========================================="
  echo "Building Lambda: $lambda"
  echo "=========================================="

  cd "$LAMBDA_SRC"

  # Check if package.json exists
  if [ ! -f "package.json" ]; then
    echo "❌ No package.json found for $lambda"
    exit 1
  fi

  # Install dependencies
  echo "📦 Installing dependencies..."
  if [ -f package-lock.json ]; then
    npm ci
  else
    npm install
  fi
  
#   # Run tests
#   if grep -q "\"test\"" package.json; then
#     echo "🧪 Running tests..."
#     npm test
#   fi

#   # Lint
#   if grep -q "\"lint\"" package.json; then
#     echo "🔍 Linting..."
#     npm run lint
#   fi

  # Build TypeScript
  echo "🔨 Building TypeScript..."
  npm run build

  # Create deployment package
  echo "📦 Creating deployment package..."

  BUILD_DIR="build"
  rm -rf "$BUILD_DIR"
  mkdir -p "$BUILD_DIR"

  # Copy compiled code
  cp -r dist/* "$BUILD_DIR/"

  # Copy package files if they exist
  if [ -f "package.json" ]; then
    cp package.json "$BUILD_DIR/" 2>/dev/null || true
  fi
  if [ -f "package-lock.json" ]; then
    cp package-lock.json "$BUILD_DIR/" 2>/dev/null || true
  fi

  # Install production dependencies if package.json exists
  if [ -f "$BUILD_DIR/package.json" ]; then
    cd "$BUILD_DIR"
    npm ci --production --ignore-scripts 2>/dev/null || true
    cd ..
  fi

  # Create ZIP
  cd "$BUILD_DIR"
  zip -r "../lambda.zip" . -q
  cd ..

  # Copy to Terraform modules directory
  LAMBDA_MODULE_DIR="$MODULES_DIR/$lambda"
  mkdir -p "$LAMBDA_MODULE_DIR"
  mv lambda.zip "$LAMBDA_MODULE_DIR/"

  echo "✅ Built $lambda → $LAMBDA_MODULE_DIR/lambda.zip"
  echo "📦 Size: $(du -h "$LAMBDA_MODULE_DIR/lambda.zip" | cut -f1)"

  # Cleanup
  rm -rf build dist node_modules

  cd "$PROJECT_ROOT"
done

echo ""
echo "=========================================="
echo "✅ All Lambdas built successfully!"
echo "=========================================="