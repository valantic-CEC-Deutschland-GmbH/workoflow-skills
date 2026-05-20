---
name: debug-stacktrace
description: Investigate a user prompt not answered correctly by the orchestrator. Fetches Phoenix traces, identifies failed prompts, diagnoses root cause.
argument-hint: <workflow_user_id>
---

# Debug Orchestrator Prompts

## Environment

Read these variables from `workoflow-skills/.env`:

| Variable | Purpose |
|---|---|
| `DEFAULT_ORG_UUID` | Default organisation UUID |
| `DEFAULT_WORKFLOW_USER_ID` | Default workflow user ID |

- **User ID**: $ARGUMENTS (if provided), otherwise `DEFAULT_WORKFLOW_USER_ID`
- **Org ID**: `DEFAULT_ORG_UUID`

## Transport Selection

- **Default (production)**: Always use SSH + `get_stacktrace.sh`. This is the standard path.
- **Local**: Only when the user explicitly asks to debug **local** traces (e.g., "debug local stacktrace", "check local phoenix", "local traces"). Requires `execute_sql_hosting_phoenix` dbhub MCP tool to be available. If it's not → tell the user dbhub is not configured and they need to set up `hosting-phoenix` in their `dbhub.toml`.

## Steps — Production (default)

### VPN Check

```bash
ssh -o ConnectTimeout=5 -o BatchMode=yes val-workoflow-prod echo "VPN OK" 2>/dev/null
```
If timeout → tell user: **VPN is not connected. Enable VPN and try again.**

### Execution

1. **Fetch traces** from Phoenix:
   ```bash
   workoflow-skills/.claude/skills/debug-stacktrace/get_stacktrace.sh --compact <user_id> YYYY-MM-DD
   ```
   Always pass today's date as `YYYY-MM-DD` (e.g., `2026-05-20`). Do NOT pass `today`, `24h`, or other relative formats — they are not compatible with macOS.
   If today returns no results, try a date range: `YYYY-MM-DD:YYYY-MM-DD` covering the last 7 days.
2. **Identify problematic prompt**: Look for poor/empty results in `call_llm`, `tool.execute`, `invocation [workoflow]` spans
3. **Cross-reference KB**: Use MCP tools `orchestrator_search_knowledge_base`, `orchestrator_list_knowledge_sources`
4. **Diagnose root cause**: Content not indexed? Bad retrieval query? Wrong tool? Embedding issues?
5. **Report**: Failed prompt, agent actions, expected result, root cause, suggested fix

## Steps — Local (only when explicitly requested)

1. **Check dbhub**: Verify `execute_sql_hosting_phoenix` is available. If not → inform user and stop.
2. **Extract SQL**: Read `workoflow-skills/.claude/skills/debug-stacktrace/get_stacktrace.sh` and locate the SQL query for the requested operation (`cmd_traces_compact`, `cmd_traces_full`, `cmd_list_users`, `cmd_schema`, or `cmd_sample`). Do NOT write your own queries — the script contains tested SQL with correct JSONB attribute paths and CTE structure.
3. **Execute**: Replace the shell variables (`$PROJECT`, `$WORKFLOW_USER_ID`, `$START_DATE`, `$END_DATE`, `$LIMIT`) with actual values and run via `execute_sql_hosting_phoenix`.
4. **Analyze**: Same as production steps 2–5.
