# Production-Grade Kubernetes Manifests

**Location:** `k8s/`

## Overview

This directory contains production-ready Kubernetes manifests for the hybrid cloud application stack with advanced features including:

- ✅ **Resource Management**: CPU/memory requests & limits with realistic values
- ✅ **Security**: Network policies, RBAC, pod security contexts, seccomp
- ✅ **High Availability**: Pod affinity rules, disruption budgets, multi-replica deployments
- ✅ **Observability**: ServiceMonitor, PrometheusRules, health checks
- ✅ **Deployment Strategies**: Canary, Blue-Green, Rolling updates
- ✅ **Autoscaling**: HPA with CPU & memory metrics, optional VPA
- ✅ **Database**: PostgreSQL with persistent storage and health checks

## Directory Structure

```
k8s/
├── namespace.yaml              # Namespace + ResourceQuota + NetworkPolicies + RBAC
├── configmap.yaml              # Consolidated ConfigMaps (app-wide settings)
├── secrets.yaml                # Secret templates with placeholders (DB credentials)
├── ingress.yaml                # NGINX ingress with TLS termination
│
├── postgres/
│   ├── pvc.yaml               # 20Gi PersistentVolumeClaim
│   └── deployment.yaml        # PostgreSQL 15 + Service + PDB
│
├── frontend/
│   ├── deployment.yaml        # Angular/Nginx (3 replicas + PDB)
│   └── service.yaml           # ClusterIP service
│
├── monolith/
│   ├── deployment.yaml        # Java WAR (3 replicas + PDB)
│   └── service.yaml           # ClusterIP service
│
├── microservice/
│   ├── deployment.yaml        # Spring Boot (3-10 replicas via HPA + VPA + PDB)
│   └── service.yaml           # ClusterIP service
│
├── strategies/
│   ├── canary-deployment.yaml        # Canary: 1 replica, separate service
│   └── blue-green-deployment.yaml    # Blue (active) & Green (standby) deployments
│
├── monitoring/
│   └── prometheus-rules.yaml        # ServiceMonitor + PrometheusRules for alerts
│
└── README.md                   # This file
```

## Key Improvements Over Legacy infra/kubernetes/

| Feature | Old (infra/kubernetes/) | New (k8s/) |
|---------|-------------------------|-----------|
| **Namespace Strategy** | Environment-specific (enterprise-uat, enterprise-prod, enterprise-perf-prod) | Unified (enterprise-app) with template placeholders |
| **Resource Management** | Basic requests/limits | Realistic CPU/memory + burstable limits |
| **Security** | Basic securityContext | Full RBAC, NetworkPolicies, seccomp, FSGroup |
| **High Availability** | Replicas only | Replicas + PodDisruptionBudgets + Affinity rules |
| **Health Checks** | Readiness + Liveness | Readiness + Liveness + Startup probes |
| **Observability** | Manual scraping | ServiceMonitor + PrometheusRules + Alerts |
| **Pod Anti-Affinity** | None | Prefer spread across nodes |
| **Temporary Storage** | Not managed | EmptyDir volumes with size limits |
| **Startup Probe** | None | 30 retries × 10s for slow startups |
| **VPA (Vertical Autoscaler)** | N/A | Optional VPA for microservice |
| **Graceful Shutdown** | 30s | 30s + preStop hooks (optional) |
| **Init Scripts** | Direct mount | ConfigMap mount with proper permissions |

## Namespace Architecture

The `enterprise-app` namespace includes:

1. **ResourceQuota**: Limits total CPU/memory consumption
2. **NetworkPolicy**: Default deny + allow from ingress controller
3. **ServiceAccount**: Single SA for all workloads (RBAC-controlled)
4. **RBAC Role/RoleBinding**: Read access to ConfigMaps, Secrets, and Pods

### Apply Namespace + Security Foundation
```bash
kubectl apply -f k8s/namespace.yaml
# Creates: Namespace, ResourceQuota, NetworkPolicies, ServiceAccount, RBAC
```

## ConfigMap & Secrets Strategy

### ConfigMap (k8s/configmap.yaml)

Contains non-sensitive app configuration consolidated across all services:

```yaml
# app-config: Global app settings
# microservice-config: Microservice-specific settings
# monolith-config: Monolith-specific settings
```

**Apply:**
```bash
kubectl apply -f k8s/configmap.yaml
```

### Secrets (k8s/secrets.yaml)

Template with placeholders for sensitive data (DB credentials, API keys):

```yaml
# Placeholders: __DB_HOST__, __DB_PORT__, __DB_NAME__, __DB_USER__, __DB_PASSWORD__
```

