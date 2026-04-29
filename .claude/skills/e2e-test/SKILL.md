---
name: e2e-test
description: E2E semantic testing with Promptfoo. Use when the user mentions "e2e test", "promptfoo", "semantic test", "end-to-end test", or works in the workoflow-tests project.
---

# E2E Testing (Promptfoo)

## Overview

Promptfoo-based E2E semantic validation for Workoflow agents. Tests that AI responses remain consistent after RAG/vector store updates.

## Commands

```bash
npm run test:e2e          # Full test suite
npm run test:filter "X"   # Filter by name
npm run test:view         # Results UI (port 8080)
npm run test:dry-run      # Validate config syntax
npm run test:verbose      # Verbose output
npm run docker:build      # Build container
npm run docker:shell      # Shell access
npm run docker:clean      # Clean up
npm run lint              # ESLint (REQUIRED before commits)
npm run lint:fix          # Auto-fix
```

## Configuration

- **Test config**: `configs/promptfoo.config.js`
- **Test files**: `configs/tests/*.tests.js` (jira, confluence, gitlab, sharepoint, people-finder, etc.)
- **Docker**: `docker-compose.yml` + `Dockerfile.test`

## Environment

Key vars (from `.env.example`):
- `N8N_WEBHOOK_URL` — target webhook endpoint
- `AZURE_API_KEY` — Azure OpenAI for semantic validation
- `SEMANTIC_THRESHOLD` — similarity threshold (0-1, default 0.85)
- `TEST_TIMEOUT` — max test duration (ms)

## Writing Tests

Tests use semantic (LLM Rubric), latency, contains, and JavaScript function assertions. Both German and English supported.

## Debugging

```bash
# Interactive shell
npm run docker:shell
> promptfoo eval -c configs/promptfoo.config.js --filter "test name" -v

# Check webhook connectivity
curl -X POST $N8N_WEBHOOK_URL -H "Content-Type: application/json" -d '{"text":"test"}'
```
