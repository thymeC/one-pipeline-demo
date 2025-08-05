# Docker-Based Deployment with Ansible

This directory contains the Ansible playbook and configuration files for deploying the FastAPI application using Docker containers.

## Changes Made

### 1. Updated `deploy.yml`
- **Removed**: Python virtual environment setup, manual artifact download from Nexus
- **Added**: Docker installation and configuration
- **Changed**: Deployment method from direct Python execution to Docker container

### 2. Key Features
- **Docker Installation**: Automatically installs Docker CE on Ubuntu servers
- **Image Pulling**: Downloads the latest Docker image from Docker Hub
- **Container Management**: Stops old containers, pulls new images, starts new containers
- **Environment Variables**: Passes deployment information to containers
- **Health Checks**: Verifies application is running after deployment

### 3. Variables
- `docker_image`: Docker Hub image name (default: `jinggegeha/one-pipeline-demo`)
- `docker_tag`: Image tag (default: `latest` or build number)
- `app_port`: Port for the application (default: 8000)
- `deployment_time`: Timestamp of deployment

### 4. Updated Nginx Configuration
- **Health Check**: Updated to use `/health` endpoint
- **API Routes**: Added `/api/` proxy configuration
- **Docker Integration**: Configured to proxy to Docker container

### 5. GitHub Actions Integration
- **Docker Image**: Passes `IMAGE_NAME` from CI/CD pipeline
- **Build Number**: Uses GitHub run number as Docker tag
- **Health Check**: Updated to use correct endpoint

## Usage

### Manual Deployment
```bash
cd deploy
ansible-playbook -i inventory.yml deploy.yml \
  -e "docker_image=your-username/your-app" \
  -e "build_number=latest" \
  -e "deployment_time=$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
```

### Automated Deployment
The GitHub Actions workflow automatically:
1. Builds and pushes Docker image to Docker Hub
2. Runs Ansible playbook with correct parameters
3. Performs health checks

## Requirements

### Target Server
- Ubuntu 18.04+ (for Docker installation)
- SSH access with sudo privileges
- Internet connectivity for Docker Hub

### Ansible
- `docker` module (included in Ansible 2.8+)
- SSH access to target servers

## Benefits

1. **Consistency**: Same container runs everywhere
2. **Isolation**: Application runs in isolated environment
3. **Rollback**: Easy to rollback to previous image versions
4. **Scalability**: Easy to scale horizontally
5. **Maintenance**: No need to manage Python dependencies on server 