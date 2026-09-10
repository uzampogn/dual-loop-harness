# Spec — Metric drawer redesign (EXAMPLE ITEM)

> This is a worked example showing what a design-loop session produces.
> Delete this folder once you've seen the shape.

## Observation (the seed)

> O: Metric drawer UI/UX is poor. Too much text, formula not rendered as
> mathematical expression.
> C: Users skip the drawer, so they act on numbers they don't understand.

## Locked decision

**D4** (see `dual-loop-brain/00-decision-log.md`): each drawer section gets
1 unique purpose, no duplicated information — *Definition* (human-readable,
for non-experts) · *Formula* (rendered as a mathematical expression, not
prose) · *How to use* (1 short paragraph) · *Source* (copyable query).
Rejected: a single long description block (that's the current failure mode);
tabs (hides content behind clicks for no space gain at this content size).

## Desired behavior

- The formula renders as a real expression (numerator over denominator), not
  a sentence.
- Each of the 4 sections is visually distinct and carries no information that
  belongs to another section.
- Copy in each section follows the project's writing conventions: concise,
  readable by a non-data-expert.

## Out of scope

- The drawer's open/close mechanics and the metric grid (other lanes own them).
- New wire fields — the drawer renders what the API already sends.

## Acceptance

- Component tests cover the 4 sections and the formula rendering.
- Screenshot of the new drawer at desktop width attached to the report —
  **this item matches alert rule A3 (UI): the PR parks for human review.**
