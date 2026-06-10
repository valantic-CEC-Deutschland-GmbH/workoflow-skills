# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## 2026-06-10

### Added
- `check-chrome`: New skill for manual UI/UX reviews via the Chrome browser. Invoke with `/check-chrome <url>` (or no URL to use `LOCAL_APP_URL` from `.env`); walks the named flow with screenshots, deliberately tests error paths, and reports severity-ordered findings with improvement proposals. New `.env` keys: `LOCAL_APP_URL`, `LOCAL_TEST_AUTH_EMAIL`.

## 2026-05-26

### Changed
- `people-finder`: Updated re-indexing docs to reflect new required `--org-uuid` parameter for tenant-scoped employee indexing

## 2026-05-20

### Changed
- `debug-stacktrace`: Add local transport mode via dbhub for debugging Phoenix traces without SSH/VPN
- `debug-stacktrace`: Use explicit `YYYY-MM-DD` date format instead of relative formats for macOS compatibility

## 2026-04-29

### Added
- Initial release with 15 Claude Code skills for the Workoflow ecosystem
- Skills cover: architecture overview, deployment, production/staging diagnostics, Sentry error investigation, Phoenix trace debugging, local dev setup, integration development, translations, API testing, People Finder, bot development, E2E testing, load testing, and MCP development
- Deployment scripts for integration platform and Grafana metrics
- Shared environment configuration for production/staging servers, Sentry, and Phoenix
