#!/bin/bash

# Test Ansible Connection Script
# This script helps debug Ansible connection issues

set -e

echo "🔍 Testing Ansible Connection..."
echo "=================================="

# Check if required variables are set
echo "📋 Checking variables:"
echo "TARGET_HOST: ${TARGET_HOST:-'NOT SET'}"
echo "SSH_USER: ${SSH_USER:-'NOT SET'}"
echo "SSH_PRIVATE_KEY: ${SSH_PRIVATE_KEY:-'NOT SET'}"

# Test SSH connection
if [ -n "$TARGET_HOST" ]; then
    echo ""
    echo "🔌 Testing SSH connection to $TARGET_HOST..."
    if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no ${SSH_USER:-ubuntu}@$TARGET_HOST "echo 'SSH connection successful'"; then
        echo "✅ SSH connection successful"
    else
        echo "❌ SSH connection failed"
        exit 1
    fi
else
    echo "⚠️  TARGET_HOST not set, skipping SSH test"
fi

# Test Ansible ping
echo ""
echo "🏓 Testing Ansible ping..."
if ansible all -i inventory.yml -m ping -e "target_host=$TARGET_HOST" -e "ssh_user=${SSH_USER:-ubuntu}"; then
    echo "✅ Ansible ping successful"
else
    echo "❌ Ansible ping failed"
    exit 1
fi

echo ""
echo "✅ All tests passed!" 