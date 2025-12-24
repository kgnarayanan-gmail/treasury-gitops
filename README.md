# Treasury GitOps Platform

Multi-environment Kubernetes deployment with GitOps, CI/CD, and monitoring.

## Architecture

```
┌─────────────────┐      ┌──────────────────┐      ┌─────────────────┐
│  Developer      │─────▶│  GitHub Actions  │─────▶│  GitHub Repo    │
│  Code Changes   │      │  CI/CD Pipeline  │      │  (GitOps Source)│
└─────────────────┘      └──────────────────┘      └─────────────────┘
                                                            │
                                                            │ watches
                                                            ▼
                         ┌───────────────────────────────────────────┐
                         │           ArgoCD                          │
                         │  (Continuous Deployment)                  │
                         └───────────────────────────────────────────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    ▼                 ▼                 ▼
              ┌──────────┐      ┌──────────┐      ┌──────────┐
              │   Dev    │      │ Staging  │      │   Prod   │
              │ Namespace│      │ Namespace│      │ Namespace│
              │ 1 replica│      │ 2 replica│      │ 3 replica│
              └──────────┘      └──────────┘      └──────────┘
```

## CI/CD Pipeline

### Automated Flow

1. **Developer pushes code** to `treasury-app/` directory
2. **GitHub Actions triggers** automatically:
   - Builds Docker image
   - Pushes to GitHub Container Registry (GHCR)
   - Updates `values-dev.yaml` with new image tag
   - Commits changes back to Git
3. **ArgoCD detects changes** and syncs to dev environment
4. **Manual promotion** to staging and prod via PR

### Pipeline Features

- Semantic versioning (`1.0.BUILD_NUMBER`)
- Multi-stage Docker builds
- GitHub Container Registry (GHCR) integration
- Automated dev deployments
- GitOps-based promotion workflow

## Directory Structure

```
gitops-apps/
├── .github/
│   └── workflows/
│       └── ci-cd.yml              # GitHub Actions CI/CD pipeline
├── treasury-app/                  # Custom application source
│   ├── Dockerfile                 # Multi-stage build
│   ├── docker-entrypoint.sh       # Dynamic config injection
│   ├── nginx.conf                 # Web server config
│   └── src/
│       └── index.html             # Application UI
└── nginx-chart/                   # Helm chart
    ├── Chart.yaml
    ├── values.yaml                # Default values
    ├── values-dev.yaml            # Dev environment
    ├── values-staging.yaml        # Staging environment
    ├── values-prod.yaml           # Production environment
    └── templates/
        ├── deployment.yaml
        ├── service.yaml
        ├── configmap.yaml
        └── NOTES.txt
```

## Environment Configuration

| Environment | Replicas | Port | Image Tag | Auto-Deploy |
|------------|----------|------|-----------|-------------|
| Dev | 1 | 30090 | Dynamic (CI/CD) | Yes |
| Staging | 2 | 30091 | Manual promotion | No |
| Production | 3 | 30092 | Manual promotion | No |

## Accessing Environments

```bash
# Get minikube IP
minikube ip

# Access environments
http://<minikube-ip>:30090  # Dev
http://<minikube-ip>:30091  # Staging
http://<minikube-ip>:30092  # Production
```

## Making Changes

### Automated Dev Deployment

1. Modify code in `treasury-app/src/index.html`
2. Commit and push to `main` branch
3. GitHub Actions builds and deploys to dev automatically
4. Check ArgoCD UI to watch deployment

### Promoting to Staging

1. After testing in dev, update `values-staging.yaml`:
   ```bash
   # Update image tag to tested version
   sed -i 's|tag: ".*"|tag: "1.0.X"|g' nginx-chart/values-staging.yaml
   ```
2. Commit and push
3. ArgoCD auto-syncs staging

### Promoting to Production

1. After staging validation, update `values-prod.yaml`
2. Create Pull Request for review
3. Merge after approval
4. ArgoCD deploys to production

## Monitoring

- **Prometheus**: `kubectl port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 9090:9090`
- **Grafana**: `kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80`
- **ArgoCD**: `kubectl port-forward svc/argocd-server -n argocd 8080:443`

## Key Commands

```bash
# View all applications
kubectl get applications -n argocd

# Check deployment status
kubectl get pods -n dev
kubectl get pods -n staging
kubectl get pods -n prod

# Trigger manual sync
kubectl -n argocd patch app nginx-dev --type=json -p='[{"op": "replace", "path": "/operation", "value": {"sync": {"revision": "HEAD"}}}]'

# View application logs
kubectl logs -n dev -l app=treasury-nginx --tail=50

# Rollback deployment
kubectl rollout undo deployment/treasury-nginx -n dev
```

## Technologies Used

- **Kubernetes**: Container orchestration
- **Helm**: Package manager for Kubernetes
- **ArgoCD**: GitOps continuous delivery
- **GitHub Actions**: CI/CD automation
- **Prometheus + Grafana**: Monitoring and alerting
- **Docker**: Containerization
- **GitHub Container Registry (GHCR)**: Image registry

## Best Practices Implemented

1. **GitOps**: All infrastructure as code in Git
2. **Multi-environment**: Separate namespaces for isolation
3. **Automated Testing**: Dev environment auto-deploys
4. **Progressive Delivery**: Gradual promotion through environments
5. **Immutable Infrastructure**: New deployments create new pods
6. **Observability**: Metrics and monitoring built-in
7. **Security**: Image scanning, RBAC, namespace isolation

## Future Enhancements

- [ ] Add automated tests in CI pipeline
- [ ] Implement canary deployments with Argo Rollouts
- [ ] Add Sealed Secrets for sensitive data
- [ ] Configure Ingress with TLS
- [ ] Add horizontal pod autoscaling (HPA)
- [ ] Implement automated rollback on failures
