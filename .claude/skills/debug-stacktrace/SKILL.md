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

## VPN Check

The script SSHes into production. Verify VPN first:
```bash
ssh -o ConnectTimeout=5 -o BatchMode=yes val-workoflow-prod echo "VPN OK" 2>/dev/null
```
If timeout → tell user: **VPN is not connected. Enable VPN and try again.**

## Steps

1. **Fetch traces** from Phoenix:
   ```bash
   workoflow-skills/.claude/skills/debug-stacktrace/get_stacktrace.sh --compact <user_id> today
   ```
   If "today" returns no results, try `24h` or `7d`.
2. **Identify problematic prompt**: Look for poor/empty results in `call_llm`, `tool.execute`, `invocation [workoflow]` spans
3. **Cross-reference KB**: Use MCP tools `orchestrator_search_knowledge_base`, `orchestrator_list_knowledge_sources`
4. **Diagnose root cause**: Content not indexed? Bad retrieval query? Wrong tool? Embedding issues?
5. **Report**: Failed prompt, agent actions, expected result, root cause, suggested fix
