#!/bin/bash

# Deployment script for workoflow orchestrator (adk-orchestrator)
# Pulls the latest image and recreates the container
# Usage: ./deploy-orchestrator.sh {prod|stage}

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

ENV="${1:-}"

if [ -z "$ENV" ]; then
    log_error "Environment parameter is required"
    echo "Usage: $0 {prod|stage}"
    exit 1
fi

if [ "$ENV" != "prod" ] && [ "$ENV" != "stage" ]; then
    log_error "Invalid environment: $ENV"
    echo "Usage: $0 {prod|stage}"
    exit 1
fi

if [ "$ENV" = "prod" ]; then
    HOST="val-workoflow-prod"
    ENV_NAME="Production"
else
    HOST="val-workoflow-stage"
    ENV_NAME="Staging"
fi

echo ""
log_info "=========================================="
log_info "Deploying orchestrator to: ${ENV_NAME} (${HOST})"
log_info "=========================================="
echo ""

log_info "Checking VPN and connection to ${HOST}..."
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes "$HOST" "exit" 2>/dev/null; then
    log_error "Cannot reach ${HOST}. Please ensure you are connected to the VPN."
    exit 1
fi
log_success "Successfully connected to ${HOST}"

log_info "Pulling new orchestrator image and recreating container..."
echo ""

ssh -t "$HOST" bash << 'ENDSSH'
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[REMOTE]${NC} $1"; }
log_success() { echo -e "${GREEN}[REMOTE]${NC} $1"; }

log_info "Switching to docker user..."

sudo -iu docker bash << 'DOCKEREOF'
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[DOCKER]${NC} $1"; }
log_success() { echo -e "${GREEN}[DOCKER]${NC} $1"; }

ORCH_DIR="/home/docker/docker-setups/n8n"
PLATFORM_DIR="/home/docker/docker-setups/workoflow-integration-platform"

cd "$ORCH_DIR"
log_info "Pulling latest orchestrator image..."
docker-compose pull adk-orchestrator

log_info "Recreating orchestrator container with new image..."
docker-compose up -d adk-orchestrator

log_info "Waiting for orchestrator to become healthy..."
for i in $(seq 1 30); do
    STATUS=$(docker inspect --format='{{.State.Health.Status}}' adk-orchestrator 2>/dev/null || echo "unknown")
    if [ "$STATUS" = "healthy" ]; then
        log_success "Orchestrator is healthy"
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "WARNING: Orchestrator did not become healthy within 30s - check logs"
        break
    fi
    sleep 1
done

log_info "Clearing platform agent cache..."
cd "$PLATFORM_DIR"
docker-compose -f docker-compose-prod.yml exec -T frankenphp php bin/console cache:pool:clear cache.app

log_success "Orchestrator deployment complete"

docker-compose -f "$ORCH_DIR/docker-compose.yml" logs --tail=5 adk-orchestrator

DOCKEREOF

ENDSSH

if [ $? -eq 0 ]; then
    echo ""
    log_success "=========================================="
    log_success "Orchestrator deployment to ${ENV_NAME} completed!"
    log_success "=========================================="
    echo ""
    exit 0
else
    echo ""
    log_error "=========================================="
    log_error "Orchestrator deployment to ${ENV_NAME} failed!"
    log_error "=========================================="
    echo ""
    exit 1
fi
