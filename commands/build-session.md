---
description: Start (or resume) the build loop — deliver every unblocked backlog item autonomously
argument-hint: [optional focus, e.g. "items 3-7 only" or "single lane"]
---

# Build session: $ARGUMENTS

You are the **orchestrator** for this repository. This command carries the
complete per-item loop: every operating constant and command lives here and
nowhere else. The playbook, `${CLAUDE_PLUGIN_ROOT}/references/build-strategy.md`, carries
what the loop assumes — topology, the model/effort rubric, coordination
rules, queue sources, recovery — **read it now**. Decisions in the decision
log are settled; never re-litigate them.

## Role rules

**Orchestrator** — run the build loop per this command, which carries the complete per-item mechanics; the playbook holds what the loop assumes.

- **Orchestrate only:** dispatch, verify, merge, queue management. Never write code in this session — MR-comment fixes and anything else that isn't orchestration go to background agents or workers.
- Single writer of beads. Regenerate `dual-loop-brain/02-backlog/BACKLOG.md` from beads in the same step that changes beads. In-flight PR state (URL, CI, pending comments) goes on the bead.
- Owns `contracts/`; escalates human-bound items.
- Close out with the run review `dual-loop-brain/04-handoffs/<date>-orchestrator.md` per the handoff contract — the one document the human reads to review the run.

### Model & effort

Orchestrator: always the frontier model at high effort. Workers: the orchestrator picks the cheapest tier the item needs (rubric in the playbook) and always passes `--model`, `--effort`, and `--permission-mode auto` explicitly — never inherit defaults. Workers run only on models that support auto mode, so every lane has 1 permission mode and no `acceptEdits` fallback. Auto mode is unavailable on Haiku 4.5 (the session silently falls back to manual mode and every write prompts): never dispatch a worker on it; the small tier is Sonnet 5.

## 0. Anchor to the repo (always, before anything else)

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
5. **Confirm the runtime.** herdr is the build loop's runtime: every lane is
   a herdr worktree workspace, and this session should itself run in a herdr
   pane so the human's terminal is the lane board. `herdr status server`
   must report a running server; none → stop and ask the human to launch
   `herdr` and start this session inside a pane.

## 1. Recover state

Read in order: repo `CLAUDE.md` → `dual-loop-brain/00-decision-log.md` (settled
decisions + alert rules) → the newest `dual-loop-brain/04-handoffs/*-orchestrator.md` →
`bd ready` + `bd list --status=in_progress` (**beads is the source of truth**)
→ `dual-loop-brain/02-backlog/BACKLOG.md` (its generated view), `git log`, `dual-loop-brain/03-build-reports/`.
Trust these over memory of past sessions — and treat every volatile claim
(CI state, branch position, pending comments, blocked reasons) as stale until
re-verified with a command, wherever it came from: docs, beads, and handoffs
describe the world as of their last edit. Acting on a stale claim is this
loop's #1 failure mode (e.g. resurrecting an already-fixed blocker as a live
P0).
Reconcile lanes: a `.beads/lanes/` entry with no matching worktree
(`git worktree list`) is stale from a dead run — delete it before dispatching.
A live agent in `herdr agent list` whose bead is not `in_progress` is an
orphan from a dead run: read its pane (`herdr agent read <name>`) before
deciding whether to resume it or exit it.

## 2. Report before dispatching

Tell the human where the build stands in one short paragraph: items done / in
progress / ready / blocked (with the one-line reason per blocked item), how
many lanes can run right now against the target of **4**, and which item you
are starting with.

## 3. Run the per-item loop

Run the loop below until no unblocked backlog items remain (or per
`$ARGUMENTS`). **Saturate the lanes:** aim for 4 workers in parallel — at
every tick, refill every free lane with an unblocked item whose file boundary
is disjoint from the running lanes.

**Background everything that isn't orchestration — hard rule.** Your context
window is the loop's fuel gauge: a 1-item run has cost ~17% of it on inline
verify work. Verify-gate re-runs (tests), empirical browser/screenshot
checks, and PR-comment triage each go to a background agent that returns a
1-line verdict plus an evidence path; this session holds only dispatch, bead
writes, contract edits, merges, and close-out.

