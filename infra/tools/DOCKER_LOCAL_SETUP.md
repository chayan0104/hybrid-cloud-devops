# Docker Local Development Setup

**Time to complete:** 5 minutes

Quick setup for local development with Docker Compose. Get the entire stack running on your machine.

## ✅ Prerequisites

```bash
# Install Docker Desktop (includes Docker Compose)
# https://www.docker.com/products/docker-desktop

# Verify installation
docker --version          # Docker 24+
docker compose version    # Docker Compose 2.20+
git --version            # Git 2.30+
```

## 🚀 Quick Start (5 Minutes)

### Step 1: Clone & Navigate (1 min)

```bash
git clone https://github.com/your-org/hybrid-cloud-devops.git
cd hybrid-cloud-devops/applications
```

### Step 2: Start Stack (2 min)

```bash
docker compose up -d --build
```

Wait for containers to be healthy:
```bash
docker compose ps
```

Expected output:
```
NAME                COMMAND                  STATUS
frontend            "nginx -g daemon off"   Up (healthy)
monolith            "java -jar ..."         Up (healthy)
microservice        "java -jar ..."         Up (healthy)
postgres            "docker-entrypoint..."  Up (healthy)
```

### Step 3: Verify Services (2 min)

```bash
# Frontend
curl http://localhost:9091
# Response: HTML page

# Monolith
curl http://localhost:9092/monolith/health
# Response: {"status":"UP"}

# Microservice
curl http://localhost:9093/microservice/actuator/health
# Response: {"status":"UP"}

# Database
docker compose exec postgres psql -U app_user -d app_db -c "SELECT COUNT(*) FROM customers;"
```

## 📖 Understanding the Stack

### Components

| Service | Type | Port | Technology | Purpose |
|---------|------|------|-----------|---------|
| **frontend** | SPA | 9091 | Angular + Nginx | User interface |
| **monolith** | App | 9092 | Java Spring | Main business logic |
| **microservice** | Service | 9093 | Spring Boot | Order/inventory service |
| **postgres** | Database | 5432 | PostgreSQL 15 | Persistent data |

### Architecture

```
┌─────────────────────────────────────────┐
│          User Browser (Localhost)       │
└──────────────────────────────────────────┘
   ↓ 9091           ↓ 9092           ↓ 9093
┌──────────┐    ┌─────────┐     ┌──────────┐
│ Frontend │    │ Monolith│     │Microserv │
│ (Nginx)  │    │ (Tomcat)│     │ (Spring) │
└──────────┘    └─────────┘     └──────────┘
   ↓                ↓                ↓
└─────────────────────────────────────────┘
           ↓ 5432
      ┌──────────────┐
      │ PostgreSQL   │
      └──────────────┘
```

## 📝 Common Tasks

### Check Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f microservice

# Recent 50 lines
docker compose logs -f --tail 50
```

### Execute Commands in Container

```bash
# Connect to database
docker compose exec postgres psql -U app_user -d app_db

# Query data
docker compose exec postgres psql -U app_user -d app_db -c "SELECT * FROM customers LIMIT 5;"

# Check application logs inside container
docker compose exec microservice cat /var/log/application.log
```

### Test APIs

```bash
# Get customer from monolith
curl http://localhost:9092/monolith/api/customer/1

# Get orders from microservice
curl http://localhost:9093/microservice/api/orders/1

# Cross-service call (aggregation)
curl http://localhost:9092/monolith/api/customer-summary/1

# Swagger documentation
open http://localhost:9092/monolith/swagger-ui.html
open http://localhost:9093/microservice/swagger-ui.html
```

### Rebuild Images

```bash
# Rebuild from scratch (clears cache)
docker compose up -d --build --force-recreate

# Rebuild only specific service
docker compose build frontend --no-cache
docker compose up -d frontend
```

### Scale Services

```bash
# Run 3 instances of microservice
docker compose up -d --scale microservice=3

