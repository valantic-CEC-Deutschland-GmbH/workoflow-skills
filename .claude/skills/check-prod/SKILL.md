---
name: check-prod
description: Production server diagnostics. Use when user says "check prod", "look at prod", "production issue", "diagnose production", or wants to inspect/debug/restart anything on production.
---

# Production Diagnostics

## Environment

Read these variables from `workoflow-skills/.env`:

| Variable | Purpose |
|---|---|
| `PROD_SSH_HOST` | Production server SSH alias |
| `PROD_SSH_USER` | SSH user |
| `PROD_DEPLOY_DIR` | Platform deploy directory |
| `PROD_ORCHESTRATOR_DIR` | Orchestrator/n8n deploy directory |

## VPN Check

```bash
ssh -o ConnectTimeout=5 -o BatchMode=yes $PROD_SSH_HOST echo "VPN OK" 2>/dev/null
```
If timeout → tell user: **VPN is not connected. Enable VPN and try again.** Do NOT proceed without VPN.

## Connection

```bash
ssh $PROD_SSH_HOST
sudo -iu $PROD_SSH_USER
cd $PROD_DEPLOY_DIR
```

## Docker Setup Directories

All under the parent of `$PROD_DEPLOY_DIR`:

| Directory | Purpose | Compose File |
|---|---|---|
| `workoflow-integration-platform/` | Symfony app | `docker-compose-prod.yml` |
| `n8n/` | AI stack (orchestrator, litellm, qdrant, phoenix, etc.) | `docker-compose.yaml` |
| `workoflow-metrics/` | Grafana | default |
| `workoflow-pptx/` | PPTX generator | default |
| `workoflow-rag/` | RAG services | default |

## CRITICAL: Always use docker-compose-prod.yml for integration platform

```bash
# CORRECT
docker-compose -f docker-compose-prod.yml ps
# WRONG — creates new volumes, loses data!
docker-compose ps
```

For the n8n stack, use normal `docker-compose` in `$PROD_ORCHESTRATOR_DIR`.

## All Production Containers

### Integration Platform
| Container | Port | Purpose |
|---|---|---|
| frankenphp | 3979→80 | Symfony app |
| messenger-worker | — | Async processing |
| scheduled-worker | — | Scheduled tasks |
| mariadb | 3306 | MariaDB 12 |
| redis | — | Redis 8 |

### AI Stack
| Container | Port | Purpose |
|---|---|---|
| adk-orchestrator | 8080 | AI orchestrator |
| litellm | 4000 | LLM proxy (1G limit, ~90%) |
| workoflow-docling | 5001 | Document parsing (2G limit) |
| qdrant | 6333 | Vector DB (1G limit) |
| phoenix | 6006 | Trace observability |
| minio | 9000/9001 | S3 storage |
| workoflow-rustfs | 9004/9007 | KB file storage |
| workoflow-crawl4ai | 11235 | Web crawling |
| teams-bot | 3978 | MS Teams bot |
| workoflow-mcp | 9006 | MCP server |
| mcp-atlassian | 9005 | Atlassian MCP |
| searxng | 8090 | Search engine |
| gotenberg | 3002 | PDF conversion |
| tika | 9998 | Content extraction |

## Common Operations

```bash
# Restart Symfony app
cd $PROD_DEPLOY_DIR && docker-compose -f docker-compose-prod.yml restart frankenphp

# View logs
docker-compose -f docker-compose-prod.yml logs -f frankenphp
docker-compose -f docker-compose-prod.yml logs -f messenger-worker

# Orchestrator logs
cd $PROD_ORCHESTRATOR_DIR && docker-compose logs -f adk-orchestrator

# Clear Symfony cache
docker-compose -f docker-compose-prod.yml exec frankenphp php bin/console cache:clear

# Database schema update
docker-compose -f docker-compose-prod.yml exec frankenphp php bin/console doctrine:schema:update --dump-sql

# Resource check
docker stats --no-stream
free -h
df -h /
```

## Known Resource Concerns

- **litellm**: 1G memory limit, often ~90% — restart if OOM-killed
- **workoflow-docling**: 2G limit, CPU-heavy during parsing
- **qdrant**: 1G limit, ~20% typical

## Diagnosis Workflow

1. Check `docker ps` for unhealthy/restarting containers
2. Check `docker stats --no-stream` for resource pressure
3. Check logs for the relevant service
4. For prompt issues → use `debug-stacktrace` skill
5. For Symfony errors → `docker-compose -f docker-compose-prod.yml exec frankenphp cat var/log/prod.log | tail -100`
