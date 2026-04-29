---
name: check-stage
description: Staging server diagnostics. Use when user says "check stage", "look at staging", "staging issue", "diagnose staging", or wants to inspect the staging environment.
---

# Staging Diagnostics

## Environment

Read these variables from `workoflow-skills/.env`:

| Variable | Purpose |
|---|---|
| `STAGE_SSH_HOST` | Staging server SSH alias |
| `STAGE_SSH_USER` | SSH user |
| `STAGE_DEPLOY_DIR` | Platform deploy directory |
| `STAGE_ORCHESTRATOR_DIR` | Orchestrator/n8n deploy directory |

## VPN Check

```bash
ssh -o ConnectTimeout=5 -o BatchMode=yes $STAGE_SSH_HOST echo "VPN OK" 2>/dev/null
```
If timeout → tell user: **VPN is not connected. Enable VPN and try again.** Do NOT proceed without VPN.

## Connection

```bash
ssh $STAGE_SSH_HOST
sudo -iu $STAGE_SSH_USER
cd $STAGE_DEPLOY_DIR
```

## Operations

Same structure and commands as production — see `check-prod` skill for full container list and operations. Key differences:

- Use `$STAGE_*` variables instead of `$PROD_*`
- Staging may not have all production services running
- **CRITICAL**: Still use `docker-compose-prod.yml` for the integration platform if staging uses the same compose pattern

## Quick Checks

```bash
# Container status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Resource usage
docker stats --no-stream

# Orchestrator logs
cd $STAGE_ORCHESTRATOR_DIR && docker-compose logs -f --tail=50 adk-orchestrator

# Platform logs
cd $STAGE_DEPLOY_DIR && docker-compose -f docker-compose-prod.yml logs -f --tail=50 frankenphp
```
