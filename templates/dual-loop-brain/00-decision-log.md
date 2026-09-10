# Decision Log — <PROJECT NAME>

> Living record of decisions with rationale + trade-off. Newest at the bottom.
> This file is the **shared memory** of the dual loop: workers have no memory
> across sessions, so anything not written here gets re-argued 50 times.
> Decisions are **settled** — sessions cite D-numbers, they never re-litigate.
>
> **Precedence — when artifacts disagree:**
> 1. The newer decision wins on the same topic (follow Superseded pointers).
> 2. For questions about *current behavior*, live code beats any document —
>    read the code, then flag the stale doc in your report. The spec of the
>    item in flight still states intent: the verify gate holds the diff to
>    it.
> 3. Agents cite and propose, they never resolve: this file changes only by
>    a human's hand — directly, or through the human-led `/dual-loop:design-session`
>    locking what the human just chose. A worker's labeled default surfaces
>    in the run review as a ready-to-paste **Proposed** row; a human pastes
>    it here and locks it, or rejects it.
>
> Status legend: **Locked** (agreed) · **Proposed** (a built, running default
> awaiting ratification) · **Open** (still being decided) · **Superseded by
> Dn** (no longer current — follow the pointer).

## Alert rules — changes that wait for a human

Some changes are hard to revert. A worker that touches any surface below still
builds the full change, but the PR **parks for human review before merging**:

| Rule | Surface | Why |
|---|---|---|
| A1 | `contracts/` — how components talk to each other | Every parallel lane depends on it; a silent change breaks all of them. |
| A2 | Data schema (migrations, table shapes) | Data structure mistakes outlive the session that made them. |
| A3 | Visual design (UI components, layout, styling) | The area where agent judgment is weakest. Drop this rule once your visual direction is set and speed matters more. |
<!-- EDIT ME: add project-specific alert rules (auth, billing, anything
customer-visible you don't trust agents on yet). Remove A3 when you turn
autonomy up. -->

## Decisions

The rows below are **examples** showing the shape — replace them with your
own. Notice what each column does: the decision is one sentence, the
rationale says why it beat the alternatives, and the trade-off names what you
knowingly gave up (that's the part that stops a future session from
re-opening it).

| # | Date | Decision | Rationale | Trade-off / alternative rejected | Status |
|---|---|---|---|---|---|
| D1 | 2026-01-05 | Stack = FastAPI monolith + Postgres + React/Vite SPA. | One deployable unit keeps the loop simple; every worker knows the stack; Postgres covers relational + JSON needs. | Microservices rejected: contract surface would explode with 4 parallel lanes. | Locked |
| D2 | 2026-01-05 | Day 1 opens with a **walking-skeleton deploy** (repo + CI + hello-world live), hard end-of-day timebox; if not live → freeze infra, build against local, deploy later. | Only a real deploy answers "is the platform as easy as documented"; skeleton and feature streams don't contend. | If frozen, nothing is live on demo day; infra restarts cold later. | Locked |
| D3 | 2026-01-06 | Visual direction = **dense console** — tables per section, inline sparklines, flag pills. Picked from 3 screenshot-proven directions. | All metrics land on 1 screen — strongest for the scanning job-to-be-done. | Density risks approachability for first-time viewers; rejected: executive cards (hero-promotion reshuffling), editorial briefing (composed prose). | Locked |
| D4 | 2026-01-08 | Metric drawer = 4 single-purpose sections (Definition · Formula · How to use · Source); formula rendered as a mathematical expression. | Users skipped the drawer and acted on numbers they didn't understand (observation O6). | A single description block (current failure mode) and tabs (hides content for no space gain) rejected. | Locked |
<!-- Every /dual-loop:design-session appends its locked decision here. Seed yours with:
stack, deploy target, and visual direction — the 3 decisions workers hit
most often. -->
