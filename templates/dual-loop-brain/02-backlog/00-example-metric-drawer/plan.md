# Plan — Metric drawer redesign (EXAMPLE ITEM)

> **For the worker:** this plan is your complete spec — the conversation
> behind it is NOT in your worktree; everything you need is embedded here.
> Scope is settled — do NOT re-litigate. Timebox ~2.5h.
>
> This is a worked example: the code references a hypothetical React app.
> Real plans embed *complete* snippets and *exact* commands for YOUR repo —
> written so a bare session with zero context can execute them.

```yaml
model: claude-opus-5        # standard implementation from a complete plan
effort: high
branch: 00-example-metric-drawer   # always the item slug — the verify gate diffs main...<item-slug>
```

**Goal:** rebuild `MetricDrawer` into 4 single-purpose sections (Definition ·
Formula · How to use · Source) with the formula rendered as a mathematical
expression, so a non-expert understands a metric before acting on it (D4).

## File boundary — ONLY

- `frontend/src/components/MetricDrawer.tsx` (rewrite)
- `frontend/src/components/Formula.tsx` (new)
- `frontend/src/__tests__/metric-drawer.test.tsx` (new)
- `dual-loop-brain/03-build-reports/00-example-metric-drawer/` (your report folder: `report.md` + screenshots)
- Checkboxes in this file.

**NEVER:** `frontend/src/types.ts` (contract mirror — orchestrator-only),
`contracts/`, `server/`, `dual-loop-brain/00-decision-log.md`, `dual-loop-brain/02-backlog/BACKLOG.md`,
other components, merge/push `main`.

## Seams under test

The rendered output of `<Formula/>` and `<MetricDrawer/>` (testing-library
`render` + queries) — behavior a user sees. Not component internals, hook
state, or fetch call counts. Expected values come from the fixture in
`contracts/fixtures/`, never recomputed in the test.

## Ground truth (verified by the orchestrator — cite, don't re-derive)

- The wire shape the drawer receives is `Metric` in `frontend/src/types.ts`;
  the formula arrives as `{ numerator: string, denominator: string | null }`.
- Test conventions: see `frontend/src/__tests__/` — fixture loaded from
  `contracts/fixtures/`, `vi.stubGlobal("fetch", …)` for mounted tests.
- Styling: plain CSS classes on the project's custom-property tokens — no
  inline styles.

## G1 — Formula component, TDD (~45 min)

- [ ] **Step 1:** Write `metric-drawer.test.tsx` cases for `<Formula/>` FIRST
  (red): (a) numerator-only renders as a single expression; (b) numerator +
  denominator renders as a stacked fraction; (c) no formula → section absent.
  Run: `cd frontend && npx vitest run src/__tests__/metric-drawer.test.tsx` → red.
- [ ] **Step 2:** Implement `Formula.tsx` (stacked-fraction layout via CSS,
  no math library needed at this scale). Same command → green. Commit.

## G2 — 4-section drawer (~60 min)

- [ ] **Step 1:** Extend the test file (red): the 4 sections render in order
  Definition · Formula · How to use · Source; each renders only when its
  field is present; Source shows the query with a working copy button.
- [ ] **Step 2:** Rewrite `MetricDrawer.tsx` accordingly. Full suite:
  `cd frontend && npx vitest run` → 100% green. Commit.

## G3 — Empirical proof (~30 min)

- [ ] Run the app, open the drawer on a real metric, screenshot at 1440px →
  `dual-loop-brain/03-build-reports/00-example-metric-drawer/metric-drawer.png`.
- [ ] Write the final report entry in `dual-loop-brain/03-build-reports/00-example-metric-drawer/report.md`:
  what changed, test output, screenshot path, anything deferred.

**Done means:** all boxes ticked · full suite green · screenshot on disk ·
work committed on `00-example-metric-drawer`. The orchestrator takes it from there
(this item parks for human review before merge — alert rule A3).
