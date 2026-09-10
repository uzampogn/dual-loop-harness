# Report — 00-example-metric-drawer (EXAMPLE)

> A worked example of a worker report. Delete this folder with the example
> backlog item once you've seen the shape.

## 2026-01-09 14:10 — G1 done

- **Done:** `Formula.tsx` + 3 test cases (numerator-only, stacked fraction,
  absent section). `npx vitest run src/__tests__/metric-drawer.test.tsx` →
  3 passed.
- **Evidence:** test output above; committed `a1b2c3d` on `00-example-metric-drawer`.

## 2026-01-09 15:25 — G2 done, one blocker

- **Done:** 4-section drawer rewrite; full suite green (41 passed).
- **Evidence:** `npx vitest run` output; commit `d4e5f6a`.
- **Blocker:** the Source section needs `metric.source_url`, which lives in
  `frontend/src/types.ts` — **outside my file boundary** (contract mirror,
  orchestrator-only). Skipped that sub-task; drawer renders without the link.
  → Orchestrator: bump the contract or confirm out of scope.

## 2026-01-09 15:50 — G3 done, item complete

- **Done:** screenshot at 1440px → `metric-drawer.png` (beside this file).
- **Evidence:** screenshot on disk; all plan boxes ticked; suite green.
- Work committed on `00-example-metric-drawer`. This item matches alert rule A3
  (UI) — PR parks for human review.