**Render with Jenkins & Apply:**
```bash
# Substitute real values during CI/CD pipeline
sed -e "s|__DB_HOST__|postgres.enterprise-app.svc.cluster.local|g" \
    -e "s|__DB_PORT__|5432|g" \
    -e "s|__DB_NAME__|app_db|g" \
    -e "s|__DB_USER__|postgres|g" \
    -e "s|__DB_PASSWORD__|your_secure_password|g" \
    k8s/secrets.yaml | kubectl apply -f -
```

## Component Deployments

### PostgreSQL (k8s/postgres/deployment.yaml)

**Features:**
- Single replica (Recreate strategy for consistency)
- 20Gi persistent volume for data durability
- Health checks with `pg_isready`
- Init scripts mounted from ConfigMap
- Resource requests: 250m CPU / 512Mi memory
- Headless service for stable DNS
- PodDisruptionBudget prevents eviction

**Deploy:**
```bash
kubectl apply -f k8s/postgres/pvc.yaml
kubectl apply -f k8s/postgres/deployment.yaml
```

**Verify:**
```bash
kubectl get pvc -n enterprise-app
kubectl exec -it deployment/postgres -n enterprise-app -- psql -U postgres
```

### Frontend (k8s/frontend/deployment.yaml)

**Features:**
- 3 replicas (rolling updates, max surge=1)
- Pod anti-affinity (prefer spread across nodes)
- Health checks: readiness (10s initial, 5s period), liveness (15s initial, 10s period)
- EmptyDir volumes for /tmp and cache
- Resource requests: 100m CPU / 128Mi memory
- PodDisruptionBudget (minAvailable: 2 for HA)
- Read-only root filesystem for security

**Deploy:**
```bash
sed "s|__FRONTEND_IMAGE__|registry.io/frontend:v1.0|g" k8s/frontend/deployment.yaml | kubectl apply -f -
```

### Monolith (k8s/monolith/deployment.yaml)

**Features:**
- 3 replicas with RollingUpdate strategy
- Pod anti-affinity + preferred affinity to postgres
- Startup probe for slow app initialization (30 retries)
- JAVA_OPTS tuning for JVM performance
- Resource requests: 250m CPU / 512Mi memory
- Prometheus metrics scraping enabled
- PodDisruptionBudget (minAvailable: 2)

**Deploy:**
```bash
sed "s|__MONOLITH_IMAGE__|registry.io/monolith:v1.0|g" k8s/monolith/deployment.yaml | kubectl apply -f -
```

### Microservice (k8s/microservice/deployment.yaml)

**Features:**
- 3 replicas (stable track)
- **HPA v2**: Scales 3-10 replicas based on CPU (70%) & memory (80%)
- **VPA (optional)**: Recommends optimal CPU/memory
- Pod anti-affinity to spread replicas
- Startup probe for Spring Boot initialization
- Prometheus metrics at `/microservice/actuator/prometheus`
- Spring profiles: prod + environment-specific
- PodDisruptionBudget (minAvailable: 2)
- Graceful shutdown: 30s termination grace period

**Deploy:**
```bash
sed "s|__MICROSERVICE_IMAGE__|registry.io/microservice:v1.0|g" k8s/microservice/deployment.yaml | kubectl apply -f -
kubectl get hpa -n enterprise-app microservice-hpa -w
```

**Monitor HPA:**
```bash
kubectl top pods -n enterprise-app
kubectl describe hpa microservice-hpa -n enterprise-app
```

## Deployment Strategies

### Rolling Updates (Default)

All deployments use RollingUpdate with controlled rollout:

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0  # Zero downtime
    maxSurge: 1        # One extra pod during update
```

**Apply new image:**
```bash
kubectl set image deployment/microservice microservice=registry.io/microservice:v1.1 -n enterprise-app
kubectl rollout status deployment/microservice -n enterprise-app
```

### Canary Deployment (k8s/strategies/canary-deployment.yaml)

**Process:**
1. Deploy canary (1 replica) with new version
2. Route small % traffic to canary service
3. Monitor metrics for errors/latency
4. Promote stable if canary is healthy

**Deploy Canary:**
```bash
sed "s|__MICROSERVICE_IMAGE_CANARY__|registry.io/microservice:v1.1-canary|g" \
  k8s/strategies/canary-deployment.yaml | kubectl apply -f -

kubectl scale deployment/microservice-canary --replicas=1 -n enterprise-app
kubectl get pods -n enterprise-app -l track=canary
```

**Promote to Stable:**
```bash
# Update stable deployment with canary image
kubectl set image deployment/microservice microservice=registry.io/microservice:v1.1 -n enterprise-app

# Scale down canary
kubectl scale deployment/microservice-canary --replicas=0 -n enterprise-app
```

### Blue-Green Deployment (k8s/strategies/blue-green-deployment.yaml)

**Process:**
1. Blue = current version (2 replicas, active)
2. Green = new version (0 replicas, standby)
3. Deploy Green with new image
4. Switch service selector from blue → green
5. Keep Blue for instant rollback

**Deploy Green:**
```bash
sed "s|__MICROSERVICE_IMAGE_GREEN__|registry.io/microservice:v1.1|g" \
  k8s/strategies/blue-green-deployment.yaml | kubectl apply -f -

