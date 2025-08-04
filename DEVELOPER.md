# Developer Guide

This guide provides comprehensive information for developers working on the HSBC Pipeline Demo project.

## Table of Contents

- [Quick Start](#quick-start)
- [Running GitHub Workflows Locally](#running-github-workflows-locally)
- [Development Setup](#development-setup)
- [Testing](#testing)
- [Code Quality](#code-quality)
- [Docker](#docker)
- [CI/CD Pipeline](#cicd-pipeline)
- [Troubleshooting](#troubleshooting)

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd one-pipeline-demo
   ```

2. **Set up virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   pip install pytest pytest-asyncio httpx flake8 black
   ```

4. **Run the application**
   ```bash
   python main.py
   ```

5. **Run tests**
   ```bash
   python -m pytest tests/ -v
   ```

## Running GitHub Workflows Locally

### Why Run Workflows Locally?

- **Faster feedback**: No need to push to GitHub to see if your code works
- **Cost savings**: Avoid using GitHub Actions minutes for testing
- **Debugging**: Easier to debug issues locally
- **Confidence**: Ensure your code will pass CI before pushing

### Method 1: Using `act` (Full Workflow Simulation)

[`act`](https://github.com/nektos/act) is a tool that runs your GitHub Actions locally using Docker.

#### Installation
```bash
# macOS
brew install act

# Linux
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Windows
choco install act-cli
```

#### Usage
```bash
# List available workflows
act --list

# Run specific job
act -W .github/workflows/ci-cd.yml -j test

# Run all jobs
act -W .github/workflows/ci-cd.yml

# Run with specific event
act push
```

#### Configuration
Create `~/.actrc` (Linux/macOS) or `%USERPROFILE%\.actrc` (Windows):
```
-P ubuntu-latest=catthehacker/ubuntu:act-latest
--container-architecture linux/amd64
```

### Method 2: Manual Step-by-Step (Recommended)

Run the equivalent steps manually:

```bash
# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
pip install pytest pytest-asyncio httpx flake8 black

# Run tests
python -m pytest tests/ -v

# Run linting
flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics

# Run formatting check
black . --check
```

### Method 3: Using Provided Scripts

#### Test Workflow Script
```bash
./run_workflow_local.sh
```

This script runs the equivalent of your `test` job:
- Installs dependencies
- Runs pytest tests
- Runs flake8 linting
- Runs black formatting check

#### Docker Build Script
```bash
./run_docker_build_local.sh
```

This script runs the equivalent of your `build` job:
- Builds Docker image
- Tags it appropriately
- Shows build results

## Development Setup

### Prerequisites

- Python 3.9+
- Docker (for containerization)
- Git

### Environment Variables

Create a `.env` file for local development:
```env
ENVIRONMENT=development
PORT=8000
HOST=0.0.0.0
```

### IDE Configuration

#### VS Code Settings
Create `.vscode/settings.json`:
```json
{
    "python.defaultInterpreterPath": "./venv/bin/python",
    "python.linting.enabled": true,
    "python.linting.flake8Enabled": true,
    "python.formatting.provider": "black",
    "python.testing.pytestEnabled": true,
    "python.testing.pytestArgs": ["tests"]
}
```

## Testing

### Running Tests

```bash
# Run all tests
python -m pytest tests/ -v

# Run specific test file
python -m pytest tests/test_main.py -v

# Run with coverage
python -m pytest tests/ --cov=main --cov-report=html

# Run tests in parallel
python -m pytest tests/ -n auto
```

### Test Structure

```
tests/
├── test_main.py          # Main application tests
├── conftest.py           # Pytest configuration (if needed)
└── __init__.py
```

### Writing Tests

Follow these guidelines:
- Use descriptive test names
- Test both success and failure cases
- Use fixtures for common setup
- Mock external dependencies

Example:
```python
def test_create_item_success():
    """Test successful item creation"""
    item_data = {"name": "Test Item", "price": 29.99}
    response = client.post("/items", json=item_data)
    assert response.status_code == 200
    assert response.json()["name"] == item_data["name"]
```

## Code Quality

### Linting

We use `flake8` for linting with custom configuration in `.flake8`:

```ini
[flake8]
exclude = 
    venv/,
    .venv/,
    __pycache__/,
    .git/,
    .pytest_cache/,
    *.egg-info/
max-line-length = 88
extend-ignore = E203, W503
```

Run linting:
```bash
flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
```

### Code Formatting

We use `black` for code formatting:

```bash
# Check formatting
black . --check

# Format code
black .
```

### Pre-commit Hooks

Consider setting up pre-commit hooks:

```bash
pip install pre-commit
pre-commit install
```

Create `.pre-commit-config.yaml`:
```yaml
repos:
  - repo: https://github.com/psf/black
    rev: 23.3.0
    hooks:
      - id: black
  - repo: https://github.com/pycqa/flake8
    rev: 6.0.0
    hooks:
      - id: flake8
```

## Docker

### Building Images

```bash
# Build image
docker build -t jinggegeha/one-pipeline-demo .

# Run container
docker run -p 8000:8000 jinggegeha/one-pipeline-demo

# Run with environment variables
docker run -p 8000:8000 -e ENVIRONMENT=production jinggegeha/one-pipeline-demo
```

### Docker Compose

Create `docker-compose.yml` for local development:
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "8000:8000"
    environment:
      - ENVIRONMENT=development
    volumes:
      - .:/app
```

## CI/CD Pipeline

### Workflow Overview

Our CI/CD pipeline consists of three main jobs:

1. **Test Job**: Runs tests, linting, and formatting checks
2. **Build Job**: Builds and pushes Docker images to Docker Hub
3. **Deploy Job**: Deploys the application using Ansible

### Workflow Triggers

- **Push to main/develop**: Runs full pipeline
- **Pull Request**: Runs test job only

### Environment Variables

Set these secrets in your GitHub repository:

- `DOCKERHUB_USERNAME`: Your Docker Hub username
- `DOCKERHUB_TOKEN`: Your Docker Hub access token
- `SSH_PRIVATE_KEY`: SSH key for deployment
- `TARGET_HOST`: Target server hostname

### Local Testing

Before pushing, always run:
```bash
./run_workflow_local.sh
```

This ensures your code will pass CI checks.

## Troubleshooting

### Common Issues

#### 1. Virtual Environment Issues
```bash
# Recreate virtual environment
rm -rf venv
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

#### 2. Docker Build Issues
```bash
# Clean Docker cache
docker system prune -a

# Rebuild without cache
docker build --no-cache -t jinggegeha/one-pipeline-demo .

# If you get timeout errors, try pulling the base image first
docker pull python:3.11-slim

# Then build your image
docker build -t jinggegeha/one-pipeline-demo .

# For network timeout issues, try using host network
docker build --network=host -t jinggegeha/one-pipeline-demo .
```

#### 3. Test Failures
```bash
# Run tests with verbose output
python -m pytest tests/ -v -s

# Run specific failing test
python -m pytest tests/test_main.py::test_specific_function -v
```

#### 4. Linting Issues
```bash
# Auto-fix formatting
black .

# Check specific files
flake8 main.py tests/test_main.py
```

### Getting Help

1. Check the logs in GitHub Actions
2. Run workflows locally to debug
3. Check the troubleshooting section above
4. Create an issue with detailed error information

### Docker Timeout Issues

If you encounter `DeadlineExceeded` or `i/o timeout` errors when building Docker images:

1. **Check Docker login status**:
   ```bash
   docker login
   ```

2. **Pull base images manually**:
   ```bash
   docker pull python:3.11-slim
   ```

3. **Use host network**:
   ```bash
   docker build --network=host -t your-image-name .
   ```

4. **Increase Docker timeout** (if using Docker Desktop):
   - Go to Docker Desktop → Settings → Resources
   - Increase memory and CPU allocation
   - Restart Docker Desktop

5. **Check network connectivity**:
   ```bash
   ping docker.io
   curl -I https://auth.docker.io
   ```

## Best Practices

### Code Style
- Follow PEP 8 guidelines
- Use type hints
- Write docstrings for functions and classes
- Keep functions small and focused

### Git Workflow
- Use descriptive commit messages
- Create feature branches for new work
- Test locally before pushing
- Use pull requests for code review

### Testing
- Write tests for new features
- Maintain high test coverage
- Use meaningful test names
- Test edge cases and error conditions

### Documentation
- Keep README.md updated
- Document API changes
- Update this DEVELOPER.md as needed
- Add inline comments for complex logic

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests locally
5. Submit a pull request

For more information, see the main README.md file. 