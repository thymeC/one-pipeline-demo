#!/bin/bash

# Verify SSH Agent Setup Script
# This script helps debug SSH agent configuration in GitHub Actions

set -e

echo "🔍 Verifying SSH Agent Setup..."
echo "=================================="

# Check if SSH agent is running
echo "📋 SSH Agent Status:"
if ssh-add -l; then
    echo "✅ SSH agent is running and has keys loaded"
else
    echo "❌ SSH agent is not running or has no keys"
    exit 1
fi

# Check SSH configuration
echo ""
echo "🔧 SSH Configuration:"
echo "SSH_AUTH_SOCK: ${SSH_AUTH_SOCK:-'NOT SET'}"
echo "SSH_AGENT_PID: ${SSH_AGENT_PID:-'NOT SET'}"

# List loaded keys
echo ""
echo "🔑 Loaded SSH Keys:"
ssh-add -l

# Test SSH connection if TARGET_HOST is set
if [ -n "$TARGET_HOST" ]; then
    echo ""
    echo "🔌 Testing SSH connection to $TARGET_HOST..."
    if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o BatchMode=yes ${SSH_USER:-ubuntu}@$TARGET_HOST "echo 'SSH connection successful'"; then
        echo "✅ SSH connection successful"
    else
        echo "❌ SSH connection failed"
        echo "Debug info:"
        ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o BatchMode=yes -v ${SSH_USER:-ubuntu}@$TARGET_HOST "echo 'test'" 2>&1 | head -20
        exit 1
    fi
else
    echo "⚠️  TARGET_HOST not set, skipping SSH test"
fi

echo ""
echo "✅ SSH agent verification completed!" 