# Check
docker compose ps
```

## 🧹 Cleanup

### Stop All Services

```bash
docker compose down
```

### Clean Everything (Remove volumes)

```bash
docker compose down -v
```

### Clean Up Disk Space

```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune
```

## 📊 Monitoring & Debugging

### View Real-time Stats

```bash
docker stats
```

### Inspect Container

```bash
# Get container details
docker inspect <container-id>

# Network inspection
docker network inspect bridge
```

### Enter Container Shell

```bash
docker compose exec microservice /bin/sh

# Inside container:
ps aux           # Process list
netstat -tlnp    # Port list
env              # Environment variables
```

## 🚨 Troubleshooting

### Port Already in Use

```bash
# Check what's using the port
lsof -i :9091

# Either kill the process or change docker-compose.yml port mapping
# Edit applications/docker-compose.yml:
# ports:
#   - "19091:8080"  # Changed from 9091
```

**Solution:**
```bash
# Kill conflicting process
kill -9 <PID>

# Or restart Docker
docker compose restart

# Or use different ports
docker compose -f docker-compose.yml -p myapp up -d
```

### Container Won't Start

```bash
# Check logs
docker compose logs <service>

# Rebuild
docker compose build <service> --no-cache

# Restart
docker compose restart <service>
```

### Health Check Failing

```bash
# Check if service is responding
docker compose exec microservice curl http://localhost:8081/microservice/actuator/health

# View health check configuration
docker compose config | grep -A 10 "healthcheck"

# Manually test
curl http://localhost:9093/microservice/actuator/health
```

### Out of Disk Space

```bash
# Check usage
docker system df

# Clean up
docker system prune -a --volumes

# On Windows/Mac (WSL):
wsl --manage Docker-Desktop --compact
```

### Database Connection Issues

```bash
# Test PostgreSQL connectivity
docker compose exec postgres pg_isready

# Check database exists
docker compose exec postgres psql -U app_user -l

# Test from application
docker compose exec microservice sh -c 'nc -zv postgres 5432'
```

### Memory/CPU Issues

```bash
# View resource usage
docker stats --no-stream

# Limit resources (edit docker-compose.yml)
# services:
#   microservice:
#     deploy:
#       resources:
#         limits:
#           cpus: '0.5'
#           memory: 512M
#         reservations:
#           cpus: '0.25'
#           memory: 256M
```

## 📚 Next Steps

### 1. Explore Application Code

```bash
# Frontend (Angular)
code applications/frontend-angular/

# Monolith (Java)
code applications/monolith/

# Microservice (Spring Boot)
code applications/microservice/
```

### 2. Modify and Test

```bash
# Edit code
# Rebuild and test
docker compose build <service>
docker compose up -d <service>

# Verify
curl http://localhost:9093/microservice/health
```

### 3. Learn More

- [Project README](../../README.md)
- [Architecture](../../docs/ARCHITECTURE.md)
- [Full Setup Guide](../../docs/SETUP-AND-DEPLOYMENT-GUIDE.md)

### 4. Deploy to UAT/PROD

When ready to deploy beyond local:
→ [UAT_SETUP.md](UAT_SETUP.md) - Deploy to Kubernetes

## ✅ Validation Checklist

- [ ] Docker Desktop installed and running
- [ ] `docker compose up -d --build` completes without errors
- [ ] All containers show "healthy" status
- [ ] Frontend accessible at http://localhost:9091
- [ ] Monolith responds at http://localhost:9092/monolith/health
- [ ] Microservice responds at http://localhost:9093/microservice/actuator/health
- [ ] Database queries work: `docker compose exec postgres psql -U app_user -d app_db -c "SELECT 1"`
- [ ] Can execute API calls successfully

---

**Ready for next steps?** → [UAT_SETUP.md](UAT_SETUP.md)

**Having issues?** → [TROUBLESHOOTING_TOOLS.md](TROUBLESHOOTING_TOOLS.md)