# Scale green replicas
kubectl scale deployment/microservice-green --replicas=2 -n enterprise-app

# Wait for green to be ready
kubectl get deployment microservice-green -n enterprise-app -w
```

**Switch Traffic to Green:**
```bash
# Edit microservice-active service selector
kubectl patch service microservice-active -n enterprise-app --type merge -p '{"spec":{"selector":{"slot":"green"}}}'
```

**Rollback to Blue:**
```bash
kubectl patch service microservice-active -n enterprise-app --type merge -p '{"spec":{"selector":{"slot":"blue"}}}'
kubectl scale deployment/microservice-green --replicas=0 -n enterprise-app
```

## Autoscaling

### Horizontal Pod Autoscaler (HPA)

Microservice scales automatically based on metrics:

```yaml
minReplicas: 3
maxReplicas: 10
metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        averageUtilization: 80
```

**Monitor HPA:**
```bash
kubectl get hpa -n enterprise-app
kubectl top nodes
kubectl top pods -n enterprise-app
```

### Vertical Pod Autoscaler (VPA - Optional)

VPA recommends CPU/memory without restarting pods (set to `Off` mode):

```yaml
updatePolicy:
  updateMode: "Off"  # Change to "Auto" for automatic updates
```

**Enable VPA (requires VPA addon):**
```bash
helm repo add fairwinds-stable https://charts.fairwinds.com/stable
helm install vpa fairwinds-stable/vpa --namespace kube-system
```

## Observability & Monitoring

### ServiceMonitor (k8s/monitoring/prometheus-rules.yaml)

Scrapes Prometheus metrics from applications:

```bash
# Requires Prometheus Operator
kubectl apply -f k8s/monitoring/prometheus-rules.yaml
```

**Verify metrics scraped:**
```bash
# Port-forward to Prometheus
kubectl port-forward -n prometheus svc/prometheus 9090:9090

# Query: up{job="microservice"} or up{job="monolith"}
```

### PrometheusRules & Alerts

Pre-configured alerts for:
- High error rate (>5% for 5m)
- High latency (P95 > 1s)
- Replica count < expected
- High CPU/memory usage (>80%)
- PostgreSQL unavailable

**View Alerts:**
```bash
kubectl get PrometheusRule -n enterprise-app
kubectl describe PrometheusRule enterprise-app-alerts -n enterprise-app
```

### Pod Logs

```bash
# Follow logs
kubectl logs -f deployment/microservice -n enterprise-app --all-containers=true

# Previous pod logs (crashed pod)
kubectl logs deployment/microservice -n enterprise-app --previous

# Logs from all microservice replicas
kubectl logs -l app=microservice -n enterprise-app --all-containers=true -f
```

### Pod Events

```bash
kubectl describe pod <pod-name> -n enterprise-app
kubectl get events -n enterprise-app --sort-by='.lastTimestamp' -w
```

## Deployment Commands

### Deploy All Components

```bash
# 1. Apply namespace + security foundation
kubectl apply -f k8s/namespace.yaml

# 2. Apply configs and secrets (with template substitution in CI/CD)
kubectl apply -f k8s/configmap.yaml
sed -e "s|__DB_HOST__|postgres.enterprise-app.svc.cluster.local|g" \
    -e "s|__DB_PASSWORD__|your_secure_password|g" \
    k8s/secrets.yaml | kubectl apply -f -

# 3. Apply ingress
kubectl apply -f k8s/ingress.yaml

# 4. Deploy PostgreSQL
kubectl apply -f k8s/postgres/

# 5. Deploy frontend, monolith, microservice (with image substitution)
for SERVICE in frontend monolith microservice; do
  sed "s|__${SERVICE^^}_IMAGE__|registry.io/${SERVICE}:v1.0|g" \
    k8s/${SERVICE}/deployment.yaml | kubectl apply -f -
  kubectl apply -f k8s/${SERVICE}/service.yaml
done

# 6. Deploy monitoring (requires Prometheus Operator)
kubectl apply -f k8s/monitoring/prometheus-rules.yaml
```

### Verify Deployments

```bash
# Check all resources
kubectl get all -n enterprise-app

# Check rollout status
kubectl rollout status deployment/frontend -n enterprise-app
kubectl rollout status deployment/monolith -n enterprise-app
kubectl rollout status deployment/microservice -n enterprise-app
kubectl rollout status deployment/postgres -n enterprise-app

# Check PVCs
kubectl get pvc -n enterprise-app

# Check HPA status
kubectl get hpa -n enterprise-app

