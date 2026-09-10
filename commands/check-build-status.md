---
description: Where the build stands — read-only, no dispatching
---

# Status

Report where the build stands. **Read-only:** do not claim, dispatch,
merge, or edit anything.

## Step 0 — Anchor to the repo (always, before anything else)

This command must work from any launch directory — a workspace root, a parent
folder — not just the repo (the repo's CLAUDE.md and its `.claude/settings.json`
load only when the session starts inside the repo; never assume they did).

1. **Locate the repo root.** If an argument names a path, use it. Otherwise
   find the directory containing
   `dual-loop-brain/00-decision-log.md` at or under the cwd:
   `find . -maxdepth 4 -path "*/dual-loop-brain/00-decision-log.md" 2>/dev/null`.
   0 matches → stop and ask the human for the repo path. 2+ → list them and
   ask which. Call the result `<root>`.
2. **Load the law explicitly, now:** read `<root>/CLAUDE.md` and
   `<root>/dual-loop-brain/00-decision-log.md`. The harness
   guardrails and worker rules arrive via the dual-loop plugin's
   session-start injection — they are already in your context.
3. **Anchor every path.** Prefix every shell command with `cd <root> && `
   (or use `git -C <root>`): in some environments the shell cwd resets
   between commands (worker sessions may keep it; orchestrator sessions
   have been observed losing it) — never rely on a persistent `cd`,
   including inside worktrees
   (`cd <root>/../<worktree> && …`).
4. **Precedence:** for work inside this repo, its law and decision log win
   over any workspace-level rules loaded by the launch directory.

1. Run `bd ready` and `bd list --status=in_progress` first — beads is the
   source of truth. Then read `dual-loop-brain/02-backlog/BACKLOG.md` (its generated human
   view), the newest `dual-loop-brain/04-handoffs/` note, and scan the latest entries in
   `dual-loop-brain/03-build-reports/*/report.md` and `git log --oneline -15`.
2. Summarize in one short block: items done / in progress / ready /
   blocked (one-line reason each) · evidence worth a look (screenshots,
   failed gates, parked PRs) · suggested next action (`/dual-loop:build-session`, a
   `/dual-loop:design-session`, or a human review of a parked PR).
