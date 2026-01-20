# kubectl-ai Examples for Chatbot Todo App

This document provides practical examples of using `kubectl-ai` with natural language commands for managing the Chatbot Todo App on Kubernetes.

## Prerequisites

1. kubectl-ai installed and configured
2. OpenAI API key set: `export OPENAI_API_KEY=your-key`
3. Kubernetes cluster running (Minikube)
4. Chatbot Todo App deployed

## Basic Operations

### View Resources

```bash
# List all pods
kubectl ai "show all pods in chatbot-app namespace"

# Get pod details
kubectl ai "describe the chatbot-todo-app pod"

# List services
kubectl ai "list all services in chatbot-app namespace"

# View deployments
kubectl ai "show deployment status for chatbot-todo-app"
```

### Logs and Monitoring

```bash
# View application logs
kubectl ai "show logs from chatbot-todo-app deployment"

# Stream logs in real-time
kubectl ai "follow the logs from chatbot pods"

# Check resource usage
kubectl ai "show CPU and memory usage for chatbot pods"

# View events
kubectl ai "show recent events in chatbot-app namespace"
```

## Deployment Management

### Scaling

```bash
# Scale up
kubectl ai "scale chatbot-todo-app deployment to 3 replicas"

# Scale down
kubectl ai "reduce chatbot replicas to 1"

# Check scaling status
kubectl ai "show current replica count for chatbot deployment"
```

### Rolling Updates

```bash
# Check rollout status
kubectl ai "show rollout status for chatbot-todo-app"

# View rollout history
kubectl ai "display deployment history for chatbot-todo-app"

# Rollback deployment
kubectl ai "rollback chatbot-todo-app to previous version"
```

### Restart Pods

```bash
# Restart all pods
kubectl ai "restart all pods in chatbot-todo-app deployment"

# Delete a specific pod (triggers recreation)
kubectl ai "delete the oldest chatbot pod"
```

## Troubleshooting

### Diagnose Issues

```bash
# Check pod status
kubectl ai "why is the chatbot pod not running?"

# View pod events
kubectl ai "show events for failing chatbot pod"

# Check readiness probes
kubectl ai "why is chatbot pod not becoming ready?"

# Debug networking
kubectl ai "check if chatbot service endpoints are healthy"
```

### Access Pods

```bash
# Execute shell in pod
kubectl ai "open a shell in the chatbot pod"

# Run a specific command
kubectl ai "execute 'ls -la /app' in chatbot pod"

# Check environment variables
kubectl ai "show environment variables in chatbot pod"
```

### Port Forwarding

```bash
# Forward service port
kubectl ai "forward port 8000 from chatbot service to localhost"

# Forward pod port
kubectl ai "create port forward to chatbot pod on port 8000"
```

## Resource Management

### Persistent Storage

```bash
# View PVCs
kubectl ai "list persistent volume claims in chatbot-app namespace"

# Check PVC status
kubectl ai "show status of chatbot data PVC"

# View storage usage
kubectl ai "how much storage is chatbot-data-pvc using?"
```

### Secrets and ConfigMaps

```bash
# List secrets
kubectl ai "show all secrets in chatbot-app namespace"

# View configmap
kubectl ai "display chatbot configmap contents"

# Check secret exists
kubectl ai "does chatbot-secrets contain openai-api-key?"
```

## Advanced Operations

### YAML Export

```bash
# Export deployment YAML
kubectl ai "export chatbot-todo-app deployment as yaml"

# Get service definition
kubectl ai "show yaml for chatbot service"
```

### Resource Limits

```bash
# View resource limits
kubectl ai "what are the resource limits for chatbot pods?"

# Check if resources are sufficient
kubectl ai "is chatbot deployment hitting resource limits?"
```

### Network Policies

```bash
# List network policies
kubectl ai "show network policies affecting chatbot namespace"

# Check connectivity
kubectl ai "can chatbot pods reach external services?"
```

## Helm-Specific Commands

```bash
# List Helm releases
kubectl ai "list all helm releases in chatbot-app namespace"

# Get Helm values
kubectl ai "show values used for chatbot-todo-app helm release"

# Check Helm status
kubectl ai "what is the status of chatbot-todo-app helm release?"
```

## Quick Reference Card

| Task | Natural Language Command |
|------|-------------------------|
| View pods | "show all pods" |
| Get logs | "show chatbot logs" |
| Scale up | "scale to 3 replicas" |
| Restart | "restart the pods" |
| Troubleshoot | "why is pod failing?" |
| Port forward | "forward port 8000" |
| Check resources | "show CPU usage" |
| View secrets | "list secrets" |
| Rollback | "rollback deployment" |
| Shell access | "exec into pod" |

## Tips

1. **Be Specific**: Include namespace and deployment names for accuracy
2. **Confirm Commands**: kubectl-ai shows generated commands before execution
3. **Use Dry-Run**: Add "dry run" to see what would happen without executing
4. **Chain Commands**: Describe multi-step operations naturally
5. **Ask Questions**: kubectl-ai can explain Kubernetes concepts

## Common Patterns

```bash
# Morning check
kubectl ai "give me a health summary of chatbot-app namespace"

# Before deployment
kubectl ai "is there enough capacity to scale chatbot to 5 replicas?"

# Incident response
kubectl ai "show me everything about the failing chatbot pod including logs and events"

# End of day
kubectl ai "how has chatbot performed today? show metrics summary"
```
