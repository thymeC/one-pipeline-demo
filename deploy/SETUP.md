# GitHub Secrets Setup for Ansible Deployment

To enable automated deployment with Ansible, you need to configure the following secrets in your GitHub repository.

## Required Secrets

### 1. TARGET_HOST
- **Description**: The IP address or hostname of your target server
- **Example**: `192.168.1.100` or `my-server.example.com`
- **How to set**: Go to your repository → Settings → Secrets and variables → Actions → New repository secret

### 2. SSH_USER
- **Description**: SSH username for connecting to the target server
- **Example**: `ubuntu`, `root`, `deploy`
- **Default**: `ubuntu` (if not set)
- **How to set**: Go to your repository → Settings → Secrets and variables → Actions → New repository secret

### 3. SSH_PRIVATE_KEY
- **Description**: SSH private key for authentication
- **Format**: The entire private key content (including `-----BEGIN OPENSSH PRIVATE KEY-----` and `-----END OPENSSH PRIVATE KEY-----`)
- **How to set**: Go to your repository → Settings → Secrets and variables → Actions → New repository secret

## How to Set Up SSH Keys

### 1. Generate SSH Key Pair (if you don't have one)
```bash
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
```

### 2. Add Public Key to Target Server
```bash
# Copy your public key to the target server
ssh-copy-id -i ~/.ssh/id_rsa.pub username@target-server
```

### 3. Test SSH Connection
```bash
ssh username@target-server
```

### 4. Add Private Key to GitHub Secrets
1. Copy the content of your private key:
   ```bash
   cat ~/.ssh/id_rsa
   ```
2. Go to your GitHub repository
3. Navigate to Settings → Secrets and variables → Actions
4. Click "New repository secret"
5. Name: `SSH_PRIVATE_KEY`
6. Value: Paste the entire private key content

## Testing the Setup

### Local Testing
You can test the connection locally using the provided script:

```bash
cd deploy
export TARGET_HOST="your-server-ip"
export SSH_USER="your-username"
export SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"
./test_connection.sh
```

### GitHub Actions Testing
Once you've set up the secrets, the GitHub Actions workflow will:
1. Test the Ansible connection with a ping
2. Run the deployment playbook
3. Perform health checks

## Troubleshooting

### Common Issues

1. **"hostname contains invalid characters"**
   - Make sure `TARGET_HOST` doesn't contain special characters
   - Use IP address instead of hostname if DNS issues occur

2. **"Permission denied (publickey)"**
   - Verify the SSH private key is correctly added to GitHub secrets
   - Ensure the public key is added to the target server's `~/.ssh/authorized_keys`

3. **"Connection timeout"**
   - Check if the target server is reachable
   - Verify firewall settings allow SSH connections
   - Ensure the IP address/hostname is correct

### Debug Commands

```bash
# Test SSH connection
ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa username@target-host

# Test Ansible connection
ansible all -i inventory.yml -m ping -e "target_host=target-host" -e "ssh_user=username"

# Run playbook with verbose output
ansible-playbook -i inventory.yml deploy.yml -vvv
```

## Security Notes

- Never commit SSH private keys to your repository
- Use dedicated deployment keys with minimal permissions
- Regularly rotate SSH keys
- Consider using SSH key passphrases for additional security 