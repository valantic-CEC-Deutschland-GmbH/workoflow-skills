---
name: architecture
description: Workoflow ecosystem architecture overview. Use when the user asks about architecture, infrastructure, how projects connect, system components, cross-project questions, or mentions multiple workoflow-* repositories.
---

# Workoflow Architecture

## Ecosystem

| Repo | Role | Tech |
|------|------|------|
| `workoflow-integration-platform` | Integration hub — tools, credentials, prompts, MCP server | PHP 8.5, Symfony 8.0, FrankenPHP |
| `workoflow-orchestrator` | AI agent orchestrator — multi-agent coordination | Python, Google ADK, FastAPI |
| `workoflow-bot` | MS Teams channel client | Node.js, Bot Framework SDK v4 |
| `workoflow-mcp` | MCP server for Claude Code / Cursor / Windsurf | Python, MCP SDK |
| `workoflow-hosting` | Shared infrastructure (Docker Compose) | Redis, Qdrant, Phoenix, LiteLLM |
| `workoflow-tests` | E2E semantic testing (Promptfoo) | Node.js, Azure OpenAI |
| `workoflow-load-tests` | Load testing (k6) | Node.js, k6 |
| `workoflow-metrics` | Grafana dashboards | Grafana |

## Data Flow

```
User (MS Teams) → Bot → Orchestrator → Platform API → External Services
                                     ↕                    (Jira, GitLab, etc.)
                              Infrastructure
                         (LiteLLM, Qdrant, Phoenix, Redis)
```

## System Components

```
┌─────────────────────────────────────────────────────────────────┐
│                       WORKOFLOW PLATFORM                        │
│                                                                 │
│  Channel Clients ──▶ AI Orchestrator ──▶ Integration Platform   │
│  (Teams Bot,        (Google ADK,        (Symfony 8.0,           │
│   MCP Client)        Main + Sub-Agents)  14 integrations,       │
│                           │               13 system tools)      │
│                    Infrastructure          │                    │
│                    (LiteLLM, Phoenix,      ▼                    │
│                     Qdrant, Redis)    External Services          │
│                                      (Jira, GitLab, etc.)      │
└─────────────────────────────────────────────────────────────────┘
```

## Orchestrator Pattern

- **Main Agent** coordinates, delegates to sub-agents
- **Platform sub-agents**: dynamically created per user's enabled integrations (Jira, Confluence, etc.)
- **Native agents**: People Finder, Web Agent — always available, self-register via `NativeAgentRegistry`
- **LLM**: Azure OpenAI via LiteLLM proxy
- **Session**: Redis-backed, 30-day TTL, thread-based via `conversationId`

## Tenant Types

- **COMMON**: Uses `workoflow-orchestrator` (Google ADK). This is the standard.
- **n8n**: Legacy, uses n8n workflows as orchestrator.

## Key Infrastructure Services

| Service | Port | Purpose |
|---------|------|---------|
| LiteLLM | 4000 | LLM proxy gateway (Azure OpenAI) |
| Phoenix | 6006 | Observability / tracing |
| Qdrant | 6333 | Vector database |
| Redis | 6381 | Session storage, cache |
| SearXNG | 8090 | Web search |
| Tika | 9998 | Document text extraction |
| RustFS | 9004 | Knowledge Base document storage |
| Docling | 5001 | Document parsing |
| Crawl4AI | 11235 | Web crawling |

## API Flow

1. **Tool discovery**: `GET /api/integrations/{org}` or `GET /api/mcp/tools`
2. **Tool execution**: `POST /api/integrations/{org}/execute` or `POST /api/mcp/execute`
3. **Sub-agent prompts**: `GET /api/skills`
4. **Main agent prompt**: `GET /api/tenant/{org}/settings?system_prompt=true`

## Design Principles

All projects follow: SOLID, Clean Code, KISS. Simplest solution that meets requirements.
