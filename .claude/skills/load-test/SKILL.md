---
name: load-test
description: k6 load testing for the Workoflow bot. Use when the user mentions "load test", "k6", "performance test", "stress test", or works in the workoflow-load-tests project.
---

# Load Testing (k6)

## Overview

k6-based performance testing for the MS Teams Bot. Uses `LOAD_TEST_MODE=true` on the bot to skip Bot Framework auth.

## Setup

```bash
# Install k6: https://k6.io/docs/getting-started/installation/
# Install deps
npm install

# Configure
cp .env.example .env
# Set BOT_ENDPOINT (default: http://localhost:3978/api/messages)

# Start bot in load test mode
cd ../workoflow-bot
LOAD_TEST_MODE=true npm start
```

## Commands

```bash
npm test              # Full load test
npm run smoke         # Connectivity check
npm run verify        # Verify setup
```

## Test Files

| File | Purpose |
|------|---------|
| `tests/smoke.test.js` | Basic connectivity |
| `tests/simple-message.test.js` | Load test with ramp-up |
| `tests/stress-breakpoint.test.js` | Stress/breakpoint test |

## Performance Thresholds

- Error rate: < 1%
- p(95) response time: < 500ms
- p(99) response time: < 1000ms

## Environment

- `BOT_ENDPOINT` — bot URL (http://localhost:3978/api/messages)
- `LOAD_TEST_API_KEY` — API key for load test mode
- `TEST_MESSAGE` — message to send (default: "test")
