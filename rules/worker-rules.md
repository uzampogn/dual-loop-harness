# Worker rules (build-lane sessions)

> You are a worker if you were dispatched with a plan file in `dual-loop-brain/02-backlog/<item>/plan.md`. Interactive human session? These rules still bind any build-lane work you do.

Read first: your **plan file** (`dual-loop-brain/02-backlog/<item>/plan.md`) — your only scope.

**Worker** — execute one plan, in your worktree, inside your file boundary.

- You get a goal, not a task list: done means the goal is **verifiably achieved**, not attempted, not mostly working.
- Execute the plan in order, TDD per step. A step is done when its tests pass — check its box in the plan then.
- Write tests that can fail: test at the seams your plan names — public interfaces only, never internals, private methods, or call counts. Expected values come from an independent source (a spec literal, a golden fixture) — never recomputed the way the code computes them.
- Mock only at system boundaries (external APIs, time, randomness), with `contracts/fixtures/` as the data source; never mock the project's own modules **on new test surfaces**. An established suite that already mocks an internal module is a settled per-file convention: follow it there and flag it in your report — never rewrite a passing suite to satisfy this rule. One test → one implementation per step — don't write all tests up front.
- Verify empirically: run the app, execute the query against the real database, screenshot any UI change. A claim you can't verify is marked `unverified`, never asserted.
- Keep `dual-loop-brain/03-build-reports/<item>/report.md` current as you go: what's done, evidence (test output, screenshot paths), blockers.
- Stay inside your plan's file boundary. A cross-boundary need is a blocker — record it and stop that task; don't work around it.
- Commit small and often on your branch.
- A missing low-risk decision is not a blocker: build the sensible default, label it `default — unratified` in your report, and keep going. Blocking is for credentials, approvals, and anything that contradicts the decision log.
- Stop only when the goal is achieved (full suite green + proof recorded + committed on your branch) or you're genuinely blocked on a human (credentials, an approval, a decision that contradicts the decision log).
- Never commit to `main`, never merge, never run `bd`, never edit `contracts/`, `dual-loop-brain/00-decision-log.md` (propose in your report instead), or `dual-loop-brain/02-backlog/BACKLOG.md`.
