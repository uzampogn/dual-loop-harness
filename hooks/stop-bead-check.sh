#!/usr/bin/env bash
# Stop hook — blocks a session ending with ORPHANED in_progress beads.
# A bead is orphaned when no live lane claims it: the orchestrator touches
# .beads/lanes/<bead-id> at dispatch and removes it at teardown/parking
# (/dual-loop:build-session steps 4, 9, 10) — an idle orchestrator with running workers
# is a legitimate wait, not an orphan. Worker sessions (linked worktrees:
# repo top has a .git FILE) are exempt — workers never run bd; the bead
# belongs to the orchestrator's queue.
# Deterministic (asks bd + the filesystem, never the transcript); fails
# OPEN on any error, including missing bd or jq.
# Output contract: {"decision":"block","reason":...} blocks; nothing allows.
set -u

command -v jq >/dev/null 2>&1 || exit 0
command -v bd >/dev/null 2>&1 || exit 0

input=$(cat)

# Loop guard: re-invocation after a block sets stop_hook_active.
if [ "$(jq -r '.stop_hook_active // false' <<<"$input" 2>/dev/null)" = "true" ]; then
  exit 0
fi

top=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -f "$top/dual-loop-brain/00-decision-log.md" ] || exit 0   # not a harness repo
[ -f "$top/.git" ] && exit 0   # linked worktree = worker session

orphans=""
while IFS= read -r id; do
  [ -z "$id" ] && continue
  [ -e "$top/.beads/lanes/$id" ] && continue   # live lane
  orphans="${orphans:+$orphans, }$id"
done < <(bd list --status=in_progress --json 2>/dev/null | jq -r '.[].id' 2>/dev/null)

if [ -n "$orphans" ]; then
  jq -nc --arg ids "$orphans" \
    '{decision:"block", reason:("These in_progress beads have no live lane claiming them: " + $ids + ". For each: `bd close <id>` if done; `bd update <id> --status=blocked` plus the reason if stuck; `bd update <id> --status=open` to release it; or, if its worker is genuinely still running, mark the lane live: `touch .beads/lanes/<id>`. Then `bd export -o .beads/issues.jsonl`.")}'
fi
exit 0
