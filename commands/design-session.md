---
description: Run one design-loop session — turn a 2-line observation into a locked decision, a spec, and a plan in the backlog
argument-hint: [observations file — default: newest in dual-loop-brain/01-observations/] [observation id, e.g. O3]
---

# Design session: $ARGUMENTS

## Role rules

**Design session** — human-led: turn observations into build-ready backlog items.

- Interview in plain Q&A, propose 2–3 options; the human picks — never lock a decision without them.
- Outputs per item: `dual-loop-brain/02-backlog/<item>/` (spec + plan), 1 bead with deps + Owns boundary, a decision-log append. This is the only session type besides a human's hand that changes the decision log.
- Runs `bd` only to create the item's bead and wire its deps; the orchestrator stays the build loop's single beads writer.
- Never implements: no app code, no `contracts/` edits — propose contract changes for the orchestrator to freeze.

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

You are running one session of the **design loop**: observations in, decisions
out. The human decides what to build; you turn 2-line observations into
build-ready backlog items. The output of this session is one
`dual-loop-brain/02-backlog/<item>/` folder containing a spec and a plan.

## Step 1 — Pick the observation

Read the observations file given in `$ARGUMENTS` — none given → the newest
`<date>-observations.md` in `dual-loop-brain/01-observations/`. If an observation id was
given (e.g. `O3`), work on that one; otherwise list the observations not yet
covered by a backlog item and ask the human which to take (one session per
item — don't batch).

**Day 0 — no app yet?** The pitch is the observation: take `O0` (the 2-line
app idea) and run this session on it. Its output is the opening backlog
items — the walking skeleton (repo skeleton + CI green + hello-world deploy)
and the v1 `contracts/` freeze — per the playbook's bootstrap step.

## Step 2 — Interview the human (brainstorm)

Check the dependency **out loud**: Superpowers installed → use its
**brainstorming** workflow under the harness overrides below. Not installed →
say "Superpowers not installed — running the harness's inline shape (README
names the 2-command install)" and run the same shape yourself. Never
silently assume it loaded:

- Explore how the app currently works in the area the observation touches —
  read the code, run the app if needed. Ground the conversation in reality.
- Ask questions **one at a time**, like a pairing partner. Bounce ideas back
  and forth. The human has broad context you don't — extract it.
- Check `dual-loop-brain/00-decision-log.md` first: settled decisions are not
  re-opened, they are cited.
- Propose 2–3 options with trade-offs and your recommendation. For UI work,
  show mockups (Superpowers visual companion if installed, else HTML sketches or screenshots) rather than describing layouts
  in prose.
- Before the interview closes, agree the **seams under test**: name the
  public interfaces where behavior will be verified and get the human's
  explicit yes — the plan may not introduce a test seam the human never saw.

The human picks one option. That's the session's decision point.

**Harness overrides while Superpowers is active** (the harness wins on conflict):

- Every backlog item runs the full design shape — a spike/bounded
  classification never skips the spec, the plan, or the bead: an item
  without a plan cannot be dispatched.
- Artifacts land in `dual-loop-brain/02-backlog/<NN-item-slug>/`, never in
  `docs/superpowers/…`.

## Step 3 — Lock the decision

Append the decision to `dual-loop-brain/00-decision-log.md`: what was decided,
the rationale, the trade-off accepted, the alternative rejected. If the
decision changes a contract, a schema, or the visual direction, say so
explicitly — those trigger the alert rules at merge time.

## Step 4 — Write the spec and the plan

Take the next free number `NN` in `dual-loop-brain/02-backlog/` and create
`dual-loop-brain/02-backlog/<NN-item-slug>/`. The number is a historical record (when
design started): append-only, never reused, never renumbered — beads owns
priority and sequencing. The branch, worktree, and build-report folder all
reuse this exact `NN-item-slug` name. The folder holds:

- **`spec.md`** — what to build and why: the observation, the locked decision,
  the desired behavior, what's explicitly out of scope.
- **`plan.md`** — how to build it, written for a **bare worker with no tribal
  context**. Use the Superpowers **writing-plans** workflow if installed — with the
  harness's yaml plan header (`model:`/`effort:`/`branch:`) replacing its
  required header, and NO execution-handoff step: dispatch belongs to
  `/dual-loop:build-session`. Absent the plugin, the bullets below are the
  complete shape. The
  plan must carry:
  - a header with `model:` and `effort:` (see the rubric in
    `${CLAUDE_PLUGIN_ROOT}/references/build-strategy.md`),
  - the **file boundary** — exact paths the worker owns, and the paths it must
    never touch,
  - the **seams under test** — the public interfaces where behavior is
    verified, agreed with the human in the interview; the worker writes no
    test at any other surface,
  - complete code snippets and exact commands, not descriptions,
  - checkbox steps, TDD-ordered (test first, then implementation),
  - the empirical verification the worker must produce (test command,
    query, screenshot).

Close the step with a **spec-vs-plan consistency check on test seams**: every
mock instruction in the plan's snippets must match the spec's carve-outs and
the agreed seams — plans carry full code, so a contradiction here reaches the
worker verbatim (the harness's costliest defect class). The plan header must
carry the line: *plan code is a sketch — verify every claim empirically
against the live system.*

## Step 5 — Register the item

Beads is the source of truth, so the bead carries everything:

1. `bd create "<item title>"`, then put the **1-line user outcome** (what
   this item buys the user — distilled from the observation's C line and the
   locked decision), the **file boundary** (the paths the item owns), and the
   `dual-loop-brain/02-backlog/<NN-item-slug>/spec.md` + `plan.md` paths in its
   description or notes. Wire dependencies with `bd dep`.
2. Regenerate `dual-loop-brain/02-backlog/BACKLOG.md` from `bd list --json` — it is a
   generated human view (item, outcome, status, files owned, deps, bead id),
   never hand-edited.
3. Mark the observation covered in the observations file: append
   `→ <item-slug>` to its `O` line.
4. **Commit the session's outputs to `main` directly** — spec, plan,
   decision-log append, regenerated BACKLOG.md, `.beads/issues.jsonl` export
   — as 1 commit (`docs(design): <NN-item-slug>`). Design output is docs-only
   by nature; the no-docs-only-PR guardrail binds the build loop only
   (harness guardrails). `main` protected → a fast-track PR is the
   fallback; build-lane brain updates still ride their item's code PR.

If several items are queued, identify dependencies between them so the build
order is clear — items with disjoint file boundaries and no dependency can
run as parallel lanes.

## Step 6 — Hand off

Close the session with exactly three things:

1. **What landed where:** the `dual-loop-brain/02-backlog/<item>/` folder, the bead id, the
   decision number.
2. **What's still uncovered:** the observations without a backlog item yet.
3. **The build handoff, verbatim** — how many items `bd ready` now shows
   against the 3–4 an unattended run wants (below that the loop starves
   mid-run — name the uncovered observation to design next), and the next
   command, so the human can paste it:

   > N of the 3–4 items an unattended run wants are ready. To start the
   > build loop, open a fresh session and run:
   >
   > ```
   > claude --model claude-fable-5 --effort high
   > > /dual-loop:build-session
   > ```

**Interrupted mid-session?** Write `dual-loop-brain/04-handoffs/<date>-design.md`
with the `write-handoff` skill (role: design) — it follows the design contract
in `${CLAUDE_PLUGIN_ROOT}/references/handoff-contract.md`: the observation, what
the interview established, the options on the table — so the next session
resumes instead of restarting the conversation.
