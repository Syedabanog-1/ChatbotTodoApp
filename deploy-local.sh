#!/bin/bash
# =============================================================================
# Quick Deploy Script - Local Kubernetes with AI Tools
# =============================================================================

set -e

echo "======================================================================"
echo "    Chatbot Todo App - Local Kubernetes Deployment"
echo "    Tech Stack: Docker, Minikube, Helm, kubectl-ai, kagent"
echo "======================================================================"

# Check for OpenAI API key
if [ -z "$OPENAI_API_KEY" ]; then
    echo ""
    echo "WARNING: OPENAI_API_KEY environment variable is not set!"
    echo "The application requires an OpenAI API key to function."
    echo ""
    echo "Please set it with:"
    echo "  export OPENAI_API_KEY='your-api-key-here'"
    echo ""
    read -p "Continue anyway? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        exit 1
    fi
fi

echo ""
echo "Select deployment option:"
echo "  1) Full setup (Minikube + App + AI Tools)"
echo "  2) App only (assumes Minikube is running)"
echo "  3) AI Tools only (kubectl-ai + kagent)"
echo ""
read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        echo ""
        echo "[Step 1/3] Setting up Minikube and deploying app..."
        chmod +x k8s/local/minikube-setup.sh
        ./k8s/local/minikube-setup.sh

        echo ""
        echo "[Step 2/3] Installing kubectl-ai..."
        chmod +x k8s/ai-tools/kubectl-ai-setup.sh
        ./k8s/ai-tools/kubectl-ai-setup.sh

        echo ""
        echo "[Step 3/3] Deploying kagent..."
        chmod +x k8s/ai-tools/kagent/setup-kagent.sh
        ./k8s/ai-tools/kagent/setup-kagent.sh
        ;;
    2)
        echo ""
        echo "Deploying application with Helm..."
        eval $(minikube docker-env)
        docker build -t chatbot-todo-app:1.0 .

        kubectl create namespace chatbot-app --dry-run=client -o yaml | kubectl apply -f -

        helm upgrade --install chatbot-todo-app ./helm/chatbot-todo-app \
            --namespace chatbot-app \
            --set openaiApiKey="$OPENAI_API_KEY" \
            -f ./helm/chatbot-todo-app/values-local.yaml \
            --wait

        echo ""
        echo "Deployment complete! Access with:"
        echo "  minikube service chatbot-todo-app -n chatbot-app"
        ;;
    3)
        echo ""
        echo "Installing AI tools..."
        chmod +x k8s/ai-tools/kubectl-ai-setup.sh
        ./k8s/ai-tools/kubectl-ai-setup.sh

        chmod +x k8s/ai-tools/kagent/setup-kagent.sh
        ./k8s/ai-tools/kagent/setup-kagent.sh
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "======================================================================"
echo "                    Deployment Complete!"
echo "======================================================================"
echo ""
echo "Quick commands:"
echo "  kubectl get pods -n chatbot-app     # Check pods"
echo "  kubectl ai 'show pods'              # Natural language K8s"
echo "  minikube dashboard                  # Open dashboard"
echo ""
