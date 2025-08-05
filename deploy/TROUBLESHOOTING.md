# SSH Connection Troubleshooting Guide

This guide helps you resolve SSH connection issues when deploying with Ansible.

## Common Error: "Permission denied (publickey)"

This error means SSH key authentication is failing. Here's how to fix it:

### Step 1: Verify GitHub Secrets

1. **Go to your GitHub repository**
   - Navigate to Settings → Secrets and variables → Actions
   - Check that these secrets exist:
     - `TARGET_HOST`
     - `SSH_USER` 
     - `SSH_PRIVATE_KEY`

2. **Verify SSH_PRIVATE_KEY format**
   - The secret should contain the ENTIRE private key
   - Include the header and footer lines:
   ```
   -----BEGIN OPENSSH PRIVATE KEY-----
   [key content]
   -----END OPENSSH PRIVATE KEY-----
   ```

### Step 2: Verify Target Server Setup

1. **Check if public key is on target server**
   ```bash
   # Connect to your target server
   ssh your-username@your-server-ip
   
   # Check authorized_keys file
   cat ~/.ssh/authorized_keys
   ```

2. **Add your public key to target server**
   ```bash
   # From your local machine
   ssh-copy-id your-username@your-server-ip
   ```

3. **Test SSH connection manually**
   ```bash
   ssh your-username@your-server-ip
   ```

### Step 3: Generate New SSH Key Pair (if needed)

If you don't have SSH keys or want to create new ones:

```bash
# Generate new SSH key pair
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# Copy public key to target server
ssh-copy-id -i ~/.ssh/id_rsa.pub your-username@your-server-ip

# Test connection
ssh your-username@your-server-ip
```

### Step 4: Update GitHub Secrets

1. **Get your private key content**
   ```bash
   cat ~/.ssh/id_rsa
   ```

2. **Update GitHub secret**
   - Go to your repository → Settings → Secrets and variables → Actions
   - Edit `SSH_PRIVATE_KEY` secret
   - Paste the ENTIRE private key content (including headers)

### Step 5: Test Locally

You can test the setup locally before running GitHub Actions:

```bash
# Set environment variables
export TARGET_HOST="your-server-ip"
export SSH_USER="your-username"

# Add your key to SSH agent
ssh-add ~/.ssh/id_rsa

# Test connection
cd deploy
./debug_ssh.sh
```

### Step 6: Check Server SSH Configuration

On your target server, verify SSH is configured correctly:

```bash
# Check SSH service status
sudo systemctl status ssh

# Check SSH configuration
sudo cat /etc/ssh/sshd_config | grep -E "(PubkeyAuthentication|AuthorizedKeysFile)"

# Should show:
# PubkeyAuthentication yes
# AuthorizedKeysFile .ssh/authorized_keys
```

### Step 7: Debug GitHub Actions

The GitHub Actions workflow now includes debugging steps that will show:
- SSH agent status
- Loaded keys
- Connection attempts
- Verbose SSH output

Check the workflow logs for detailed error information.

## Common Issues and Solutions

### Issue: "No such identity"
**Solution**: SSH agent isn't loaded. The workflow should handle this automatically.

### Issue: "Host key verification failed"
**Solution**: The workflow adds the host to known_hosts automatically.

### Issue: "Connection timeout"
**Solution**: 
- Check if server is reachable
- Verify firewall settings
- Check if SSH port (22) is open

### Issue: "Permission denied (password)"
**Solution**: Server is configured for password authentication instead of key authentication.

## Testing Commands

### Test SSH connection
```bash
ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o BatchMode=yes username@server-ip
```

### Test with verbose output
```bash
ssh -v username@server-ip
```

### Check SSH agent
```bash
ssh-add -l
```

### Test Ansible connection
```bash
ansible all -i inventory.yml -m ping -e "target_host=server-ip" -e "ssh_user=username"

ansible all -i inventory.yml -m ping -e "target_host=8.136.4.119" -e "ssh_user=root"
```

## Still Having Issues?

1. **Check GitHub Actions logs** for detailed error messages
2. **Run the debug script locally** to identify the issue
3. **Verify all steps** in this guide
4. **Consider using a different SSH key** if the current one has issues 