---
name: people-finder
description: People Finder re-indexing, scoring weights, and employee search. Use when the user mentions "people finder", "re-index employees", "Decidalo", "scoring weights", "employee search", or "qdrant employees".
---

# People Finder

## Re-indexing

The People Finder uses Qdrant for employee search. Data is tenant-scoped via `org_uuid`. To re-index:

```bash
# 1. Get a fresh Decidalo bearer token:
#    Log in to https://valantic.decidalo.app/
#    DevTools -> Network -> copy Authorization: Bearer eyJ... header

# Full re-index (drops + recreates collection)
docker exec -it adk-orchestrator python -m src.scraper.cli index --full \
  --org-uuid "<organisation-uuid>" --bearer-token "eyJ..."

# Single user update (no downtime)
docker exec -it adk-orchestrator python -m src.scraper.cli index --user-id 170 \
  --org-uuid "<organisation-uuid>" --bearer-token "eyJ..."
```

**Important**: Bearer token expires. Always pass a fresh one. `--full` causes brief search downtime. `--org-uuid` is required - get it from the platform's Organisation entity.

## Scoring Weights

Composite score has 11 components summing to 1.0:

| Component | Weight | Notes |
|-----------|--------|-------|
| Vector similarity | 0.30 | RRF-fused dense+BM25 score |
| Project name match | 0.15 | Token overlap with query |
| Skill level | 0.15 | Average level of matched skills |
| Core skill | 0.05 | Fraction of matched core skills |
| Top skill | 0.05 | Fraction of matched top skills |
| Experience years | 0.05 | Currently zero — future use |
| Availability | 0.05 | Currently null — future use |
| Role/title match | 0.05 | Query terms in job_title/roles |
| Language match | 0.05 | Binary match on languages |
| Industry match | 0.05 | Token match on industries |
| Certificate match | 0.05 | Token match on certificates |

## Search Architecture

- **Hybrid search**: dense (text-embedding-3-large) + BM25 sparse vectors in Qdrant
- **Fusion**: Reciprocal Rank Fusion (RRF) combines dense + sparse results
- **Native agent**: self-registers via `NativeAgentRegistry`, always available for COMMON tenants

## Code Location

- `src/agents/people_finder.py` — Agent definition
- `src/search/people/` — Scoring, hybrid search, models
- `src/scraper/` — Decidalo API client, mapper, indexer, CLI
- `src/tools/` — Tool wrappers (employee_search, employee_profile)