# Check pod disruption budgets
kubectl get pdb -n enterprise-app

# Check network policies
kubectl get networkpolicies -n enterprise-app

# Check RBAC
kubectl get sa,role,rolebinding -n enterprise-app
```

### Quick Troubleshooting

```bash
# Check pod status and events
kubectl describe pod <pod-name> -n enterprise-app

# Get detailed pod info
kubectl get pods -n enterprise-app -o wide

# Check resource usage
kubectl top pods -n enterprise-app --containers
kubectl top nodes

# Check ingress status
kubectl get ingress -n enterprise-app -o wide
kubectl describe ingress app-ingress -n enterprise-app

# Port forward for local testing
kubectl port-forward -n enterprise-app svc/frontend 8080:80
kubectl port-forward -n enterprise-app svc/microservice 8081:80
kubectl port-forward -n enterprise-app svc/monolith 8082:80
kubectl port-forward -n enterprise-app svc/postgres 5432:5432
```

### Scaling

```bash
# Manual scaling
kubectl scale deployment/frontend --replicas=5 -n enterprise-app

# View HPA-managed scaling
kubectl get hpa microservice-hpa -n enterprise-app -w

# Update HPA limits
kubectl patch hpa microservice-hpa -n enterprise-app --type merge -p '{"spec":{"maxReplicas":15}}'
```

### Updates & Rollbacks

```bash
# Rolling update
kubectl set image deployment/microservice microservice=registry.io/microservice:v1.1 -n enterprise-app

# Watch rollout
kubectl rollout status deployment/microservice -n enterprise-app -w

# Undo last rollout
kubectl rollout undo deployment/microservice -n enterprise-app

# View rollout history
kubectl rollout history deployment/microservice -n enterprise-app
```

## Resource Estimates

### CPU/Memory Requests (total for 1 replica of each)

| Component | CPU Request | Memory Request |
|-----------|-------------|----------------|
| Frontend | 100m | 128Mi |
| Monolith | 250m | 512Mi |
| Microservice | 250m | 512Mi |
| PostgreSQL | 250m | 512Mi |
| **Total** | **850m** | **1664Mi** |

### At Full Scale (Frontend: 3, Monolith: 3, Microservice: 10, PostgreSQL: 1)

| Component | Replicas | Total CPU | Total Memory |
|-----------|----------|-----------|--------------|
| Frontend | 3 | 300m | 384Mi |
| Monolith | 3 | 750m | 1536Mi |
| Microservice | 10 | 2500m | 5120Mi |
| PostgreSQL | 1 | 250m | 512Mi |
| **Grand Total** | **17** | **3800m** | **7552Mi** |

Recommended cluster: **4-5 nodes** with 2 CPUs / 4GB RAM each (oversubscription + buffer).

## Production Checklist

- [x] Namespace with ResourceQuota
- [x] NetworkPolicies (deny by default)
- [x] RBAC (ServiceAccount + Roles)
- [x] Pod security contexts (non-root, capabilities dropped)
- [x] Resource requests & limits
- [x] Health checks (readiness + liveness + startup)
- [x] Pod anti-affinity & affinity rules
- [x] PodDisruptionBudgets (HA protection)
- [x] Persistent storage (PostgreSQL)
- [x] Secrets management (template placeholders)
- [x] Ingress with TLS
- [x] HPA with metrics
- [x] Monitoring (ServiceMonitor + PrometheusRules)
- [x] Deployment strategies (rolling, canary, blue-green)
- [x] Graceful shutdown (termination grace period)
- [x] Prometheus metrics scraping

## Differences from Old infra/kubernetes/ Structure

**Migration Path:**

Old structure split configs by environment:
```
infra/kubernetes/
├── uat/              (enterprise-uat namespace)
├── prod/             (enterprise-prod namespace)
└── perf-prod/        (enterprise-perf-prod namespace)
```

New unified structure:
```
k8s/                  (enterprise-app namespace)
├── (core configs)
└── strategies/       (deployment patterns)
```

**Migration Steps:**

1. Update Jenkins Jenkinsfiles to reference `k8s/` instead of `infra/kubernetes/{uat,prod}/`
2. Consolidate environment-specific placeholders into template format
3. Update deployment scripts to render placeholders during CI/CD
4. Keep old `infra/kubernetes/` for reference until all deployments migrated

## Support & Customization

- **Resource limits**: Adjust based on your workload profiling
- **Replicas**: Scale down for dev/test environments
- **Affinity**: Remove anti-affinity for single-node clusters
- **Storage class**: Change `storageClassName` in PVC for cloud-specific storage
- **Monitoring**: Requires Prometheus Operator addon
- **VPA**: Optional - requires VPA addon installation

## References

- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)
- [Pod Disruption Budgets](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/)
- [HPA Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

