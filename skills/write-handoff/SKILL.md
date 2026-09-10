---
name: write-handoff
description: Write this session's handoff note in dual-loop-brain/04-handoffs/ per the handoff contract — the orchestrator's run review at build-session close-out, or a design/human-session note when a session is interrupted or closes with loose ends. Use when a session is ending or being interrupted, or when the user asks for a handoff or run review.
---

**Step 0 — anchor:** locate the repo root (the directory containing
`dual-loop-brain/00-decision-log.md` at or under cwd — 0 or 2+
matches → ask the human). Prefix shell commands with `cd <root> && ` — in
some environments the cwd resets between commands (never rely on a
persistent `cd`). Write only under `<root>/dual-loop-brain/04-handoffs/`.

# /write-handoff — the note the successor (or the human) reads first

1. **Read the contract now:** `${CLAUDE_PLUGIN_ROOT}/references/handoff-contract.md`.
   Its section lists are the law; this skill only sequences the work. Skim
   the newest existing note in `dual-loop-brain/04-handoffs/` for the shape
   in use.
2. **Pick the role.** `orchestrator` if this session ran
   `/dual-loop:build-session` (or the invocation says so); otherwise
   `design`. Target file: `dual-loop-brain/04-handoffs/<date>-<role>.md`
   with `date +%F`. Already exists for today → update it in place: 1 note
   per session per day, never a second file.
3. **Gather state with commands, never from memory.** Orchestrator:
   `bd list --json` and `bd ready` (beads is the source of truth),
   `git log --oneline -20`, `git worktree list`, `ls .beads/lanes/`,
   `gh pr list` / `glab mr list` (state, CI, pending comments), every
   `dual-loop-brain/03-build-reports/*/report.md` touched this run (look for
   `default — unratified` and stale-doc flags). Design: the observation in
   flight, the decision log's newest rows, the options discussed, what the
   human said.
4. **Write the note in the contract's section order for that role.** Every
   "it works" carries its evidence beside it (screenshot path, check
   output). An unmerged item links its report and screenshots at the PR's
   file view on the branch — or the lane worktree path, labeled as such —
   never the `main` path, which is empty until merge. Unratified defaults
   become ready-to-paste **Proposed** rows for the decision log; anything
   contradicting a Locked decision is flagged, never resolved. Reference
   specs, plans, reports, and beads by path. Redact secrets.
5. **Report** the note's path and its headline lines back to the session.
   Nothing else: no beads writes, no backlog regeneration, no commit — the
   command that called you (or the human) decides those.
