---
name: deploy
description: Deploy code to the Workoflow production server. Use when the user says "deploy", "push to prod", "ship it", "release", "update production", or wants to deploy changes.
---

# Deploy to Production

## Deploy Scripts

```bash
# Integration Platform (git pull, build, restart)
workoflow-skills/.claude/skills/deploy/deploy-platform.sh prod     # Production
workoflow-skills/.claude/skills/deploy/deploy-platform.sh stage    # Staging

# Grafana Metrics
workoflow-skills/.claude/skills/deploy/deploy-metrics.sh deploy    # Pull + restart
workoflow-skills/.claude/skills/deploy/deploy-metrics.sh setup     # Initial setup
workoflow-skills/.claude/skills/deploy/deploy-metrics.sh restart   # Restart only
workoflow-skills/.claude/skills/deploy/deploy-metrics.sh logs      # Tail logs
workoflow-skills/.claude/skills/deploy/deploy-metrics.sh status    # Container status
```

All scripts check VPN connectivity before proceeding.

## Manual Deployment

### Environment

Read these variables from `workoflow-skills/.env`:

| Variable | Purpose |
|---|---|
| `PROD_SSH_HOST` | Production server SSH alias |
| `PROD_SSH_USER` | SSH user |
| `PROD_DEPLOY_DIR` | Platform deploy directory |
| `PROD_ORCHESTRATOR_DIR` | Orchestrator/n8n deploy directory |

## VPN Check

Before connecting, verify VPN:
```bash
ssh -o ConnectTimeout=5 -o BatchMode=yes $PROD_SSH_HOST echo "VPN OK" 2>/dev/null
```
If timeout → tell user: **VPN is not connected. Enable VPN and try again.** Do NOT proceed without VPN.

## CRITICAL: Always use docker-compose-prod.yml

```bash
# CORRECT — uses external volumes with production data
docker-compose -f docker-compose-prod.yml <command>

# WRONG — creates new prefixed volumes, LOSES production data!
docker-compose <command>
```

## Connection

```bash
ssh $PROD_SSH_HOST
sudo -iu $PROD_SSH_USER
cd $PROD_DEPLOY_DIR
```

## Deployment Sequence

### 1. Pull latest code
```bash
git pull
```

### 2. Build the container
```bash
docker-compose -f docker-compose-prod.yml build frankenphp
```

### 3. Bring up services
```bash
docker-compose -f docker-compose-prod.yml up -d frankenphp messenger-worker scheduled-worker
```

### 4. Update database schema (if entities changed)
```bash
docker-compose -f docker-compose-prod.yml exec frankenphp php bin/console doctrine:schema:update --dump-sql
docker-compose -f docker-compose-prod.yml exec frankenphp php bin/console doctrine:schema:update --force
```

### 5. Clear caches
```bash
docker-compose -f docker-compose-prod.yml exec frankenphp php bin/console cache:clear
docker-compose -f docker-compose-prod.yml exec frankenphp php bin/console cache:pool:clear cache.app
```

### 6. Verify
```bash
docker-compose -f docker-compose-prod.yml ps
docker-compose -f docker-compose-prod.yml logs -f --tail=50 frankenphp
docker stats --no-stream
```

## Quick deploy

```bash
ssh $PROD_SSH_HOST
sudo -iu $PROD_SSH_USER
cd $PROD_DEPLOY_DIR
git pull
docker-compose -f docker-compose-prod.yml build frankenphp
docker-compose -f docker-compose-prod.yml up -d frankenphp messenger-worker scheduled-worker
docker-compose -f docker-compose-prod.yml exec frankenphp php bin/console doctrine:schema:update --dump-sql
docker-compose -f docker-compose-prod.yml exec frankenphp php bin/console cache:clear
docker-compose -f docker-compose-prod.yml logs -f --tail=20 frankenphp
```

## Deploying orchestrator

```bash
cd $PROD_ORCHESTRATOR_DIR
docker-compose restart adk-orchestrator
docker-compose logs -f adk-orchestrator
```

After deploying new orchestrator agents, clear platform cache:
```bash
cd $PROD_DEPLOY_DIR
docker-compose -f docker-compose-prod.yml exec frankenphp php bin/console cache:pool:clear cache.app
```

## Rollback

```bash
git log --oneline -5
git checkout <commit-hash>
docker-compose -f docker-compose-prod.yml build frankenphp
docker-compose -f docker-compose-prod.yml up -d frankenphp messenger-worker scheduled-worker
docker-compose -f docker-compose-prod.yml exec frankenphp php bin/console cache:clear
```

## Pre-deploy checklist

1. `composer code-check` passes (PHPStan + PHPCS)
2. Tests pass: `./vendor/bin/phpunit`
3. CHANGELOG.md updated
4. Assets built: `npm run build`
