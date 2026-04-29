# Workoflow Skills

Shared Claude Code skills for the Workoflow ecosystem.

## Setup

```bash
git clone git@github.com:valantic-CEC-Deutschland-GmbH/workoflow-skills.git
# In any workoflow-* project:
/add-dir ../workoflow-skills
```

Copy `.env.example` to `.env` and fill in your values.

## Skills

| Skill | Trigger | Scope |
|-------|---------|-------|
| `architecture` | Architecture, infrastructure, ecosystem questions | All projects |
| `deploy` | Deploy to production/staging | Ops |
| `check-prod` | Production diagnostics | Ops (VPN) |
| `check-stage` | Staging diagnostics | Ops (VPN) |
| `sentry` | Sentry error investigation | Ops |
| `debug-stacktrace` | Phoenix trace debugging | Ops |
| `dev-setup` | Local development setup | All projects |
| `add-integration` | Add new platform integration | Platform |
| `add-translation` | Add/update i18n keys | Platform |
| `api-test` | PHPUnit tests, code quality | Platform |
| `people-finder` | Re-index employees, scoring | Orchestrator |
| `bot-dev` | Bot development, threading | Bot |
| `e2e-test` | Promptfoo E2E testing | Tests |
| `load-test` | k6 load testing | Load Tests |
| `mcp-dev` | MCP server development | MCP |

## Environment Variables

See `.env.example` for all required variables. Skills that need SSH access check VPN connectivity before proceeding.
