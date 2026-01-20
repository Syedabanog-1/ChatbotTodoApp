#!/bin/bash
# =============================================================================
# Minikube Local Kubernetes Setup Script
# Tech Stack: Docker, Minikube, Helm, kubectl-ai, kagent
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MINIKUBE_CPUS=${MINIKUBE_CPUS:-4}
MINIKUBE_MEMORY=${MINIKUBE_MEMORY:-8192}
MINIKUBE_DRIVER=${MINIKUBE_DRIVER:-docker}
KUBERNETES_VERSION=${KUBERNETES_VERSION:-v1.28.0}

echo -e "${BLUE}==============================================================================${NC}"
echo -e "${BLUE}        Local Kubernetes Deployment - Chatbot Todo App${NC}"
echo -e "${BLUE}        Tech Stack: Docker, Minikube, Helm, kubectl-ai, kagent${NC}"
echo -e "${BLUE}==============================================================================${NC}"

# -----------------------------------------------------------------------------
# Pre-flight Checks
# -----------------------------------------------------------------------------
check_prerequisites() {
    echo -e "\n${YELLOW}[1/7] Checking prerequisites...${NC}"

    # Check Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}ERROR: Docker is not installed. Please install Docker first.${NC}"
        echo "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    echo -e "${GREEN}  ✓ Docker is installed${NC}"

    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        echo -e "${RED}ERROR: Docker daemon is not running. Please start Docker.${NC}"
        exit 1
    fi
    echo -e "${GREEN}  ✓ Docker daemon is running${NC}"

    # Check Minikube
    if ! command -v minikube &> /dev/null; then
        echo -e "${RED}ERROR: Minikube is not installed.${NC}"
        echo "Install with: choco install minikube (Windows) or brew install minikube (Mac)"
        echo "Visit: https://minikube.sigs.k8s.io/docs/start/"
        exit 1
    fi
    echo -e "${GREEN}  ✓ Minikube is installed${NC}"

    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}ERROR: kubectl is not installed.${NC}"
        echo "Install with: choco install kubernetes-cli (Windows) or brew install kubectl (Mac)"
        exit 1
    fi
    echo -e "${GREEN}  ✓ kubectl is installed${NC}"

    # Check Helm
    if ! command -v helm &> /dev/null; then
        echo -e "${RED}ERROR: Helm is not installed.${NC}"
        echo "Install with: choco install kubernetes-helm (Windows) or brew install helm (Mac)"
        exit 1
    fi
    echo -e "${GREEN}  ✓ Helm is installed${NC}"

    echo -e "${GREEN}All prerequisites satisfied!${NC}"
}

# -----------------------------------------------------------------------------
# Start Minikube Cluster
# -----------------------------------------------------------------------------
start_minikube() {
    echo -e "\n${YELLOW}[2/7] Starting Minikube cluster...${NC}"

    # Check if Minikube is already running
    if minikube status | grep -q "Running"; then
        echo -e "${GREEN}  Minikube is already running${NC}"
    else
        echo -e "${BLUE}  Starting Minikube with ${MINIKUBE_CPUS} CPUs and ${MINIKUBE_MEMORY}MB memory...${NC}"
        minikube start \
            --driver=${MINIKUBE_DRIVER} \
            --cpus=${MINIKUBE_CPUS} \
            --memory=${MINIKUBE_MEMORY} \
            --kubernetes-version=${KUBERNETES_VERSION} \
            --addons=ingress,dashboard,metrics-server
    fi

    # Verify cluster is ready
    kubectl cluster-info
    echo -e "${GREEN}  ✓ Minikube cluster is ready${NC}"
}

# -----------------------------------------------------------------------------
# Configure Docker Environment for Minikube
# -----------------------------------------------------------------------------
configure_docker_env() {
    echo -e "\n${YELLOW}[3/7] Configuring Docker environment for Minikube...${NC}"

    # Set Docker environment to use Minikube's Docker daemon
    eval $(minikube docker-env)
    echo -e "${GREEN}  ✓ Docker environment configured to use Minikube's daemon${NC}"
    echo -e "${BLUE}  Note: Run 'eval \$(minikube docker-env)' in new terminals${NC}"
}

