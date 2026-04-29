# Workoflow Skills

Shared Claude Code skills for the Workoflow ecosystem. Developers clone this repo and `/add-dir` it into any workoflow-* project.

## Skill Format

Skills live in `.claude/skills/{name}/SKILL.md` with YAML frontmatter:

```yaml
---
name: skill-name
description: When to trigger this skill
---
```

## Environment Variables

Skills that need secrets read from `workoflow-skills/.env` (copy `.env.example` to `.env`).

## Contributing

1. Create `.claude/skills/{name}/SKILL.md`
2. Add YAML frontmatter (name + description)
3. Update README.md skill table
4. If new env vars needed, add to `.env.example`
