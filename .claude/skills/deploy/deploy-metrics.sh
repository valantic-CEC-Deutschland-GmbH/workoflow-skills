#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
REMOTE_HOST="val-workoflow-prod"
REMOTE_USER="docker"
REMOTE_DIR="/home/docker/docker-setups/workoflow-metrics"

usage() {
    echo "Usage: $0 {setup|deploy|restart|logs|status}"
    echo ""
    echo "Commands:"
    echo "  setup    - Initial setup: clone repo and copy .env on remote"
    echo "  deploy   - Pull latest changes and restart Grafana"
    echo "  restart  - Restart Grafana container"
    echo "  logs     - Tail Grafana logs"
    echo "  status   - Show container status"
    exit 1
}

run_remote() {
    ssh "$REMOTE_HOST" "sudo -iu $REMOTE_USER bash" <<REMOTE_EOF
$1
REMOTE_EOF
}

cmd_setup() {
    echo "==> Setting up workoflow-metrics on $REMOTE_HOST..."

    if [ ! -f "$PROJECT_DIR/.env" ]; then
        echo "ERROR: .env file not found at $PROJECT_DIR/.env"
        echo "Copy .env.example to .env and fill in production values first."
        exit 1
    fi

    # Clone repo if not exists
    run_remote "
        if [ ! -d $REMOTE_DIR ]; then
            cd /home/docker/docker-setups && git clone https://github.com/valantic-CEC-Deutschland-GmbH/workoflow-metrics.git
        else
            echo 'Repository already exists, pulling latest...'
            cd $REMOTE_DIR && git pull
        fi
    "

    # Copy .env to remote
    echo "==> Copying .env to remote..."
    scp "$PROJECT_DIR/.env" "$REMOTE_HOST:/tmp/workoflow-metrics-env"
    run_remote "cp /tmp/workoflow-metrics-env $REMOTE_DIR/.env"
    ssh "$REMOTE_HOST" "rm -f /tmp/workoflow-metrics-env"

    # Start Grafana
    echo "==> Starting Grafana..."
    run_remote "cd $REMOTE_DIR && docker compose up -d"

    echo "==> Setup complete. Grafana available at http://$REMOTE_HOST:3030"
}

cmd_deploy() {
    echo "==> Deploying workoflow-metrics..."

    # Push local changes first
    echo "==> Pushing local changes..."
    cd "$PROJECT_DIR"
    git push

    # Pull and restart on remote
    run_remote "cd $REMOTE_DIR && git pull && docker compose up -d"

    echo "==> Deploy complete."
}

cmd_restart() {
    echo "==> Restarting Grafana..."
    run_remote "cd $REMOTE_DIR && docker compose restart grafana"
}

cmd_logs() {
    ssh "$REMOTE_HOST" "sudo -iu $REMOTE_USER bash -c 'cd $REMOTE_DIR && docker compose logs grafana --tail 100 -f'"
}

cmd_status() {
    run_remote "cd $REMOTE_DIR && docker compose ps"
}

case "${1:-}" in
    setup)   cmd_setup ;;
    deploy)  cmd_deploy ;;
    restart) cmd_restart ;;
    logs)    cmd_logs ;;
    status)  cmd_status ;;
    *)       usage ;;
esac
