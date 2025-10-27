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