#!/bin/bash
# =============================================================================
# kubectl-ai Setup and Configuration Script
# Natural Language Kubernetes Commands
# =============================================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}==============================================================================${NC}"
echo -e "${BLUE}                    kubectl-ai Setup Script${NC}"
echo -e "${BLUE}        Natural Language Interface for Kubernetes Commands${NC}"
echo -e "${BLUE}==============================================================================${NC}"

# -----------------------------------------------------------------------------
# Install kubectl-ai
# -----------------------------------------------------------------------------
install_kubectl_ai() {
    echo -e "\n${YELLOW}[1/3] Installing kubectl-ai...${NC}"

    # Check if Go is installed (required for some installation methods)
    if command -v go &> /dev/null; then
        echo -e "${BLUE}  Installing via Go...${NC}"
        go install github.com/sozercan/kubectl-ai@latest
    elif command -v brew &> /dev/null; then
        echo -e "${BLUE}  Installing via Homebrew...${NC}"
        brew tap sozercan/kubectl-ai
        brew install kubectl-ai
    else
        echo -e "${BLUE}  Installing via curl...${NC}"
        # Detect OS and architecture
        OS=$(uname -s | tr '[:upper:]' '[:lower:]')
        ARCH=$(uname -m)
        case $ARCH in
            x86_64) ARCH="amd64" ;;
            arm64|aarch64) ARCH="arm64" ;;
        esac

        # Download latest release
        RELEASE_URL="https://github.com/sozercan/kubectl-ai/releases/latest/download/kubectl-ai-${OS}-${ARCH}"
        curl -Lo kubectl-ai "$RELEASE_URL"
        chmod +x kubectl-ai
        sudo mv kubectl-ai /usr/local/bin/

        # Also install as kubectl plugin
        sudo cp /usr/local/bin/kubectl-ai /usr/local/bin/kubectl-ai
    fi

    echo -e "${GREEN}  ✓ kubectl-ai installed successfully${NC}"
}

# -----------------------------------------------------------------------------
# Configure kubectl-ai
# -----------------------------------------------------------------------------
configure_kubectl_ai() {
    echo -e "\n${YELLOW}[2/3] Configuring kubectl-ai...${NC}"

    # Check for OpenAI API key
    if [ -z "$OPENAI_API_KEY" ]; then
        echo -e "${RED}  Warning: OPENAI_API_KEY not set${NC}"
        echo -e "${YELLOW}  kubectl-ai requires an OpenAI API key to function${NC}"
        echo -e "${YELLOW}  Set it with: export OPENAI_API_KEY='your-key-here'${NC}"
    else
        echo -e "${GREEN}  ✓ OpenAI API key detected${NC}"
    fi

    # Create kubectl-ai config directory
    mkdir -p ~/.kubectl-ai

    # Create configuration file
    cat > ~/.kubectl-ai/config.yaml << 'EOF'
# kubectl-ai Configuration
# Natural Language Kubernetes Commands

# OpenAI Configuration
openai:
  # Model to use (gpt-4 recommended for complex queries)
  model: gpt-4
  # Temperature for response generation (0.0-1.0)
  temperature: 0.2
  # Maximum tokens for response
  max_tokens: 1024

# Safety Settings
safety:
  # Require confirmation before executing commands
  require_confirmation: true
  # Dry-run mode (show commands without executing)
  dry_run: false
  # Blocked commands that require extra confirmation
  blocked_patterns:
    - "delete namespace"
    - "delete pv"
    - "delete pvc"
    - "delete all"

# Context Settings
context:
  # Default namespace
  default_namespace: chatbot-app
  # Include resource descriptions in prompts
  include_descriptions: true

# Output Settings
output:
  # Show the generated kubectl command
  show_command: true
  # Show explanation of what the command does
  show_explanation: true
  # Color output
  color: true
EOF

    echo -e "${GREEN}  ✓ kubectl-ai configured at ~/.kubectl-ai/config.yaml${NC}"
}

# -----------------------------------------------------------------------------
# Display Usage Examples
# -----------------------------------------------------------------------------
show_usage_examples() {
    echo -e "\n${YELLOW}[3/3] kubectl-ai Usage Examples${NC}"
    echo -e "${BLUE}==============================================================================${NC}"

    echo -e "\n${GREEN}Basic Commands:${NC}"
    echo -e "  kubectl ai \"show all pods in chatbot-app namespace\""
    echo -e "  kubectl ai \"get the logs from the chatbot deployment\""
    echo -e "  kubectl ai \"show resource usage for all pods\""

    echo -e "\n${GREEN}Deployment Management:${NC}"
    echo -e "  kubectl ai \"scale the chatbot deployment to 3 replicas\""
    echo -e "  kubectl ai \"restart all pods in the chatbot deployment\""
    echo -e "  kubectl ai \"show deployment rollout history\""

    echo -e "\n${GREEN}Troubleshooting:${NC}"
    echo -e "  kubectl ai \"why is the chatbot pod failing?\""
    echo -e "  kubectl ai \"show events for chatbot-app namespace\""
    echo -e "  kubectl ai \"describe the failing pod\""

    echo -e "\n${GREEN}Resource Monitoring:${NC}"
    echo -e "  kubectl ai \"show CPU and memory usage\""
    echo -e "  kubectl ai \"list all services and their endpoints\""
    echo -e "  kubectl ai \"show persistent volume claims\""

    echo -e "\n${GREEN}Advanced Operations:${NC}"
    echo -e "  kubectl ai \"create a port-forward to the chatbot service on port 8000\""
    echo -e "  kubectl ai \"execute a shell in the chatbot pod\""
    echo -e "  kubectl ai \"show the yaml for chatbot deployment\""

    echo -e "\n${BLUE}==============================================================================${NC}"
    echo -e "${GREEN}kubectl-ai setup complete! Start using natural language K8s commands.${NC}"
    echo -e "${BLUE}==============================================================================${NC}"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    install_kubectl_ai
    configure_kubectl_ai
    show_usage_examples
}

main "$@"
