# Docker Hub Connectivity Troubleshooting

This guide helps resolve Docker Hub connectivity issues when deploying with Ansible.

## Current Issue: Docker Hub Connection Timeout

**Symptoms:**
- `curl: (28) Failed to connect to registry-1.docker.io port 443 after 130657 ms: Connection timed out`
- `Error pulling image: Client.Timeout exceeded while awaiting headers`
- `telnet: Unable to connect to remote host: Network is unreachable`

## Diagnosis Results

✅ **Internet Connectivity**: Working (ping to 8.8.8.8 successful)  
✅ **DNS Resolution**: Working (registry-1.docker.io resolves correctly)  
✅ **Local Firewall**: Inactive (not blocking connections)  
❌ **Docker Hub Access**: Blocked (connection timeout)  

## Possible Causes & Solutions

### 1. Cloud Provider Network Restrictions

**Common in**: Alibaba Cloud, Tencent Cloud, AWS China, etc.

**Solution**: Configure Docker to use a mirror registry

```bash
# Create Docker daemon configuration
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
EOF

# Restart Docker
sudo systemctl restart docker
```

### 2. Corporate Network/Firewall

**Solution**: Configure Docker proxy

```bash
# Create Docker service directory
sudo mkdir -p /etc/systemd/system/docker.service.d

# Create proxy configuration
sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://proxy.company.com:8080"
Environment="HTTPS_PROXY=http://proxy.company.com:8080"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF

# Reload and restart Docker
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 3. Alternative: Use Local Docker Image

If you can't resolve the network issue, you can build the image locally and transfer it:

```bash
# On your local machine
docker build -t jinggegeha/one-pipeline-demo:latest .
docker save jinggegeha/one-pipeline-demo:latest | gzip > app-image.tar.gz

# Transfer to server
scp app-image.tar.gz root@8.136.4.119:/tmp/

# On the server
docker load < /tmp/app-image.tar.gz
```

### 4. Alternative: Use Different Registry

Configure Docker to use a different registry that's accessible:

```bash
# Use Alibaba Cloud Container Registry (if available)
sudo tee /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://registry.cn-hangzhou.aliyuncs.com"
  ]
}
EOF

sudo systemctl restart docker
```

## Testing Solutions

### Test Docker Hub Access
```bash
# Test basic connectivity
curl -I https://registry-1.docker.io/v2/

# Test Docker pull
docker pull hello-world

# Test your specific image
docker pull jinggegeha/one-pipeline-demo:latest
```

### Test Alternative Registries
```bash
# Test USTC mirror
curl -I https://docker.mirrors.ustc.edu.cn/v2/

# Test NetEase mirror
curl -I https://hub-mirror.c.163.com/v2/
```

## Updated Ansible Playbook

You can modify the Ansible playbook to handle Docker Hub connectivity issues:

```yaml
- name: Configure Docker registry mirrors
  copy:
    content: |
      {
        "registry-mirrors": [
          "https://docker.mirrors.ustc.edu.cn",
          "https://hub-mirror.c.163.com"
        ]
      }
    dest: /etc/docker/daemon.json
  when: docker_check.rc == 0
  notify: restart docker

- name: Restart Docker service
  systemd:
    name: docker
    state: restarted
  when: docker_check.rc == 0
```

## Immediate Workaround

For immediate deployment, you can:

1. **Build and transfer image locally** (see option 3 above)
2. **Use a pre-built image** from an accessible registry
3. **Deploy without Docker** (use the original Python deployment method)

## Next Steps

1. Try the registry mirror configuration
2. If that doesn't work, use the local image transfer method
3. Consider using a different cloud provider or network configuration
4. Contact your network administrator if it's a corporate network issue

## Verification

After applying any solution, verify it works:

```bash
# Test Docker Hub access
docker pull hello-world

# Test your application image
docker pull jinggegeha/one-pipeline-demo:latest

# Run the Ansible playbook
ansible-playbook -i inventory.yml deploy.yml -e "target_host=8.136.4.119" -e "ssh_user=root"
``` 

## Solution: registry mirror configuration
https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors
