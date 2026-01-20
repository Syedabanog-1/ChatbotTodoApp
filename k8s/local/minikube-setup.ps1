# =============================================================================
# Minikube Local Kubernetes Setup Script (PowerShell for Windows)
# Tech Stack: Docker, Minikube, Helm, kubectl-ai, kagent
# =============================================================================

$ErrorActionPreference = "Stop"

# Configuration
$MINIKUBE_CPUS = if ($env:MINIKUBE_CPUS) { $env:MINIKUBE_CPUS } else { 4 }
$MINIKUBE_MEMORY = if ($env:MINIKUBE_MEMORY) { $env:MINIKUBE_MEMORY } else { 8192 }
$MINIKUBE_DRIVER = if ($env:MINIKUBE_DRIVER) { $env:MINIKUBE_DRIVER } else { "docker" }
$KUBERNETES_VERSION = if ($env:KUBERNETES_VERSION) { $env:KUBERNETES_VERSION } else { "v1.28.0" }

Write-Host "==============================================================================" -ForegroundColor Blue
Write-Host "        Local Kubernetes Deployment - Chatbot Todo App" -ForegroundColor Blue
Write-Host "        Tech Stack: Docker, Minikube, Helm, kubectl-ai, kagent" -ForegroundColor Blue
Write-Host "==============================================================================" -ForegroundColor Blue

