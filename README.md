# HSBC Pipeline Demo - FastAPI Application

A comprehensive FastAPI application with CI/CD pipeline using GitHub Actions and Ansible for deployment to Nexus.

## Features

- **FastAPI Application**: Modern, fast web framework for building APIs
- **Docker Support**: Containerized application with multi-stage builds
- **CI/CD Pipeline**: Automated testing, building, and deployment
- **Nexus Integration**: Artifact storage and Docker registry
- **Ansible Deployment**: Infrastructure as Code for consistent deployments
- **Nginx Reverse Proxy**: Production-ready web server configuration
- **Systemd Service**: Managed application lifecycle
- **Health Checks**: Application monitoring and status endpoints
- **Comprehensive Testing**: Unit tests with pytest

## API Endpoints

### Core Endpoints
- `GET /api/v1/` - Application information and documentation links
- `GET /api/v1/health` - Health check endpoint
- `GET /api/v1/info` - Application metadata and environment info
- `GET /api/v1/stats` - Application statistics

### Items Management
- `GET /api/v1/items` - List all items (with pagination)
- `GET /api/v1/items/{item_id}` - Get specific item
- `POST /api/v1/items` - Create new item
- `PUT /api/v1/items/{item_id}` - Update existing item
- `DELETE /api/v1/items/{item_id}` - Delete item
- `GET /api/v1/items/search/{query}` - Search items by name or description

### Interactive Documentation
- `GET /docs` - Swagger UI documentation
- `GET /redoc` - ReDoc documentation

## Quick Start

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd hsbc-pipeline-demo
   ```

2. **Set up virtual environment**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application**
   ```bash
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

5. **Access the application**
   - API: http://localhost:8000
   - Documentation: http://localhost:8000/docs

### Docker Development

1. **Build the image**
   ```bash
   docker build -t hsbc-pipeline-demo .
   ```

2. **Run the container**
   ```bash
   docker run -p 8000:8000 hsbc-pipeline-demo
   ```

## Testing

### Run Tests
```bash
# Install test dependencies
pip install pytest pytest-asyncio httpx

# Run all tests
pytest

# Run with coverage
pytest --cov=main tests/
```

### Test API Endpoints
```bash
# Health check
curl http://localhost:8000/api/v1/health

# Create an item
curl -X POST http://localhost:8000/api/v1/items \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Item", "price": 29.99}'

# Get all items
curl http://localhost:8000/api/v1/items

# Search items
curl http://localhost:8000/api/v1/items/search/phone

# Get application stats
curl http://localhost:8000/api/v1/stats
```

## Deployment

### Prerequisites

1. **Nexus Repository Manager**
   - Docker registry configured
   - Raw repository for artifacts
   - User credentials with appropriate permissions

2. **Target Server**
   - Ubuntu 20.04+ or similar Linux distribution
   - SSH access with key-based authentication
   - Python 3.8+ installed

3. **GitHub Secrets**
   Configure the following secrets in your GitHub repository:
   - `NEXUS_USERNAME`: Nexus username
   - `NEXUS_PASSWORD`: Nexus password
   - `SSH_PRIVATE_KEY`: SSH private key for target server
   - `TARGET_HOST`: Target server IP/hostname

### Configuration

1. **Update GitHub Actions Variables**
   Edit `.github/workflows/ci-cd.yml`:
   ```yaml
   env:
     REGISTRY: your-nexus-registry.com
     IMAGE_NAME: hsbc-pipeline-demo
     NEXUS_REPOSITORY: your-repository-name
   ```

2. **Update Ansible Inventory**
   Edit `deploy/inventory.yml` with your server details:
   ```yaml
   ansible_host: "your-server-ip"
   ansible_user: "your-ssh-user"
   ```

### Deployment Process

The CI/CD pipeline automatically:

1. **Tests**: Runs unit tests and linting
2. **Builds**: Creates Docker image and application artifact
3. **Publishes**: Uploads to Nexus registry and repository
4. **Deploys**: Uses Ansible to deploy to target server
5. **Verifies**: Performs health checks

### Manual Deployment

If you need to deploy manually:

