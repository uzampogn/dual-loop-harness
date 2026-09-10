# Handoff contract — session-scoped memory

Two session types close with two different notes, both in
`dual-loop-brain/04-handoffs/`, named `<YYYY-MM-DD>-<role>.md` (sortable — recovery
reads the newest). Item-scoped state never lives here — it belongs on the bead (PR URL, CI state, blockers) and in
`dual-loop-brain/03-build-reports/<item>/`.

Common rules: reference specs, plans, reports and beads **by path** instead
of repeating them · **redact secrets** · readers re-verify volatile claims
(CI state, branch position, pending comments) with commands — a note
describes the world as of its writing · prune a note once its run is fully
merged and closed.

## Design / human-session note — `<date>-design.md`

Written when a human-led session is interrupted or closes with loose ends.
Carries what only the dying session knows:

- **In flight** — the observation being worked, the options on the table.
- **Judgments formed** — half-decided directions, comments judged wrong and
  why.
- **Next actions** — what the successor should do first.

## Orchestrator run review — `<date>-orchestrator.md`

Written at every `/dual-loop:build-session` close-out. This is **the one document the
human reads to review the run**: plain language, minutes to read, every
claim of "it works" with its evidence beside it (screenshot path or check
output), no pasted diffs. Evidence links must **resolve for the reader at
writing time**: an item whose PR is unmerged links its report and screenshots
at the PR's file view on the branch (or, without a remote, the lane worktree
path — labeled as such), never the `main` path, which is empty until the
merge. Sections in this order:

1. **Headline** — N items shipped, N held for review, N blocked; 1 sentence
   on the most important change to the app.
2. **Needs your decision** — first: it is why the human opens the file. Per
   held (alert-rule) or blocked item: the originating observation, verbatim ·
   what was built, 2 plain sentences · evidence · the specific question to
   answer or the PR to approve. Blocked items add what was tried and the
   smallest decision that unblocks.
3. **Shipped** — per merged item: observation → what changed (2 sentences) ·
   evidence · PR link for anyone who wants the diff.
4. **Decisions & drift** — every `default — unratified` and stale-doc flag
   from the worker reports; defaults written as ready-to-paste **Proposed**
   rows for the decision log, so ratifying is a paste by the human. Anything
   that contradicts a Locked decision flagged loudly — never silently
   resolved by picking a side.
5. **Next queue** — the ready items vs the 3–4 an unattended run wants, each
   with its 1-line outcome; below target, name what to design next.
6. **Successor state** — lane assignments, open PRs (URL, CI, pending
   comments), next actions, and the **failure-mode ledger**: 1 line of short
   tags (or `none`), e.g. `stale-state`, `boundary-breach`, `lane-stall`,
   `queue-starved` — the harness's own regression signal.
