# Local Kubernetes Deployment Guide

A comprehensive guide for deploying the AI Chatbot Todo Application to a local Kubernetes cluster using Minikube, with AI-powered management tools (kubectl-ai and kagent).

## Tech Stack

| Tool | Purpose | Version |
|------|---------|---------|
| **Docker** | Container runtime | Latest |
| **Minikube** | Local Kubernetes cluster | v1.32+ |
| **Helm** | Kubernetes package manager | v3.12+ |
| **kubectl-ai** | Natural language K8s commands | Latest |
| **kagent** | AI-powered K8s operations | v1.0+ |

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    Local Development Environment                 │
├─────────────────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                      Minikube Cluster                      │  │
│  │  ┌─────────────────┐  ┌─────────────────────────────────┐ │  │
│  │  │  kagent-system  │  │        chatbot-app              │ │  │
│  │  │  ┌───────────┐  │  │  ┌───────────┐  ┌───────────┐  │ │  │
│  │  │  │  kagent   │  │  │  │  Pod 1    │  │  Pod 2    │  │ │  │
│  │  │  │  (AI Ops) │──┼──┼─▶│ FastAPI   │  │ FastAPI   │  │ │  │
│  │  │  └───────────┘  │  │  └───────────┘  └───────────┘  │ │  │
│  │  └─────────────────┘  │        │              │        │ │  │
│  │                       │  ┌─────┴──────────────┴─────┐  │ │  │
│  │                       │  │     Service (NodePort)   │  │ │  │
│  │                       │  └────────────┬─────────────┘  │ │  │
│  │                       │  ┌────────────┴─────────────┐  │ │  │
│  │                       │  │  PersistentVolumeClaim   │  │ │  │
│  │                       │  │  (SQLite Database)       │  │ │  │
│  │                       │  └──────────────────────────┘  │ │  │
│  │                       └─────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                   │
│  ┌───────────────────────────┼───────────────────────────────┐  │
│  │         kubectl-ai        │                                │  │
│  │  "show pods" ──────────▶  │  ◀──── Natural Language       │  │
│  │                           │         Commands               │  │
│  └───────────────────────────┴───────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Prerequisites

### Required Software