```bash
# Build and push to Nexus
docker build -t your-nexus-registry.com/hsbc-pipeline-demo .
docker push your-nexus-registry.com/hsbc-pipeline-demo

# Deploy with Ansible
cd deploy
ansible-playbook -i inventory.yml deploy.yml \
  -e "nexus_url=your-nexus-registry.com" \
  -e "repository_name=your-repository-name" \
  -e "build_number=manual-$(date +%Y%m%d-%H%M%S)"
```

## Architecture

### Application Architecture
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Nginx     │───▶│  FastAPI    │───▶│  Systemd    │
│  (Port 80)  │    │ (Port 8000) │    │   Service   │
└─────────────┘    └─────────────┘    └─────────────┘
```

### Code Architecture
```
┌─────────────────┐
│     main.py     │  ← Application entry point
├─────────────────┤
│  app/api/       │  ← API route handlers
│  └─ routes.py   │
├─────────────────┤
│  app/database.py│  ← Data operations
├─────────────────┤
│  app/models.py  │  ← Pydantic models
├─────────────────┤
│  app/config.py  │  ← Configuration
└─────────────────┘
```

### Key Features
- **Modular Design**: Separated concerns with dedicated modules
- **Clean Architecture**: Application code organized in `app/` package
- **Configuration Management**: Centralized settings with environment support
- **Data Validation**: Comprehensive Pydantic models with validation
- **API Versioning**: Versioned API endpoints (/api/v1/)
- **Error Handling**: Standardized error responses
- **Health Monitoring**: Built-in health checks and statistics
- **Search Functionality**: Item search by name or description
- **Pagination**: Support for large datasets

### Benefits of App Structure
- **Separation of Concerns**: Application logic separated from configuration/deployment
- **Scalability**: Easy to add new modules and features
- **Maintainability**: Clear organization makes code easier to understand
- **Testing**: Isolated components are easier to test
- **Deployment**: Clean separation between app code and infrastructure

### Directory Structure
```
hsbc-pipeline-demo/
├── main.py                 # FastAPI application entry point
├── app/                    # Application package
│   ├── __init__.py
│   ├── config.py          # Application configuration
│   ├── models.py          # Pydantic data models
│   ├── database.py        # Database operations
│   └── api/               # API routes module
│       ├── __init__.py
│       └── routes.py      # API route handlers
├── requirements.txt        # Python dependencies
├── Dockerfile             # Docker configuration
├── pytest.ini            # Test configuration
├── tests/                 # Test files
│   └── test_main.py
├── .github/
│   └── workflows/
│       └── ci-cd.yml      # GitHub Actions workflow
├── deploy/                # Deployment files
│   ├── deploy.yml         # Ansible playbook
│   ├── inventory.yml      # Ansible inventory
│   └── templates/         # Ansible templates
│       ├── env.j2
│       ├── fastapi.service.j2
│       └── nginx.conf.j2
└── README.md
```

## Monitoring and Logs

### Application Logs
```bash
# View application logs
sudo journalctl -u hsbc-pipeline-demo -f

# View Nginx logs
sudo tail -f /var/log/nginx/hsbc-pipeline-demo_access.log
sudo tail -f /var/log/nginx/hsbc-pipeline-demo_error.log
```

### Health Monitoring
```bash
# Check application status
curl http://your-server/api/v1/health

# Check service status
sudo systemctl status hsbc-pipeline-demo
```

## Security Considerations

- Application runs as non-root user
- Nginx provides rate limiting and security headers
- Systemd service includes security restrictions
- SSH key-based authentication required
- Environment variables for sensitive configuration

## Troubleshooting

### Common Issues

1. **Application won't start**
   ```bash
   sudo systemctl status hsbc-pipeline-demo
   sudo journalctl -u hsbc-pipeline-demo -n 50
   ```

2. **Nginx configuration issues**
   ```bash
   sudo nginx -t
   sudo systemctl status nginx
   ```

3. **Permission issues**
   ```bash
   sudo chown -R fastapi:fastapi /opt/hsbc-pipeline-demo
   ```

### Debug Mode
```bash
# Run application in debug mode
cd /opt/hsbc-pipeline-demo
source venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 8000 --log-level debug
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 