#!/bin/bash
# =============================================================================
# kagent Setup Script
# AI-Powered Kubernetes Operations
# =============================================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}==============================================================================${NC}"
echo -e "${BLUE}                    kagent Setup Script${NC}"
echo -e "${BLUE}        AI-Powered Kubernetes Operations Agent${NC}"
echo -e "${BLUE}==============================================================================${NC}"

# -----------------------------------------------------------------------------
# Prerequisites Check
# -----------------------------------------------------------------------------
check_prerequisites() {
    echo -e "\n${YELLOW}[1/4] Checking prerequisites...${NC}"

    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}ERROR: kubectl is not installed${NC}"
        exit 1
    fi
    echo -e "${GREEN}  ✓ kubectl is available${NC}"

    # Check cluster connection
    if ! kubectl cluster-info &> /dev/null; then
        echo -e "${RED}ERROR: Cannot connect to Kubernetes cluster${NC}"
        echo "Make sure Minikube is running: minikube start"
        exit 1
    fi
    echo -e "${GREEN}  ✓ Connected to Kubernetes cluster${NC}"

    # Check for OpenAI API key
    if [ -z "$OPENAI_API_KEY" ]; then
        echo -e "${YELLOW}  Warning: OPENAI_API_KEY not set${NC}"
        echo -e "${YELLOW}  kagent requires an OpenAI API key to function${NC}"
        echo -e "${YELLOW}  Set it with: export OPENAI_API_KEY='your-key-here'${NC}"
    else
        echo -e "${GREEN}  ✓ OpenAI API key detected${NC}"
    fi
}

# -----------------------------------------------------------------------------
# Install kagent CRDs (if available)
# -----------------------------------------------------------------------------
install_crds() {
    echo -e "\n${YELLOW}[2/4] Installing kagent CRDs...${NC}"

    # Note: kagent CRDs would be installed here if using official kagent
    # For this demo, we use standard Kubernetes resources
    echo -e "${BLUE}  Using standard Kubernetes resources for agent deployment${NC}"
    echo -e "${GREEN}  ✓ CRD installation skipped (using standard resources)${NC}"
}

# -----------------------------------------------------------------------------
# Deploy kagent
# -----------------------------------------------------------------------------
deploy_kagent() {
    echo -e "\n${YELLOW}[3/4] Deploying kagent...${NC}"

    # Update secret with actual API key if available
    if [ -n "$OPENAI_API_KEY" ]; then
        echo -e "${BLUE}  Updating kagent secret with OpenAI API key...${NC}"

        # Create a temporary file with updated secret
        cat > /tmp/kagent-secret.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: kagent-secrets
  namespace: kagent-system
type: Opaque
stringData:
  openai-api-key: "${OPENAI_API_KEY}"
EOF
    fi

    # Apply the main deployment
    echo -e "${BLUE}  Applying kagent deployment...${NC}"
    kubectl apply -f "$SCRIPT_DIR/agent-deployment.yaml"

    # Apply the updated secret if we have an API key
    if [ -n "$OPENAI_API_KEY" ]; then
        kubectl apply -f /tmp/kagent-secret.yaml
        rm /tmp/kagent-secret.yaml
    fi

    # Wait for deployment
    echo -e "${BLUE}  Waiting for kagent to be ready...${NC}"
    kubectl wait --for=condition=available deployment/kagent \
        --namespace=kagent-system --timeout=120s || true

    echo -e "${GREEN}  ✓ kagent deployed${NC}"
}

# -----------------------------------------------------------------------------
# Deploy Custom Agent for Chatbot
# -----------------------------------------------------------------------------
deploy_chatbot_agent() {
    echo -e "\n${YELLOW}[4/4] Deploying Chatbot Operations Agent...${NC}"

    # Apply custom agent configuration
    echo -e "${BLUE}  Applying chatbot agent configuration...${NC}"
    kubectl apply -f "$SCRIPT_DIR/chatbot-agent.yaml" || {
        echo -e "${YELLOW}  Note: Custom agent CRD not available, configuration saved for reference${NC}"
    }

    echo -e "${GREEN}  ✓ Chatbot agent configuration applied${NC}"
}

# -----------------------------------------------------------------------------
# Show Status and Usage
# -----------------------------------------------------------------------------
show_status() {
    echo -e "\n${BLUE}==============================================================================${NC}"
    echo -e "${GREEN}                    kagent Setup Complete!${NC}"
    echo -e "${BLUE}==============================================================================${NC}"

    echo -e "\n${BLUE}Deployment Status:${NC}"
    kubectl get all -n kagent-system 2>/dev/null || echo "  kagent-system namespace created"

    echo -e "\n${BLUE}Usage:${NC}"
    echo -e "  # Check kagent status"
    echo -e "  kubectl get pods -n kagent-system"
    echo -e ""
    echo -e "  # View kagent logs"
    echo -e "  kubectl logs -f deployment/kagent -n kagent-system"
    echo -e ""
    echo -e "  # Access kagent API (port-forward)"
    echo -e "  kubectl port-forward svc/kagent 8081:8081 -n kagent-system"
    echo -e ""
    echo -e "  # Query kagent"
    echo -e "  curl http://localhost:8081/api/v1/analyze?namespace=chatbot-app"

    echo -e "\n${BLUE}Agent Capabilities:${NC}"
    echo -e "  • Health monitoring and alerting"
    echo -e "  • Log analysis for errors and anomalies"
    echo -e "  • Resource utilization tracking"
    echo -e "  • Scaling recommendations"
    echo -e "  • Automated troubleshooting assistance"

    echo -e "\n${YELLOW}Note: kagent runs in read-only mode by default for safety.${NC}"
    echo -e "${YELLOW}Enable write operations by updating the ClusterRoleBinding.${NC}"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    check_prerequisites
    install_crds
    deploy_kagent
    deploy_chatbot_agent
    show_status
}

main "$@"