# -----------------------------------------------------------------------------
# Build Docker Image
# -----------------------------------------------------------------------------
build_docker_image() {
    echo -e "\n${YELLOW}[4/7] Building Docker image...${NC}"

    # Navigate to project root
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
    cd "$PROJECT_ROOT"

    echo -e "${BLUE}  Building chatbot-todo-app:1.0 image...${NC}"
    docker build -t chatbot-todo-app:1.0 .

    # Verify image
    docker images | grep chatbot-todo-app
    echo -e "${GREEN}  ✓ Docker image built successfully${NC}"
}

# -----------------------------------------------------------------------------
# Create Kubernetes Namespace and Secrets
# -----------------------------------------------------------------------------
setup_kubernetes_resources() {
    echo -e "\n${YELLOW}[5/7] Setting up Kubernetes resources...${NC}"

    # Create namespace
    kubectl create namespace chatbot-app --dry-run=client -o yaml | kubectl apply -f -
    echo -e "${GREEN}  ✓ Namespace 'chatbot-app' created${NC}"

    # Check for OpenAI API Key
    if [ -z "$OPENAI_API_KEY" ]; then
        echo -e "${YELLOW}  Warning: OPENAI_API_KEY environment variable not set${NC}"
        echo -e "${YELLOW}  Please set it with: export OPENAI_API_KEY=your-key-here${NC}"
        OPENAI_API_KEY="placeholder-set-your-key"
    fi

    # Create secret
    kubectl create secret generic chatbot-secrets \
        --from-literal=openai-api-key="$OPENAI_API_KEY" \
        --namespace=chatbot-app \
        --dry-run=client -o yaml | kubectl apply -f -
    echo -e "${GREEN}  ✓ Secrets created${NC}"
}

# -----------------------------------------------------------------------------
# Deploy with Helm
# -----------------------------------------------------------------------------
deploy_with_helm() {
    echo -e "\n${YELLOW}[6/7] Deploying application with Helm...${NC}"

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
    HELM_CHART="$PROJECT_ROOT/helm/chatbot-todo-app"

    # Install/Upgrade Helm release
    helm upgrade --install chatbot-todo-app "$HELM_CHART" \
        --namespace chatbot-app \
        --set openaiApiKey="$OPENAI_API_KEY" \
        --wait \
        --timeout 5m

    echo -e "${GREEN}  ✓ Helm deployment complete${NC}"
}

# -----------------------------------------------------------------------------
# Verify Deployment and Show Access Info
# -----------------------------------------------------------------------------
verify_deployment() {
    echo -e "\n${YELLOW}[7/7] Verifying deployment...${NC}"

    # Wait for pods to be ready
    echo -e "${BLUE}  Waiting for pods to be ready...${NC}"
    kubectl wait --for=condition=ready pod -l app=chatbot-todo-app \
        --namespace=chatbot-app --timeout=120s

    # Show pod status
    echo -e "\n${BLUE}Pod Status:${NC}"
    kubectl get pods -n chatbot-app

    # Show service status
    echo -e "\n${BLUE}Service Status:${NC}"
    kubectl get svc -n chatbot-app

    # Get Minikube service URL
    echo -e "\n${GREEN}==============================================================================${NC}"
    echo -e "${GREEN}                    DEPLOYMENT SUCCESSFUL!${NC}"
    echo -e "${GREEN}==============================================================================${NC}"

    SERVICE_URL=$(minikube service chatbot-todo-app --namespace=chatbot-app --url 2>/dev/null || echo "Run: minikube service chatbot-todo-app -n chatbot-app")
    echo -e "\n${BLUE}Access your application:${NC}"
    echo -e "  Service URL: ${GREEN}${SERVICE_URL}${NC}"
    echo -e "  Dashboard:   ${GREEN}minikube dashboard${NC}"

    echo -e "\n${BLUE}Useful commands:${NC}"
    echo -e "  View logs:     kubectl logs -f -l app=chatbot-todo-app -n chatbot-app"
    echo -e "  Scale:         kubectl scale deployment chatbot-todo-app --replicas=3 -n chatbot-app"
    echo -e "  Port forward:  kubectl port-forward svc/chatbot-todo-app 8000:8000 -n chatbot-app"
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------
main() {
    check_prerequisites
    start_minikube
    configure_docker_env
    build_docker_image
    setup_kubernetes_resources
    deploy_with_helm
    verify_deployment
}

# Run main function
main "$@"
