# Architecture

How the dual-loop plugin is put together, and what it leaves in an app repo.
Last verified end to end 2026-09-10 (Claude Code 2.1.267, bd 1.1.2).

## Principles

- **Code vs state.** Harness code (rules, commands, skills, hooks, playbook,
  templates) lives in the plugin, versioned and upgraded as 1 unit. Harness
  state (observations, backlog, reports, handoffs, decision log) lives in the
  app repo and is never overwritten by an upgrade.
- **Lazy rules.** A rule is delivered by the mechanism that triggers its role:
  command invocation for the orchestrator and design sessions, session start
  for workers and ad-hoc sessions. Every rule has exactly 1 home.
- **Command naming: verb + component.** `design-session`, `build-session`,
  `check-build-status`, `create-observations`, `write-handoff`,
  `adopt-harness`. Plugin commands have no short form: always
  `/dual-loop:<command>`.
- **Tool-agnostic core.** `rules/` and `references/` are plain markdown with
  no Claude-specific syntax. `plugin.json`, `commands/`, `skills/`, and
  `hooks/` are the Claude Code adapter around them.

## Plugin layout

```
dual-loop-harness/
├── .claude-plugin/
│   ├── plugin.json            # name "dual-loop", version, description
│   └── marketplace.json       # the repo is its own marketplace
├── commands/
│   ├── design-session.md      # carries the design-role rules
│   ├── build-session.md       # carries the orchestrator rules + the per-item loop
│   ├── check-build-status.md  # read-only
│   └── adopt-harness.md       # scaffolds an app repo from templates/
├── skills/
│   ├── create-observations/SKILL.md
│   └── write-handoff/SKILL.md # run review / design note per references/handoff-contract.md
├── hooks/
│   ├── hooks.json             # SessionStart → inject-rules.sh · Stop → stop-bead-check.sh
│   ├── inject-rules.sh        # cats rules/*.md into every session's context
│   └── stop-bead-check.sh     # blocks ending a session with orphaned in-progress beads
├── rules/
│   ├── guardrails.md          # binds every session, ad-hoc ones included
│   └── worker-rules.md        # worker role: no trigger file, so injected
├── references/
│   ├── build-strategy.md      # the playbook, read by /dual-loop:build-session
│   └── handoff-contract.md    # read by the write-handoff skill
├── templates/                 # copied by /dual-loop:adopt-harness, verbatim
│   ├── CLAUDE-snippet.md      # appended to the app's CLAUDE.md
│   ├── settings.json          # plugin enablement + auto mode + allow/deny lists + AskUserQuestion deny
│   ├── dual-loop-brain/       # brain skeleton + example item + folder READMEs
│   └── contracts/README.md
├── docs/architecture.md       # this file
├── CHANGELOG.md · README.md · LICENSE
```

## Rule delivery

| Rule set | Home | Loads when |
|---|---|---|
| Guardrails, precedence, plan mode | `rules/guardrails.md` | Every session start (hook) |
| Worker role | `rules/worker-rules.md` | Every session start (hook) |
| Orchestrator role, model and effort | `commands/build-session.md` | `/dual-loop:build-session` |
| Design-session role | `commands/design-session.md` | `/dual-loop:design-session` |

Workers are interactive `claude` sessions in auto mode, started by
`herdr agent start` in linked worktrees with no command file, so the
SessionStart hook is the only guaranteed delivery. Verified: with the plugin
enabled only in the app repo's `.claude/settings.json`, a session in a
worktree of that repo has the guardrails heading and worker rules in
context. Outside the repo it does not.

## Build-loop runtime: herdr

The orchestrator runs in a herdr pane; every lane is a herdr worktree
workspace. Per item: `herdr worktree create` (worktree + branch + workspace +
pane) → `herdr agent start <bead-id> --kind claude --pane <pane> -- --model … --effort … --permission-mode auto`
→ `herdr agent prompt <bead-id> "/goal …" --wait`, backgrounded, as the loop
tick → gate, PR, merge → `herdr worktree remove --workspace <ws> --force`.

