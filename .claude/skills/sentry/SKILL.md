---
name: sentry
description: Investigate Sentry errors for the Workoflow platform. Use when the user mentions Sentry, error tracking, production errors, crash reports, unresolved exceptions, "WORKOFLOW-", or any Sentry issue URL.
---

# Sentry Error Investigation

You MUST use Sentry MCP tools (`mcp__sentry__*`) to gather error details. Never guess — always fetch from Sentry first.

## Environment

Read these variables from `workoflow-skills/.env`:

| Variable | Purpose |
|---|---|
| `SENTRY_ORG_SLUG` | Organization slug for API calls |
| `SENTRY_REGION_URL` | Self-hosted Sentry instance URL |
| `SENTRY_PROJECT_PLATFORM` | Symfony platform project slug |
| `SENTRY_PROJECT_ORCHESTRATOR` | AI orchestrator project slug |

**Self-hosted instance** — do NOT pass `regionUrl` to MCP tools.

## Projects

| Env Var | Description | Repo |
|---|---|---|
| `SENTRY_PROJECT_PLATFORM` | Symfony platform (PHP 8.5, FrankenPHP) | workoflow-integration-platform |
| `SENTRY_PROJECT_ORCHESTRATOR` | AI orchestrator (Python ADK) | workoflow-orchestrator |

## Investigation Workflow

1. **Read config** — get env vars from `workoflow-skills/.env`
2. **Identify scope** — URL/ID → `get_sentry_resource`, vague error → `search_issues` on BOTH projects
3. **Gather details** — issue details, tag distribution, related events, AI analysis (only when explicitly asked)
4. **Cross-reference code** — read source files for platform issues, provide file paths for orchestrator issues
5. **Report** — Issue title/ID, project, status, first/last seen, frequency, stacktrace summary, root cause, suggested fix

## Common Queries

```
# Unresolved issues in platform
mcp__sentry__search_issues(organizationSlug=$SENTRY_ORG_SLUG, projectSlugOrId=$SENTRY_PROJECT_PLATFORM, naturalLanguageQuery="unresolved issues")

# Unresolved issues in orchestrator
mcp__sentry__search_issues(organizationSlug=$SENTRY_ORG_SLUG, projectSlugOrId=$SENTRY_PROJECT_ORCHESTRATOR, naturalLanguageQuery="unresolved issues")

# Specific issue
mcp__sentry__get_sentry_resource(organizationSlug=$SENTRY_ORG_SLUG, resourceType="issue", resourceId="WORKOFLOW-123")
```

## Rules

- Always search BOTH projects when user doesn't specify which one
- Include Sentry web URL in reports
- Use `mcp__sentry__analyze_issue_with_seer` only when user explicitly asks for root cause
- Use `mcp__sentry__update_issue` only when user explicitly asks to resolve/assign
