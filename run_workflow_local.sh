#!/bin/bash

# Local GitHub Workflow Runner
# This script runs the equivalent of your CI/CD workflow locally

set -e  # Exit on any error

echo "🚀 Running GitHub Workflow Locally..."
echo "======================================"

# Activate virtual environment
echo "📦 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install -r requirements.txt
pip install pytest pytest-asyncio httpx flake8 black

# Run tests
echo "🧪 Running tests..."
python -m pytest tests/ -v

# Run linting
echo "🔍 Running linting..."
flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics

# Run formatting check
echo "🎨 Checking code formatting..."
black . --check

echo "✅ All checks passed! Your workflow would succeed on GitHub."
echo "======================================" 