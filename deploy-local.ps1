# =============================================================================
# Quick Deploy Script - Local Kubernetes with AI Tools (PowerShell)
# =============================================================================

$ErrorActionPreference = "Continue"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "    Chatbot Todo App - Local Kubernetes Deployment" -ForegroundColor Cyan
Write-Host "    Tech Stack: Docker, Minikube, Helm, kubectl-ai, kagent" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

# Check for OpenAI API key
if (-not $env:OPENAI_API_KEY) {
    Write-Host ""
    Write-Host "WARNING: OPENAI_API_KEY environment variable is not set!" -ForegroundColor Yellow
    Write-Host "The application requires an OpenAI API key to function."
    Write-Host ""
    Write-Host "Please set it with:"
    Write-Host "  `$env:OPENAI_API_KEY='your-api-key-here'"
    Write-Host ""
    $confirm = Read-Host "Continue anyway? (y/N)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        exit 1
    }
}

Write-Host ""
Write-Host "Select deployment option:" -ForegroundColor Green
Write-Host "  1) Full setup (Minikube + App + AI Tools)"
Write-Host "  2) App only (assumes Minikube is running)"
Write-Host "  3) AI Tools only (kubectl-ai + kagent)"
Write-Host ""
$choice = Read-Host "Enter choice [1-3]"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "[Step 1/3] Setting up Minikube and deploying app..." -ForegroundColor Yellow
        & .\k8s\local\minikube-setup.ps1

        Write-Host ""
        Write-Host "[Step 2/3] kubectl-ai setup instructions:" -ForegroundColor Yellow
        Write-Host "  Install kubectl-ai manually:"
        Write-Host "  - Using Go: go install github.com/sozercan/kubectl-ai@latest"
        Write-Host "  - Or download from: https://github.com/sozercan/kubectl-ai/releases"

        Write-Host ""
        Write-Host "[Step 3/3] Deploying kagent..." -ForegroundColor Yellow
        kubectl apply -f k8s/ai-tools/kagent/agent-deployment.yaml
        if ($env:OPENAI_API_KEY) {
            kubectl create secret generic kagent-secrets `
                --from-literal=openai-api-key="$($env:OPENAI_API_KEY)" `
                --namespace=kagent-system `
                --dry-run=client -o yaml | kubectl apply -f -
        }
    }
    "2" {
        Write-Host ""
        Write-Host "Deploying application with Helm..." -ForegroundColor Yellow

        # Configure Docker for Minikube
        & minikube docker-env --shell powershell | Invoke-Expression

        # Build image
        docker build -t chatbot-todo-app:1.0 .

        # Create namespace
        kubectl create namespace chatbot-app --dry-run=client -o yaml | kubectl apply -f -

        # Deploy with Helm
        $apiKey = if ($env:OPENAI_API_KEY) { $env:OPENAI_API_KEY } else { "placeholder" }
        helm upgrade --install chatbot-todo-app .\helm\chatbot-todo-app `
            --namespace chatbot-app `
            --set openaiApiKey="$apiKey" `
            -f .\helm\chatbot-todo-app\values-local.yaml `
            --wait

        Write-Host ""
        Write-Host "Deployment complete! Access with:" -ForegroundColor Green
        Write-Host "  minikube service chatbot-todo-app -n chatbot-app"
    }
    "3" {
        Write-Host ""
        Write-Host "Installing AI tools..." -ForegroundColor Yellow

        Write-Host ""
        Write-Host "kubectl-ai setup instructions:" -ForegroundColor Blue
        Write-Host "  Install kubectl-ai manually:"
        Write-Host "  - Using Go: go install github.com/sozercan/kubectl-ai@latest"
        Write-Host "  - Or download from: https://github.com/sozercan/kubectl-ai/releases"

        Write-Host ""
        Write-Host "Deploying kagent..." -ForegroundColor Blue
        kubectl apply -f k8s/ai-tools/kagent/agent-deployment.yaml
        if ($env:OPENAI_API_KEY) {
            kubectl create secret generic kagent-secrets `
                --from-literal=openai-api-key="$($env:OPENAI_API_KEY)" `
                --namespace=kagent-system `
                --dry-run=client -o yaml | kubectl apply -f -
        }
    }
    default {
        Write-Host "Invalid choice. Exiting." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "                    Deployment Complete!" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Quick commands:" -ForegroundColor Blue
Write-Host "  kubectl get pods -n chatbot-app     # Check pods"
Write-Host "  kubectl ai 'show pods'              # Natural language K8s"
Write-Host "  minikube dashboard                  # Open dashboard"
Write-Host ""
