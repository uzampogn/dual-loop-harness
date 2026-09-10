#!/bin/bash
# SessionStart: inject universal + worker rules into every session's context.
cat "${CLAUDE_PLUGIN_ROOT}/rules/guardrails.md" "${CLAUDE_PLUGIN_ROOT}/rules/worker-rules.md"
