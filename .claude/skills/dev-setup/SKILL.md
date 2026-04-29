---
name: dev-setup
description: Local development setup for the Workoflow ecosystem. Use when the user says "dev setup", "local development", "getting started", "set up locally", "install", or wants to run services locally.
---

# Local Development Setup

## Shared Infrastructure (workoflow-hosting)

All workoflow projects depend on shared services from the `workoflow-hosting` repo:

```bash
cd workoflow-hosting
docker compose up -d redis qdrant phoenix phoenix-postgres litellm litellm-postgres litellm-redis searxng tika
```

| Service | Port | Purpose |
|---------|------|---------|
| Redis | 6381 | Session storage |
| Qdrant | 6333 | Vector database |
| Phoenix | 6006 | Observability |
| LiteLLM | 4000 | LLM proxy |
| SearXNG | 8090 | Web search |
| Tika | 9998 | Text extraction |

## Integration Platform

### With DDEV
```bash
cd workoflow-integration-platform
ddev start
# App: https://workoflow.ddev.site
# MinIO: http://localhost:9003
```

### With Docker Compose
```bash
cd workoflow-integration-platform
docker-compose up -d
# App: http://localhost:3979
```

## Orchestrator

```bash
cd workoflow-orchestrator

# Start KB services
docker compose up -d   # RustFS (9004), Docling (5001), Crawl4AI (11235)

# Python environment
uv venv
source .venv/bin/activate
uv pip install -e ".[dev]"

# Configure
cp .env.example .env
# Set LITELLM_API_KEY to match workoflow-hosting LITELLM_MASTER_KEY

# Run
python -m src.main
# → http://localhost:8080/health
```

## Bot

```bash
cd workoflow-bot
npm install
cp .env.dist .env
# Set WORKOFLOW_N8N_WEBHOOK_URL
npm run watch
# → http://localhost:3978/api/messages
```

## MCP Server

```bash
cd workoflow-mcp
pip install -r requirements.txt
cp .env.example .env
uvicorn workoflow_mcp.app:app --host 0.0.0.0 --port 9006
```

## Stopping Everything

```bash
# Stop project-local services
cd workoflow-orchestrator && docker compose down

# Stop shared infrastructure
cd workoflow-hosting && docker compose down
```
