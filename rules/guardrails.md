# Dual-loop guardrails (every session)

> Injected by the dual-loop plugin at session start. App specifics (stack,
> test commands, done-means) live in this repo's CLAUDE.md.

## Read first

1. `dual-loop-brain/02-backlog/BACKLOG.md` — the human view of where the build stands. **Beads is the source of truth** (status, deps, file boundary); this file is generated from it and is never hand-edited.
2. `dual-loop-brain/00-decision-log.md` — decisions are **settled**; cite D-numbers, never re-litigate. Its precedence rules bind every session: when artifacts disagree, the newer wins; for current behavior, live code beats any document; agents propose — the log changes only by a human's hand or a human-led `/dual-loop:design-session`.

## Harness guardrails

- **Verify empirically before commit:** unverifiable claims are marked `unverified`, never asserted.
- **No beads references in PRs/MRs:** never mention bead IDs or `bd` commands in PR/MR titles, descriptions, commits, or comments — beads is repo-local.
- Changes to `contracts/` or the data schema trigger the alert rules in the decision log — build the change, but the PR waits for human review.
- UI merges wait for a human to eyeball the screenshot (drop this gate once your visual direction is settled and speed matters more).
- No docs-only PRs **from the build loop** — a build lane's docs ride with its item's code PR. Design-session outputs (spec, plan, decision-log append, backlog regeneration) are docs-only by nature and commit directly to `main` (fast-track PR where `main` is protected).
- **System vs data:** harness law lives in the dual-loop plugin; `dual-loop-brain/` holds per-app state — prunable data, never rules. The one binding state file is `dual-loop-brain/00-decision-log.md`.

## Plan mode

- The plan file is the only writeable artefact.
- **Open questions first:** probe direction with plain-text open-ended questions in the response body before finalizing anything (the `AskUserQuestion` tool is denied in this harness).
- Exit plan mode only when the plan is settled.
