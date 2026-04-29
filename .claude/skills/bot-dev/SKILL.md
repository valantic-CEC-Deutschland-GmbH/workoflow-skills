---
name: bot-dev
description: Workoflow Teams Bot development guide. Use when the user works on the bot, mentions "bot", "Teams bot", "threading", "session mapping", "bot.js", or MS Teams integration.
---

# Workoflow Bot Development

## Tech Stack

Node.js 18+, Bot Framework SDK v4, Express, PM2, Redis (ioredis), Azure OpenAI

## Key Files

| File | Purpose |
|------|---------|
| `bot.js` | Main bot logic, message routing, feedback |
| `index.js` | Express server, Azure OpenAI proxy, endpoints |
| `session-mapper.js` | Redis: teamsMessageId → conversationId mapping |
| `tenant-settings.js` | Multi-tenant webhook config + caching |
| `translations.js` | Multi-language strings (EN, DE, RO, LT) |
| `phoenix.js` | OpenInference observability |
| `azure-openai-proxy.js` | Azure OpenAI proxy for n8n |
| `feedback-tracker.js` | Redis-based feedback tracking |

## Commands

```bash
npm start          # Start bot
npm run watch      # Dev mode (nodemon)
npm run stop       # Kill port 3978
npm run lint       # ESLint
npm run deploy     # ngrok tunnel
```

## Threading Model

Thread replies continue existing conversations via Redis session mapping:

1. **New message**: Bot sends to orchestrator (no conversationId) → orchestrator generates UUID → Bot saves `teamsMessageId → conversationId` in Redis
2. **Thread reply**: Bot extracts parent message ID → Redis lookup → sends with existing conversationId → orchestrator loads full history

Redis keys: `thread-session:{teamsMessageId}` (30-day TTL)

## Environment

Key env vars (from `.env.dist`):
- `WORKOFLOW_N8N_WEBHOOK_URL` — fallback webhook URL
- `REDIS_URL` — session storage (redis://localhost:6381)
- `AZURE_OPENAI_*` — LLM proxy config
- `PHOENIX_COLLECTOR_ENDPOINT` — observability
- `LOAD_TEST_MODE` — skip Bot Framework replies for k6 testing
- `FEEDBACK_ENABLED`, `FEEDBACK_LEVEL` — feedback collection config

## Multi-Tenant

Per-tenant webhook URLs fetched from platform API at `/api/tenant/{uuid}/settings`. Cached with configurable TTL (`TENANT_SETTINGS_CACHE_TTL_MS`).