Why interactive workers, not headless `claude -p` (verified 2026-09-09 on
herdr 0.8.0): herdr has no lifecycle hook for Claude Code, so it classifies a
pane from its screen against a TOML manifest whose every rule keys on the
interactive UI — the `❯` prompt box for `idle`, the spinner in the terminal
title for `working`, dialog footers for `blocked`. A `claude -p` pane reads
`idle` (fallback rule) while it works, then the agent vanishes the moment
the process exits; `herdr agent wait … --until done` never fires. An
interactive session in auto mode is classified correctly through a whole
`/goal` run, and a `blocked` lane is a pane the human can answer.

## The app repo surface

```
your-app/
├── CLAUDE.md                  # the user's, plus an appended "## Dual-loop harness" section
├── .claude/settings.json      # enabledPlugins: dual-loop · auto mode · allow + deny lists · AskUserQuestion deny
├── dual-loop-brain/           # state only
│   ├── 00-decision-log.md     # the repo-root anchor every command searches for
│   ├── 01-observations/  02-backlog/  03-build-reports/  04-handoffs/
└── contracts/
```

Every command and skill anchors to the repo by locating
`dual-loop-brain/00-decision-log.md`, the 1 state file guaranteed to exist
from adoption on.

## Adoption and upgrades

`/dual-loop:adopt-harness` copies `templates/` into the repo, merges
settings, appends the CLAUDE.md snippet, runs `bd init` and cleans up after
it, and seeds the decision log. Same path for a greenfield repo and an
existing app. `claude plugin update dual-loop` upgrades the harness; the
plugin owns no file in the app repo, so state is untouched.

## Known caveats

Observed during verification. None blocks use, but each shapes how a
command is written.

- **`${CLAUDE_PLUGIN_ROOT}` substitutes in command and skill bodies**, so
  commands point at `references/` and `templates/` directly. The path is
  outside the app repo: the first read prompts once in an interactive
  session and is denied headless. Only interactive commands read it.
- **Adoption is interactive.** `cp -R` always needs manual approval, and any
  write under `.claude/` prompts even in `acceptEdits` mode (under auto
  mode: `unverified`). Headless, the command stops at the settings write.
- **Settings schema.** Claude Code rejects unknown keys in `settings.json`
  (`_comment` included), so the template carries none. The adoption report
  explains the file instead.
- **`bd init` side effects (1.1.x).** Writes `AGENTS.md`, `.agents/`,
  `.codex/`, a managed block in CLAUDE.md, a bare `"hooks": {}` into
  `.claude/settings.json`, root `.gitignore` lines, and auto-commits. The
  command runs it after committing the scaffold and cleans up; the empty
  hooks key is harmless.
- **The install is a cache snapshot.** `claude plugin update` is a no-op at
  an unchanged version. Release by bumping `version` in `plugin.json`; for
  local development, uninstall and reinstall (README §Developing).
- **Stop hook scope.** The plugin may be enabled at user scope, so the hook
  runs in every repo. It exits early unless the decision-log anchor exists.
- **Worktree trust is inherited.** Verified 2026-09-09: an interactive
  session in a linked worktree of a trusted repo opens straight at the
  prompt box; only an untrusted main checkout shows the trust dialog, which
  herdr reports as `blocked`. Trust the repo once in a human session before
  the first build run.
- **Auto mode is per model.** `--permission-mode auto` takes effect on
  Sonnet 5 and Opus 5 (footer: `auto mode on`). On Haiku 4.5 the session
  prints `auto mode unavailable for this model` and silently runs in manual
  mode, where every write prompts. The rubric's small tier is Sonnet 5.
- **herdr pane lifecycle.** `agent start` answers `agent_pane_busy` until
  the pane's shell reaches its prompt (retry). An agent name stays bound to
  the pane briefly after `/exit`, so names are bead ids and panes are never
  reused. Interactive shell startup noise (an oh-my-zsh update prompt) can
  swallow the first keystroke of the launch command: silence it
  (`DISABLE_UPDATE_PROMPT=true`) in the shell profile of the build machine.
- **herdr addressing.** Workspace ids are opaque (`w8`, `wC`); read
  `.result.root_pane.pane_id` and `.result.workspace.workspace_id` from the
  `worktree create` reply, never predict them.

## Future: other agent CLIs

`rules/`, `references/`, and the command bodies are the portable core. A
Codex adapter would be `adapters/codex/`, generating AGENTS.md and prompt
files from the same core. Out of scope for now.
