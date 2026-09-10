# Changelog

## 1.0.0 — 2026-09-09

Initial public release of the `dual-loop` plugin.

- Commands: `/dual-loop:adopt-harness`, `/dual-loop:design-session`, `/dual-loop:build-session`, `/dual-loop:check-build-status`.
- Skills: `create-observations`, `write-handoff`.
- Hooks: SessionStart rules injection, Stop hook for orphaned in-progress beads.
- Rules: guardrails and worker rules, delivered every session.
- References: the build playbook (`build-strategy.md`) and the handoff contract.
- Templates: `dual-loop-brain/`, `contracts/`, `settings.json` (auto mode, allow and deny lists), `CLAUDE.md` snippet.
- Runtime: herdr hosts the orchestrator and every worker lane. Workers run in auto mode on Sonnet 5 and up.
