---
name: create-observations
description: Create or open today's observations file in dual-loop-brain/01-observations/ with the O-numbering continued from previous days. Use when the user wants to jot a new observation, idea, or piece of feedback about the app.
---

**Step 0 — anchor:** locate the repo root (the directory containing
`dual-loop-brain/00-decision-log.md` at or under cwd — 0 or 2+
matches → ask the human). If the session didn't start there, read
`<root>/CLAUDE.md` and `<root>/dual-loop-brain/00-decision-log.md`
explicitly — never assume the repo's CLAUDE.md loaded. The harness
guardrails arrive via the dual-loop plugin's session-start injection. Write only under
`<root>/dual-loop-brain/01-observations/`. Prefix shell commands with
`cd <root> && ` — in some environments the cwd resets between commands
(never rely on a persistent `cd`). Inside the repo, its law
and decision log win over any workspace-level rules from the launch
directory.

# /dual-loop:create-observations — today's observations file

1. `date +%F` → today. Target: `dual-loop-brain/01-observations/<today>-observations.md`.
2. If the file doesn't exist, find the highest O-number across the dated
   files (`grep -h '^O[0-9]' dual-loop-brain/01-observations/*-observations.md`; the
   README's examples don't count; no dated files yet → start at `O0`, the app
   pitch — see the folder README). Create the file seeded with one empty
   pair: `O<next>: ` / `C<next>: `.
3. If the user dictated observations in the invocation, write them in as O/C
   pairs — 2 lines each, unpolished. Dictated with explicit ids (`O7: …`)?
   Keep those ids verbatim, even on a fresh file. No ids → number onward
   from the next free one. Otherwise just report the file path and the next
   free id.
4. Nothing else: no beads, no backlog edits. `/dual-loop:design-session` takes it from
   here — it defaults to the newest file in the folder.
