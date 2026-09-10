## Dual-loop harness

This repo is built with the dual-loop plugin: a human-led design loop
(`/dual-loop:create-observations` → `/dual-loop:design-session`) feeds a
backlog that an autonomous build loop (`/dual-loop:build-session`) drains;
`/dual-loop:check-build-status` is the read-only view. Harness rules are
injected at session start by the plugin — never copy them here.

- **State:** `dual-loop-brain/` (decision log, observations, backlog, build
  reports, handoffs) and `contracts/`. Beads (`bd`) is the queue's source of
  truth; `dual-loop-brain/02-backlog/BACKLOG.md` is its generated view.
- **Done means:** tests green + empirical proof (app runs / query executed /
  screenshot for UI) + PR merged with CI green + verified where it runs.
  **Merge ≠ done.**
- **Project guardrails:** <!-- EDIT ME: hard rules specific to this app —
  auth, billing, destructive migrations, anything customer-visible you don't
  trust agents on yet. -->
