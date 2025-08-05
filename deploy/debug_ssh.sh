#!/bin/bash

# Comprehensive SSH Debugging Script
# This script helps identify SSH connection issues

set -e

echo "🔍 Comprehensive SSH Debugging..."
echo "=================================="

# Check environment variables
echo "📋 Environment Variables:"
echo "TARGET_HOST: ${TARGET_HOST:-'NOT SET'}"
echo "SSH_USER: ${SSH_USER:-'NOT SET'}"
echo "SSH_AUTH_SOCK: ${SSH_AUTH_SOCK:-'NOT SET'}"
echo "SSH_AGENT_PID: ${SSH_AGENT_PID:-'NOT SET'}"

# Check SSH agent
echo ""
echo "🔧 SSH Agent Status:"
if command -v ssh-add >/dev/null 2>&1; then
    echo "ssh-add command available"
    if ssh-add -l 2>/dev/null; then
        echo "✅ SSH agent has keys loaded"
    else
        echo "❌ SSH agent has no keys or is not running"
    fi
else
    echo "❌ ssh-add command not available"
fi

# Check SSH configuration
echo ""
echo "🔧 SSH Configuration:"
if [ -f ~/.ssh/config ]; then
    echo "SSH config file exists"
    cat ~/.ssh/config
else
    echo "No SSH config file found"
fi

# Check known hosts
echo ""
echo "🔧 Known Hosts:"
if [ -f ~/.ssh/known_hosts ]; then
    echo "Known hosts file exists"
    if [ -n "$TARGET_HOST" ]; then
        if grep -q "$TARGET_HOST" ~/.ssh/known_hosts; then
            echo "✅ Target host found in known_hosts"
        else
            echo "❌ Target host NOT found in known_hosts"
        fi
    fi
else
    echo "No known_hosts file found"
fi

# Test SSH connection with verbose output
if [ -n "$TARGET_HOST" ] && [ -n "$SSH_USER" ]; then
    echo ""
    echo "🔌 Testing SSH connection to $SSH_USER@$TARGET_HOST..."
    echo "Command: ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o BatchMode=yes -v $SSH_USER@$TARGET_HOST 'echo test'"
    
    # Run SSH with verbose output and capture both stdout and stderr
    if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o BatchMode=yes -v $SSH_USER@$TARGET_HOST 'echo test' 2>&1; then
        echo "✅ SSH connection successful"
    else
        echo "❌ SSH connection failed"
        echo ""
        echo "🔍 Common issues and solutions:"
        echo "1. Check if SSH_PRIVATE_KEY secret is correctly set in GitHub"
        echo "2. Verify the public key is added to ~/.ssh/authorized_keys on target server"
        echo "3. Check if target server allows SSH key authentication"
        echo "4. Verify TARGET_HOST and SSH_USER are correct"
        echo ""
        echo "To add your public key to the target server:"
        echo "ssh-copy-id $SSH_USER@$TARGET_HOST"
        exit 1
    fi
else
    echo "⚠️  TARGET_HOST or SSH_USER not set, skipping SSH test"
fi

echo ""
echo "✅ SSH debugging completed!" 