1. **Docker Desktop**
   - Windows: [Download Docker Desktop](https://docs.docker.com/docker-for-windows/install/)
   - Mac: [Download Docker Desktop](https://docs.docker.com/docker-for-mac/install/)
   - Linux: [Install Docker Engine](https://docs.docker.com/engine/install/)

2. **Minikube**
   ```bash
   # Windows (Chocolatey)
   choco install minikube

   # Mac (Homebrew)
   brew install minikube

   # Linux
   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
   sudo install minikube-linux-amd64 /usr/local/bin/minikube
   ```

3. **kubectl**
   ```bash
   # Windows
   choco install kubernetes-cli

   # Mac
   brew install kubectl

   # Linux
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   sudo install kubectl /usr/local/bin/kubectl
   ```

4. **Helm**
   ```bash
   # Windows
   choco install kubernetes-helm

   # Mac
   brew install helm

   # Linux
   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
   ```

### Environment Variables

Set the OpenAI API key (required for the chatbot to function):

```bash
# Bash/Zsh
export OPENAI_API_KEY="your-openai-api-key-here"

# PowerShell
$env:OPENAI_API_KEY="your-openai-api-key-here"

# Windows CMD
set OPENAI_API_KEY=your-openai-api-key-here
```

## Quick Start

### Option 1: Automated Setup (Recommended)

**Linux/Mac:**
```bash
# Run the setup script
chmod +x k8s/local/minikube-setup.sh
./k8s/local/minikube-setup.sh
```

**Windows (PowerShell):**
```powershell
# Run the setup script
.\k8s\local\minikube-setup.ps1
```

### Option 2: Manual Setup

#### Step 1: Start Minikube

```bash
# Start Minikube with recommended settings
minikube start \
  --driver=docker \
  --cpus=4 \
  --memory=8192 \
  --kubernetes-version=v1.28.0 \
  --addons=ingress,dashboard,metrics-server
```

#### Step 2: Configure Docker Environment

```bash
# Configure Docker to use Minikube's daemon
eval $(minikube docker-env)

# PowerShell
& minikube docker-env --shell powershell | Invoke-Expression
```

#### Step 3: Build Docker Image

```bash
# Build the application image
docker build -t chatbot-todo-app:1.0 .

# Verify the image
docker images | grep chatbot-todo-app
```

#### Step 4: Create Namespace and Secrets

```bash
# Create namespace
kubectl create namespace chatbot-app

# Create secret with OpenAI API key
kubectl create secret generic chatbot-secrets \
  --from-literal=openai-api-key="$OPENAI_API_KEY" \
  --namespace=chatbot-app
```

#### Step 5: Deploy with Helm

```bash
# Install the Helm chart
helm upgrade --install chatbot-todo-app ./helm/chatbot-todo-app \
  --namespace chatbot-app \
  --set openaiApiKey="$OPENAI_API_KEY" \
  -f ./helm/chatbot-todo-app/values-local.yaml \
  --wait

# Verify deployment
kubectl get pods -n chatbot-app
```

#### Step 6: Access the Application

```bash
# Get the service URL
minikube service chatbot-todo-app --namespace=chatbot-app

# Or use port forwarding
kubectl port-forward svc/chatbot-todo-app 8000:8000 -n chatbot-app
```

## kubectl-ai Setup

kubectl-ai enables natural language Kubernetes commands.

### Installation

```bash
# Run the setup script
chmod +x k8s/ai-tools/kubectl-ai-setup.sh
./k8s/ai-tools/kubectl-ai-setup.sh

# Or install manually
# Mac
brew tap sozercan/kubectl-ai
brew install kubectl-ai

# Go install
go install github.com/sozercan/kubectl-ai@latest
```

### Configuration

Create `~/.kubectl-ai/config.yaml`:

```yaml
openai:
  model: gpt-4
  temperature: 0.2
safety:
  require_confirmation: true
context:
  default_namespace: chatbot-app
```

### Usage Examples

```bash
# View pods
kubectl ai "show all pods in chatbot-app namespace"

# Check logs
kubectl ai "get the logs from chatbot deployment"

# Scale deployment
kubectl ai "scale chatbot to 3 replicas"

# Troubleshoot
kubectl ai "why is the chatbot pod failing?"

# Resource usage
kubectl ai "show CPU and memory usage for all pods"
```

See [kubectl-ai-examples.md](k8s/ai-tools/kubectl-ai-examples.md) for more examples.

## kagent Setup

kagent provides AI-powered Kubernetes operations and monitoring.

### Installation

```bash
# Run the setup script
chmod +x k8s/ai-tools/kagent/setup-kagent.sh
./k8s/ai-tools/kagent/setup-kagent.sh
```

### Manual Deployment

```bash
# Apply kagent deployment
kubectl apply -f k8s/ai-tools/kagent/agent-deployment.yaml

# Update the secret with your API key
kubectl create secret generic kagent-secrets \
  --from-literal=openai-api-key="$OPENAI_API_KEY" \
  --namespace=kagent-system \
  --dry-run=client -o yaml | kubectl apply -f -

# Apply chatbot agent configuration
kubectl apply -f k8s/ai-tools/kagent/chatbot-agent.yaml
```

### Capabilities

- **Health Monitoring**: Continuous health checks and alerting
- **Log Analysis**: AI-powered log analysis for errors and anomalies
- **Resource Monitoring**: CPU/memory tracking with thresholds
- **Scaling Recommendations**: Intelligent scaling suggestions
- **Troubleshooting**: Automated issue diagnosis

### Accessing kagent

```bash
# Port forward to kagent API
kubectl port-forward svc/kagent 8081:8081 -n kagent-system

# Query kagent
curl http://localhost:8081/api/v1/health
curl http://localhost:8081/api/v1/analyze?namespace=chatbot-app
```

## Common Operations

### Viewing Resources

```bash
# All resources in namespace
kubectl get all -n chatbot-app

# Pod details
kubectl describe pod -l app=chatbot-todo-app -n chatbot-app

# Service endpoints
kubectl get endpoints -n chatbot-app
```

### Logs

```bash
# Stream logs
kubectl logs -f -l app=chatbot-todo-app -n chatbot-app

# Previous container logs (after crash)
kubectl logs -l app=chatbot-todo-app -n chatbot-app --previous
```

### Scaling

```bash
# Scale up
kubectl scale deployment chatbot-todo-app --replicas=3 -n chatbot-app

# Auto-scaling (HPA)
kubectl autoscale deployment chatbot-todo-app \
  --min=1 --max=5 --cpu-percent=70 -n chatbot-app
```

### Updates

```bash
# Update image
kubectl set image deployment/chatbot-todo-app \
  chatbot-todo-app=chatbot-todo-app:2.0 -n chatbot-app

# Rollback
kubectl rollout undo deployment/chatbot-todo-app -n chatbot-app
```

### Debugging

```bash
# Execute shell in pod
kubectl exec -it deployment/chatbot-todo-app -n chatbot-app -- /bin/bash

# Port forward for debugging
kubectl port-forward svc/chatbot-todo-app 8000:8000 -n chatbot-app

# View events
kubectl get events -n chatbot-app --sort-by=.metadata.creationTimestamp
```

## Helm Commands

```bash
# List releases
helm list -n chatbot-app

# View values
helm get values chatbot-todo-app -n chatbot-app

# Upgrade with new values
helm upgrade chatbot-todo-app ./helm/chatbot-todo-app \
  --namespace chatbot-app \
  --set replicaCount=3

# Uninstall
helm uninstall chatbot-todo-app -n chatbot-app
```

## Minikube Dashboard

```bash
# Open Kubernetes dashboard
minikube dashboard

# Get dashboard URL
minikube dashboard --url
```

## Cleanup

```bash
# Delete application
helm uninstall chatbot-todo-app -n chatbot-app
kubectl delete namespace chatbot-app

# Delete kagent
kubectl delete -f k8s/ai-tools/kagent/agent-deployment.yaml
kubectl delete namespace kagent-system

# Stop Minikube
minikube stop

# Delete Minikube cluster
minikube delete
```

## Troubleshooting

### Pod Not Starting

```bash
# Check pod status
kubectl describe pod -l app=chatbot-todo-app -n chatbot-app

# Check events
kubectl get events -n chatbot-app

# Check logs
kubectl logs -l app=chatbot-todo-app -n chatbot-app
```

### Image Pull Issues

```bash
# Ensure Docker env is configured
eval $(minikube docker-env)

# Verify image exists
docker images | grep chatbot-todo-app

# Check imagePullPolicy is "Never" for local images
```

### Service Not Accessible

```bash
# Check service
kubectl get svc -n chatbot-app

# Check endpoints
kubectl get endpoints -n chatbot-app

# Use Minikube tunnel for LoadBalancer services
minikube tunnel
```

### Resource Constraints

```bash
# Check node resources
kubectl top nodes

# Check pod resources
kubectl top pods -n chatbot-app

# Adjust Minikube resources
minikube stop
minikube start --cpus=6 --memory=12288
```

## File Structure

```
k8s/
├── local/
│   ├── minikube-setup.sh      # Linux/Mac setup script
│   └── minikube-setup.ps1     # Windows PowerShell script
├── ai-tools/
│   ├── kubectl-ai-setup.sh    # kubectl-ai installation
│   ├── kubectl-ai-examples.md # Usage examples
│   └── kagent/
│       ├── agent-deployment.yaml   # kagent deployment
│       ├── chatbot-agent.yaml      # Custom agent config
│       └── setup-kagent.sh         # kagent setup script
├── deployment.yaml            # Base K8s deployment
├── service.yaml              # Service configuration
├── pvc.yaml                  # Persistent volume claim
└── secret.yaml               # Secret template

helm/chatbot-todo-app/
├── Chart.yaml                # Helm chart metadata
├── values.yaml               # Default values
├── values-local.yaml         # Local development values
└── templates/
    ├── deployment.yaml       # Deployment template
    ├── service.yaml          # Service template
    ├── pvc.yaml              # PVC template
    ├── secret.yaml           # Secret template
    └── _helpers.tpl          # Template helpers
```

## Learning Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [kubectl-ai GitHub](https://github.com/sozercan/kubectl-ai)
- [Docker Documentation](https://docs.docker.com/)
