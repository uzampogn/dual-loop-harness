# Build reports — how workers talk to the orchestrator

Data folder: 1 folder per worker, `<NN-item-slug>/` — same name as the
item's backlog folder, branch, and worktree — holding `report.md` (what's
done · evidence · blockers) plus screenshots, so `ls` here reads as shipping
history. The report structure (done · evidence · blockers, `unverified` on
any claim without proof) lives in the worker rules the dual-loop plugin injects
at session start.
