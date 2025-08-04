#!/bin/bash

# Vercel Deployment Script
# This script deploys your FastAPI application to Vercel

set -e  # Exit on any error

echo "🚀 Deploying to Vercel..."
echo "=========================="

# Check if user is logged in
if ! npx vercel whoami &> /dev/null; then
    echo "🔐 Please login to Vercel..."
    npx vercel login
fi

# Deploy to Vercel
echo "🚀 Deploying application..."
npx vercel --prod

echo "✅ Deployment completed!"
echo "=========================="
echo ""
echo "Your application is now live on Vercel!"
echo "Check the output above for your deployment URL." 