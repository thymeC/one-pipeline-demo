#!/bin/bash

# Vercel Deployment Script
# This script deploys your FastAPI application to Vercel

set -e  # Exit on any error

echo "🚀 Deploying to Vercel..."
echo "=========================="

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "📦 Installing Vercel CLI..."
    npm install -g vercel
fi

# Check if user is logged in
if ! vercel whoami &> /dev/null; then
    echo "🔐 Please login to Vercel..."
    vercel login
fi

# Deploy to Vercel
echo "🚀 Deploying application..."
vercel --prod

echo "✅ Deployment completed!"
echo "=========================="
echo ""
echo "Your application is now live on Vercel!"
echo "Check the output above for your deployment URL." 