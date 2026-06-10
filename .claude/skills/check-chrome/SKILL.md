---
name: check-chrome
description: Manual UI/UX review of a web app flow using the Chrome browser. Use when the user says "/check-chrome", "check chrome", "review in chrome", "open chrome and try", "browser review", "review the user experience", or wants a manual walkthrough of a page or flow with screenshots and improvement proposals.
---

# Check Chrome - Manual UI/UX Review

Walk through a web flow in the user's Chrome browser, capture evidence at every step,
and report UX findings with concrete improvement proposals.

## Arguments

- **URL** (optional): the page to review, e.g. `/check-chrome https://workoflow.ddev.site/connectors`
- **Flow description** (optional): what to walk through, e.g. "try to add the Xurrent remote MCP server"

If no URL is given, read `LOCAL_APP_URL` from `workoflow-skills/.env`. When the target is
the local Workoflow platform, append `?X-Test-Auth-Email=<LOCAL_TEST_AUTH_EMAIL>` (also
from `.env`) to the first navigation for automatic login.

## Test users (local Workoflow platform)

| Email | Role |
|-------|------|
| `puppeteer.test1@example.com` | Admin |
| `puppeteer.test2@example.com` | Member |

Local dev test data may be mutated freely - creating, editing and deleting records during
the review is fine. Mention created leftovers in the report so the user can clean up.

## Procedure

1. **Setup**: load the claude-in-chrome tools via ToolSearch, call `tabs_context_mcp`
   first, then create a NEW tab (`tabs_create_mcp`) - never reuse unrelated tabs.
2. **Batch aggressively**: use `browser_batch` for navigate/click/type/screenshot
   sequences - one round trip per logical step.
3. **Walk the flow the user named** end to end, taking a screenshot at every meaningful
   state change. If no flow was named, review the given page: scan layout, copy, and all
   primary actions.
4. **Deliberately test the unhappy paths**: submit with invalid input, cancel mid-flow and
   check for leftover/zombie records, re-enter the flow twice and watch for duplicates,
   reload after errors to see what state survives.
5. **Watch the evidence beyond pixels**:
   - The Symfony profiler toolbar (bottom bar in dev) shows the response code per request -
     note 4xx/5xx.
   - `read_console_messages` with a `pattern` filter for JS errors when something looks broken.
6. **Judge the UX** at each step:
   - Is the user's context preserved (names, logos, prefilled values)?
   - Does the copy match the actual flow (e.g. no OAuth wording in a token flow)?
   - Are help texts actionable (where to GET a token, not just "enter token")?
   - Are error states recoverable, with entered values preserved?
   - Any dead ends, generic headings, or misleading defaults?

## Report format

End with a findings report:

1. **Verdict first**: does the flow work mechanically? (Distinguish "broken" from "works
   but feels broken".)
2. **Findings ordered by severity**, each with the screenshot step where it occurs.
3. **Concrete improvement proposals** - file-level pointers if the codebase is available
   (the platform repo is usually the sibling `workoflow-integration-platform`).
4. **Leftover test data** created during the review.

Do NOT change code during the review - findings and proposals only, unless the user asks
for fixes afterwards.

## Caveats

- Never trigger JS `alert()`/`confirm()` dialogs - they freeze the extension.
- If a screenshot times out, retry once standalone (renderer may have been busy).
- HTTPS errors on `*.ddev.site` mean ddev is not running - tell the user to `ddev start`.
