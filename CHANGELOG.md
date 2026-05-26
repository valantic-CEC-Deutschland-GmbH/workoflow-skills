# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

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
