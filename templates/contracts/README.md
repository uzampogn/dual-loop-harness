# Contracts — frozen interfaces between lanes

Parallel workers are safe only when the surfaces they share are frozen. Before
parallelizing, the orchestrator writes one file per shared surface here, then
**freezes the folder**: workers consume contracts, only the orchestrator edits
them (a change = version bump + notification to every affected lane). Touching
this folder triggers **alert rule A1** — the PR waits for human review.

## What belongs here

| File (create as needed) | Contents |
|---|---|
| `repo-layout.md` | Directory layout + a per-path **write-ownership table** (which lane owns which paths) + coordination rules |
| `api-contract.md` | The exact shape the frontend consumes and the backend emits — plus a **golden fixture** in `fixtures/` that both sides test against; neither side invents fields |
| `schema.md` | Data structures: tables, columns, migration rules |
| `fixtures/` | Golden fixtures + JSON schemas backing the contracts |

## Example — `repo-layout.md` (excerpt)

```markdown
# Contract · Repo Layout & File Ownership
> v1.0 · FROZEN 2026-01-06 · owner: orchestrator.

| Path | Contents | Who writes |
|---|---|---|
| `Dockerfile`, `.ci.yml`, `pyproject.toml` | Image + CI | **W1** (infra) |
| `server/` | FastAPI app, routes, tests | **W1** skeleton → backend lane |
| `frontend/` | React SPA | **W3** |
| `dual-loop-brain/03-build-reports/<item>/` | Per-lane report folder (report.md + screenshots) | each worker, **own folder only** |
| `contracts/` | This folder | **orchestrator only** |

1. A worker never writes outside its rows. Cross-boundary need → note it in
   your report and stop; the orchestrator routes it.
2. The SPA consumes `/api` exactly as `api-contract.md` specifies; the shared
   fixture is `fixtures/scoreboard.json` — neither side invents fields.
```

## Example — `api-contract.md` (excerpt)

```markdown
# Contract · /api response shape
> v1.0 · FROZEN 2026-01-06 · golden fixture: fixtures/scoreboard.json

GET /api/scoreboard?area=<id> →
{
  "area": { "id": "core", "name": "Core" },
  "as_of": "2026-01-31",
  "sections": [
    { "id": "usage", "name": "Usage",
      "metrics": [ { "id": "active_users", "name": "Active users",
                     "latest": 12800, "trend": { "mom_pct": 4.2 },
                     "formula": { "numerator": "users with ≥1 session",
                                  "denominator": null } } ] }
  ]
}
Both sides test against the fixture: backend asserts it emits this shape,
frontend renders from it. A new field = version bump by the orchestrator.
```

Start by copying your architecture decisions out of the decision log into
`repo-layout.md` and freezing your API shape with one golden fixture. Keep
each contract short enough that a worker actually reads it.