**Bootstrap runs once, before the loop:** repo skeleton → CI green →
hello-world deploy (a *walking skeleton*: prove the deploy path on day 1, or
consciously freeze it and build against a local run). Then `bd init`.

1. **Take** — `bd ready`; claim the item (`bd update <id> --status=in_progress`),
   then regenerate `dual-loop-brain/02-backlog/BACKLOG.md` from beads in the same step.
   **`.claude/**` check:** if the item's Owns includes any path under
   `.claude/`, expect the lane to go `blocked` at that write: the product
   gates `.claude/**` behind a human prompt that no allowlist overrides
   (verified under `acceptEdits`; under auto mode `unverified`). Dispatch it
   while a human is at the keyboard to answer the pane, or park it (step 10).
2. **Lane** — pull latest `main`, then 1 command creates the worktree, its
   branch, and the herdr workspace + pane the worker lives in:

   ```bash
   herdr worktree create --cwd <root> --branch <item-slug> --path ../<repo>-<item> --label <item-slug>
   ```

   Read `.result.root_pane.pane_id` and `.result.workspace.workspace_id` from
   the JSON reply — ids are opaque (`wC:p1`), never predicted — and record
   both on the bead. **Provision the lane** before dispatch: install the stack's deps in the
   worktree (`npm ci` / `uv sync` / your equivalent) and copy in the untracked
   files the plan assumes (`.env.local`, secrets) — gitignored files don't
   follow `git worktree add`, and a worker can neither run tests nor fetch
   credentials itself.
3. **Spec → plan** — `dual-loop-brain/02-backlog/<item>/{spec,plan}.md`, normally produced by the
   design loop. Plan missing or thin → the orchestrator writes it first. The
   plan's file boundary must match the Owns boundary on the bead.
4. **Execute** — an interactive worker in the lane's pane, **auto mode**,
   model + effort per the playbook's rubric:

   ```bash
   herdr agent start <bead-id> --kind claude --pane <pane-id> -- --model <model> --effort <effort> --permission-mode auto
   herdr agent prompt <bead-id> "/goal deliver everything in dual-loop-brain/02-backlog/<item>/plan.md until all tests pass. Verify your work empirically. Tests follow the plan's seams and the worker rules in your context." --wait
   ```

   `/goal` is a **built-in Claude Code command** — it lives in the CLI, not in
   any commands folder, so an on-disk search won't find it; that's expected,
   not a missing file.

   - `agent start` needs the pane at its shell prompt. Right after
     `worktree create` it answers `agent_pane_busy` while the shell boots:
     retry every 2 s, up to 5 times. It returns once Claude's prompt box is
     up — check `.result.agent.agent_status` is `idle`, not `blocked` (a
     dialog; read the pane as below). Agent names must be unique among live
     agents and linger briefly after exit: the bead id is the name, and a
     pane is never reused.
   - Run the `prompt --wait` line **as a background process**. It returns
     when the lane settles, and that return **is** the loop tick (no polling).
     `done` or `idle` → the goal ended; read the report and run the gate.
     `blocked` → the worker hit a dialog (a permission the classifier
     refused, a question): `herdr agent read <bead-id> --source recent-unwrapped --lines 120`,
     answer with `herdr agent send-keys <bead-id> <key>` or park the item
     (step 10), then background `herdr agent wait <bead-id>` as the new tick.
     `agent_prompt_stalled` → the prompt never registered; read the pane and
     resend.
   - Mark the lane live: `mkdir -p .beads/lanes && touch .beads/lanes/<bead-id>`
     — the Stop hook now leaves this bead alone until teardown.
   - Auto mode's classifier approves routine work; `permissions.deny` in
     `.claude/settings.json` still binds. Every lane is a tab in the human's
     herdr session: `herdr agent list` is the lane board, and a `blocked`
     lane is a pane the human can open and answer.
