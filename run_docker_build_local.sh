#!/bin/bash

# Local Docker Build Runner
# This script runs the equivalent of your build job locally

set -e  # Exit on any error

echo "🐳 Running Docker Build Locally..."
echo "=================================="

# Set environment variables (similar to your workflow)
export REGISTRY="docker.io"
export IMAGE_NAME="jinggegeha/one-pipeline-demo"

# Build the Docker image
echo "🔨 Building Docker image..."
docker build -t $IMAGE_NAME .

# Tag with latest
echo "🏷️  Tagging image..."
docker tag $IMAGE_NAME $IMAGE_NAME:latest

# Show the built image
echo "📋 Built images:"
docker images | grep $IMAGE_NAME

echo "✅ Docker build completed successfully!"
echo "=================================="
echo ""
echo "To push to Docker Hub, run:"
echo "docker login"
echo "docker push $IMAGE_NAME:latest" 