---
name: deploy
description: Deploy code to the Workoflow production server. Use when the user says "deploy", "push to prod", "ship it", "release", "update production", or wants to deploy changes.
---

# Deploy to Production

## IMPORTANT: Always use the deploy scripts

Do NOT run manual SSH commands for deployment. Use the scripts below - they handle VPN checks, SSH, sudo, git pull, docker build, cache clearing, and schema updates automatically in a single command.

## Deploy Scripts

```bash
# Integration Platform - full automated deploy (git pull, build, up, schema, cache)
workoflow-skills/.claude/skills/deploy/deploy-platform.sh prod     # Production
workoflow-skills/.claude/skills/deploy/deploy-platform.sh stage    # Staging

# Orchestrator - pull new image, recreate container, clear agent cache
workoflow-skills/.claude/skills/deploy/deploy-orchestrator.sh prod     # Production
workoflow-skills/.claude/skills/deploy/deploy-orchestrator.sh stage    # Staging

# Grafana Metrics
workoflow-skills/.claude/skills/deploy/deploy-metrics.sh deploy    # Pull + restart
workoflow-skills/.claude/skills/deploy/deploy-metrics.sh setup     # Initial setup
workoflow-skills/.claude/skills/deploy/deploy-metrics.sh restart   # Restart only
workoflow-skills/.claude/skills/deploy/deploy-metrics.sh logs      # Tail logs
workoflow-skills/.claude/skills/deploy/deploy-metrics.sh status    # Container status
```

All scripts check VPN connectivity before proceeding.

## What each script does

### deploy-platform.sh
1. Checks VPN connectivity
2. SSHs into server as docker user
3. `git fetch` + `git reset --hard origin/<branch>`
4. Runs `setup.sh prod` which: builds container, `up -d` all services, clears cache, runs `doctrine:schema:update --force`, warms cache

### deploy-orchestrator.sh
1. Checks VPN connectivity
2. SSHs into server as docker user
3. `docker-compose pull adk-orchestrator` (fetches new image)
4. `docker-compose up -d adk-orchestrator` (recreates container with new image)
5. Waits for health check to pass
6. Clears platform agent cache (`cache:pool:clear cache.app`)

## When to deploy what

- **Platform code changed** (PHP, templates, assets, composer, npm) - run `deploy-platform.sh`
- **Orchestrator image rebuilt** (user mentions orchestrator rebuild/update) - run `deploy-orchestrator.sh`
- **Both changed** - run both scripts

## Post-deploy verification

After the script completes, verify with a quick SSH check if needed:
```bash
ssh val-workoflow-prod "sudo -iu docker bash -c 'cd /home/docker/docker-setups/workoflow-integration-platform && docker-compose -f docker-compose-prod.yml ps'"
```

## Pre-deploy checklist

1. `composer code-check` passes (PHPStan + PHPCS)
2. CHANGELOG.md updated
3. Changes committed and pushed

---

## Reference: Manual deployment (only if scripts fail)

### Environment variables

Read from `workoflow-skills/.env`:

| Variable | Purpose |
|---|---|
| `PROD_SSH_HOST` | Production server SSH alias (`val-workoflow-prod`) |
| `PROD_SSH_USER` | SSH user (`docker`) |
| `PROD_DEPLOY_DIR` | Platform directory (`/home/docker/docker-setups/workoflow-integration-platform`) |
| `PROD_ORCHESTRATOR_DIR` | Orchestrator directory (`/home/docker/docker-setups/n8n`) |

### CRITICAL: Always use docker-compose-prod.yml for the platform

```bash
# CORRECT - uses external volumes with production data
docker-compose -f docker-compose-prod.yml <command>

# WRONG - creates new prefixed volumes, LOSES production data!
docker-compose <command>
```

Note: The orchestrator directory uses plain `docker-compose.yml` (no `-f` flag needed).

### Manual platform deploy

```bash
ssh val-workoflow-prod
sudo -iu docker
cd /home/docker/docker-setups/workoflow-integration-platform
git pull
docker-compose -f docker-compose-prod.yml build frankenphp
docker-compose -f docker-compose-prod.yml up -d frankenphp messenger-worker scheduled-worker
docker-compose -f docker-compose-prod.yml exec frankenphp php bin/console doctrine:schema:update --force
docker-compose -f docker-compose-prod.yml exec frankenphp php bin/console cache:clear
docker-compose -f docker-compose-prod.yml exec frankenphp php bin/console cache:pool:clear cache.app
```

### Manual orchestrator deploy

```bash
ssh val-workoflow-prod
sudo -iu docker
cd /home/docker/docker-setups/n8n
docker-compose pull adk-orchestrator
docker-compose up -d adk-orchestrator
# Then clear platform agent cache:
cd /home/docker/docker-setups/workoflow-integration-platform
docker-compose -f docker-compose-prod.yml exec frankenphp php bin/console cache:pool:clear cache.app
```

**Never use `docker-compose restart` for the orchestrator** - it reuses the old image. Always `pull` + `up -d`.

### Rollback

```bash
cd /home/docker/docker-setups/workoflow-integration-platform
git log --oneline -5
git checkout <commit-hash>
docker-compose -f docker-compose-prod.yml build frankenphp
docker-compose -f docker-compose-prod.yml up -d frankenphp messenger-worker scheduled-worker
docker-compose -f docker-compose-prod.yml exec frankenphp php bin/console cache:clear
```