5. **Verify gate (4-part, before any PR):** Run the gate via background
   agents (verdict + evidence path back); never inline: tests green · **empirical proof**
   (run the app / execute the query / screenshot the UI) · **boundary check** —
   `git diff --name-only main...<item-slug>` lists only paths inside the
   item's Owns boundary (from the bead); any path outside fails the gate
   — a failed boundary check gets **triage, not a dead end**: a *plan gap*
   (the change legitimately needs paths the plan missed — e.g. a deleted
   export's consumers, without which the gate can never go green) → amend the
   bead's Owns with a 1-line justification, regenerate the backlog view,
   re-run the check; *scope creep* (the diff wanders beyond the goal) →
   bounce it back to the worker with the offending paths listed ·
   **spec + test-quality compliance** by a fresh-eyes agent, dispatched with
   exactly:

   > Fresh eyes — you know nothing about this build. Read
   > `dual-loop-brain/02-backlog/<item>/spec.md`, then the diff
   > (`git diff main...<item-slug>`). Report every place the diff contradicts
   > or silently drops a spec requirement, and every test that cannot fail:
   > expected values recomputed the way the code computes them, mocks of the
   > project's own modules, assertions on internals instead of the spec's
   > public surface. HIGH = spec broken or a test that can't fail, LOW =
   > cosmetic drift. HIGH findings block the PR.

   Workers may lack browser tooling: when the plan demands UI
   evidence the worker can't produce, the worker marks the claim `unverified`
   (per harness law) and a background agent takes the screenshot at this
   gate — the evidence lands in the item's report folder either way.
6. **PR** — `gh pr create` (or `glab mr create`), then record the PR URL and
   state on the bead (`bd update <id> --notes` or a comment) — in-flight state
   lives on the bead, not in session memory. Merge gates: CI green ·
   review comments drained (step 7) · **alert-rule items wait for the human —
   never ship unseen**.
7. **Review-comment loop** — after *every* push to an open PR/MR, initial or
   fix: `sleep 120` (bots need ~2 min) → `gh pr view --comments` /
   `glab mr note list` → triage. For each important comment, first verify it
   is actually **right**; a wrong comment gets a reply, not a code change.
   Triage itself goes to a background agent (comment list in, verdicts out);
   real findings go to a background fix agent — never triage or fix inline.
   The fix push restarts this step; loop until no important comments
   remain.
8. **Merge** — merge when the pipeline succeeds; parallel lanes rebase on
   `main` before merging. Rebase conflicts have an owner: trivial ones the
   orchestrator resolves in the lane's worktree (the 1 exception to "never
   edits app files"); non-trivial ones → relaunch the worker with a
   rebase-first step prepended to its plan. Never leave a conflict unowned.
9. **Post-merge** — the item is done only after the deploy check: a real
   browser hit on the deployed app (or a local run if not deployed yet) →
   `bd close <id>` → regenerate `dual-loop-brain/02-backlog/BACKLOG.md` **in the same step**
   → free the lane: `herdr worktree remove --workspace <ws-id> --force`
   (removes the checkout and closes the lane's workspace) +
   `git branch -D <item-slug>` + `rm -f .beads/lanes/<bead-id>` (a stale worktree blocks re-dispatch; plain
   `-d` refuses after a squash-merge, and post-merge the branch is
   disposable).
   A stale backlog breaks the human's read of the build.
10. **Blocked on a human?** `bd update <id> --status=blocked` with one line on
    what's needed, exit the worker (`herdr agent prompt <bead-id> "/exit"`,
    keep the worktree for resume), and `rm -f .beads/lanes/<bead-id>` — a
    parked item has no live lane. Regenerate the backlog view, take the next unblocked item —
    never stall a lane silently. Park only what's genuinely human-bound: a
    missing low-risk decision gets a labeled, unratified default instead
    (worker rule, injected every session); surface those defaults in the close-out
    handoff for ratification.

## 4. Close out

Before ending, every in-progress item is merged + closed, parked `blocked` with
a reason, or has a current report a successor can resume from. Then:

1. Write the **run review** `dual-loop-brain/04-handoffs/<date>-orchestrator.md`
   with the `write-handoff` skill (role: orchestrator) — it reads the
   orchestrator contract in `${CLAUDE_PLUGIN_ROOT}/references/handoff-contract.md`
   and gathers state by command. The one document the human reads to review
   the run; unmerged items link evidence at the PR file view (or labeled
   worktree path) — never the main path (empty until merge).
2. Regenerate `dual-loop-brain/02-backlog/BACKLOG.md` from `bd list --json`.
3. `bd export -o .beads/issues.jsonl` — beads is the restart point.
