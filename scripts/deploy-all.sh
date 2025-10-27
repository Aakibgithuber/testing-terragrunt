#!/bin/bash
set -e

ENVIRONMENT=${1:-dev}

echo "=========================================="
echo "🚀 Deploying All Components to $ENVIRONMENT"
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# Step 1: Build layers
echo "Step 1: Building layers..."
./scripts/build-layers.sh

# Step 2: Build lambdas
echo "Step 2: Building lambdas..."
./scripts/build-all-lambdas.sh

# Step 3: Deploy layers first
echo "Step 3: Deploying layers to $ENVIRONMENT..."
cd "live/$ENVIRONMENT/layers"
terragrunt run-all apply --terragrunt-non-interactive

# Step 4: Deploy lambdas
echo "Step 4: Deploying lambdas to $ENVIRONMENT..."
cd "../lambdas"
terragrunt run-all apply --terragrunt-non-interactive

cd "$PROJECT_ROOT"

echo ""
echo "=========================================="
echo "✅ Deployment to $ENVIRONMENT completed!"
echo "=========================================="