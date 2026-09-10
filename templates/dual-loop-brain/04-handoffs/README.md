# Handoffs

Data folder — session-scoped memory, pruned once a run is fully merged and
closed. One note per session close or interruption, named
`<YYYY-MM-DD>-<role>.md`;
the orchestrator's note is the **run review**, the document the human reads
to review the run. Both structures follow the handoff contract that
`/dual-loop:write-handoff` applies.
