---
name: mcp-dev
description: Workoflow MCP server development. Use when the user mentions "mcp", "mcp server", "workoflow-mcp", "MCP development", or works on the MCP bridge.
---

# Workoflow MCP Server Development

## Overview

Python MCP server that dynamically exposes per-user Workoflow platform tools as native MCP tools for Claude Code, Cursor, Windsurf.

## Architecture

```
MCP Client (Claude Code / Cursor)
    │  MCP Protocol (SSE or Streamable HTTP)
    │  X-Prompt-Token header
    ▼
MCP Server (server.py)         Port 9006
  ├─ tools/list  → per-token tool discovery
  └─ tools/call  → proxy to platform API
          │
    WorkoflowClient (client.py)
          │  httpx.AsyncClient
          ▼
    Platform API (/api/mcp/tools, /api/mcp/execute)
```

## Key Design Decisions

- **Low-level MCP SDK** (`mcp.server.lowlevel.server.Server`) for per-request control
- **No server-side credentials** — token flows per-request via `X-Prompt-Token` header
- **No server-side cache** — MCP clients cache `tools/list` natively
- **Per-user isolation** — zero shared state between requests

## Source Layout

| File | Purpose |
|------|---------|
| `src/workoflow_mcp/server.py` | MCP server, list_tools/call_tool handlers |
| `src/workoflow_mcp/app.py` | Dual-transport ASGI app (Streamable HTTP + SSE) |
| `src/workoflow_mcp/client.py` | Async HTTP client for platform API |

## Commands

```bash
# Install
pip install -r requirements.txt

# Run locally
uvicorn workoflow_mcp.app:app --host 0.0.0.0 --port 9006

# Docker
docker build -t workoflow-mcp .
docker run -p 9006:9000 --env-file .env workoflow-mcp

# Tests
pytest
```

## Environment

| Variable | Default | Purpose |
|---|---|---|
| `WORKOFLOW_API_URL` | `http://localhost:8000` | Platform API base URL |
| `TOOL_TYPES` | (all) | Comma-separated tool type filter |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | (unset) | Enables OTLP tracing |

## Desktop Extension

Pre-built `.mcpb` bundle in `desktop-extension/` for Claude Desktop:
```bash
cd desktop-extension && npm install --production && npx @anthropic-ai/mcpb pack .
```