# -----------------------------------------------------------------------------
# Pre-flight Checks
# -----------------------------------------------------------------------------
function Check-Prerequisites {
    Write-Host "`n[1/7] Checking prerequisites..." -ForegroundColor Yellow

    # Check Docker
    if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: Docker is not installed. Please install Docker Desktop." -ForegroundColor Red
        Write-Host "Visit: https://docs.docker.com/docker-for-windows/install/"
        exit 1
    }
    Write-Host "  Docker is installed" -ForegroundColor Green

    # Check if Docker daemon is running
    try {
        docker info | Out-Null
        Write-Host "  Docker daemon is running" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Docker daemon is not running. Please start Docker Desktop." -ForegroundColor Red
        exit 1
    }

    # Check Minikube
    if (!(Get-Command minikube -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: Minikube is not installed." -ForegroundColor Red
        Write-Host "Install with: choco install minikube"
        Write-Host "Or download from: https://minikube.sigs.k8s.io/docs/start/"
        exit 1
    }
    Write-Host "  Minikube is installed" -ForegroundColor Green

    # Check kubectl
    if (!(Get-Command kubectl -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: kubectl is not installed." -ForegroundColor Red
        Write-Host "Install with: choco install kubernetes-cli"
        exit 1
    }
    Write-Host "  kubectl is installed" -ForegroundColor Green

    # Check Helm
    if (!(Get-Command helm -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: Helm is not installed." -ForegroundColor Red
        Write-Host "Install with: choco install kubernetes-helm"
        exit 1
    }
    Write-Host "  Helm is installed" -ForegroundColor Green

    Write-Host "All prerequisites satisfied!" -ForegroundColor Green
}

# -----------------------------------------------------------------------------
# Start Minikube Cluster
# -----------------------------------------------------------------------------
function Start-MinikubeCluster {
    Write-Host "`n[2/7] Starting Minikube cluster..." -ForegroundColor Yellow

    $status = minikube status 2>$null
    if ($status -match "Running") {
        Write-Host "  Minikube is already running" -ForegroundColor Green
    } else {
        Write-Host "  Starting Minikube with $MINIKUBE_CPUS CPUs and ${MINIKUBE_MEMORY}MB memory..." -ForegroundColor Blue
        minikube start `
            --driver=$MINIKUBE_DRIVER `
            --cpus=$MINIKUBE_CPUS `
            --memory=$MINIKUBE_MEMORY `
            --kubernetes-version=$KUBERNETES_VERSION `
            --addons=ingress,dashboard,metrics-server
    }

    kubectl cluster-info
    Write-Host "  Minikube cluster is ready" -ForegroundColor Green
}

# -----------------------------------------------------------------------------
# Configure Docker Environment for Minikube
# -----------------------------------------------------------------------------
function Configure-DockerEnv {
    Write-Host "`n[3/7] Configuring Docker environment for Minikube..." -ForegroundColor Yellow

    # Set Docker environment to use Minikube's Docker daemon
    & minikube -p minikube docker-env --shell powershell | Invoke-Expression
    Write-Host "  Docker environment configured to use Minikube's daemon" -ForegroundColor Green
    Write-Host "  Note: Run '& minikube docker-env --shell powershell | Invoke-Expression' in new terminals" -ForegroundColor Blue
}

# -----------------------------------------------------------------------------
# Build Docker Image
# -----------------------------------------------------------------------------
function Build-DockerImage {
    Write-Host "`n[4/7] Building Docker image..." -ForegroundColor Yellow

    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)
    Push-Location $ProjectRoot

    try {
        Write-Host "  Building chatbot-todo-app:1.0 image..." -ForegroundColor Blue
        docker build -t chatbot-todo-app:1.0 .

        docker images | Select-String "chatbot-todo-app"
        Write-Host "  Docker image built successfully" -ForegroundColor Green
    } finally {
        Pop-Location
    }
}

# -----------------------------------------------------------------------------
# Create Kubernetes Namespace and Secrets
# -----------------------------------------------------------------------------
function Setup-KubernetesResources {
    Write-Host "`n[5/7] Setting up Kubernetes resources..." -ForegroundColor Yellow

    # Create namespace
    kubectl create namespace chatbot-app --dry-run=client -o yaml | kubectl apply -f -
    Write-Host "  Namespace 'chatbot-app' created" -ForegroundColor Green

    # Check for OpenAI API Key
    $ApiKey = $env:OPENAI_API_KEY
    if (!$ApiKey) {
        Write-Host "  Warning: OPENAI_API_KEY environment variable not set" -ForegroundColor Yellow
        Write-Host "  Please set it with: `$env:OPENAI_API_KEY='your-key-here'" -ForegroundColor Yellow
        $ApiKey = "placeholder-set-your-key"
    }

    # Create secret
    kubectl create secret generic chatbot-secrets `
        --from-literal=openai-api-key="$ApiKey" `
        --namespace=chatbot-app `
        --dry-run=client -o yaml | kubectl apply -f -
    Write-Host "  Secrets created" -ForegroundColor Green
}

# -----------------------------------------------------------------------------
# Deploy with Helm
# -----------------------------------------------------------------------------
function Deploy-WithHelm {
    Write-Host "`n[6/7] Deploying application with Helm..." -ForegroundColor Yellow

    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)
    $HelmChart = Join-Path $ProjectRoot "helm\chatbot-todo-app"

    $ApiKey = if ($env:OPENAI_API_KEY) { $env:OPENAI_API_KEY } else { "placeholder-set-your-key" }

    helm upgrade --install chatbot-todo-app $HelmChart `
        --namespace chatbot-app `
        --set openaiApiKey="$ApiKey" `
        --wait `
        --timeout 5m

    Write-Host "  Helm deployment complete" -ForegroundColor Green
}

# -----------------------------------------------------------------------------
# Verify Deployment and Show Access Info
# -----------------------------------------------------------------------------
function Verify-Deployment {
    Write-Host "`n[7/7] Verifying deployment..." -ForegroundColor Yellow

    # Wait for pods to be ready
    Write-Host "  Waiting for pods to be ready..." -ForegroundColor Blue
    kubectl wait --for=condition=ready pod -l app=chatbot-todo-app `
        --namespace=chatbot-app --timeout=120s

    # Show pod status
    Write-Host "`nPod Status:" -ForegroundColor Blue
    kubectl get pods -n chatbot-app

    # Show service status
    Write-Host "`nService Status:" -ForegroundColor Blue
    kubectl get svc -n chatbot-app

    Write-Host "`n==============================================================================" -ForegroundColor Green
    Write-Host "                    DEPLOYMENT SUCCESSFUL!" -ForegroundColor Green
    Write-Host "==============================================================================" -ForegroundColor Green

    Write-Host "`nAccess your application:" -ForegroundColor Blue
    Write-Host "  Service URL: Run 'minikube service chatbot-todo-app -n chatbot-app'" -ForegroundColor Green
    Write-Host "  Dashboard:   Run 'minikube dashboard'" -ForegroundColor Green

    Write-Host "`nUseful commands:" -ForegroundColor Blue
    Write-Host "  View logs:     kubectl logs -f -l app=chatbot-todo-app -n chatbot-app"
    Write-Host "  Scale:         kubectl scale deployment chatbot-todo-app --replicas=3 -n chatbot-app"
    Write-Host "  Port forward:  kubectl port-forward svc/chatbot-todo-app 8000:8000 -n chatbot-app"
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------
function Main {
    Check-Prerequisites
    Start-MinikubeCluster
    Configure-DockerEnv
    Build-DockerImage
    Setup-KubernetesResources
    Deploy-WithHelm
    Verify-Deployment
}

# Run main function
Main
