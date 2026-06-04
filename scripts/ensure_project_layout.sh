#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: ensure_project_layout.sh <project-root>" >&2
  exit 2
}

[ $# -eq 1 ] || usage

project_root="$1"
mkdir -p "$project_root"
resolved_root="$(cd "$project_root" && pwd)"

dirs=(
  "reports"
  "notes"
  "browser-profiles/chrome-cdp"
  "captures/chrome_cdp/network/live"
  "captures/burp_sse/payload"
  "captures/burp_sse/raw"
  "behavior_catalog/wave1"
  "behavior_catalog/wave2"
  "behavior_worklogs/00_overall"
  "behavior_worklogs/99_templates"
  "tools/chrome_cdp"
)

for dir in "${dirs[@]}"; do
  mkdir -p "$resolved_root/$dir"
done

master_log="$resolved_root/behavior_worklogs/00_overall/01_master_log.md"
if [ ! -f "$master_log" ]; then
  cat > "$master_log" <<'EOF'
# Master Log

## Purpose

Overall session log for behavior switches, broad findings, and handoff notes.

## Entries

EOF
fi

template="$resolved_root/behavior_worklogs/99_templates/01_behavior_attempt_log_template.md"
if [ ! -f "$template" ]; then
  cat > "$template" <<'EOF'
# Behavior Attempt Log

## Behavior

- Wave:
- Name:
- Current status:

## Attempts

### Attempt 001

- Chat URL:
- Customization:
- Prompt:
- Result:
- api_trace signals:
- What this proves:
- Next change:

EOF
fi

echo "Project layout ready: $resolved_root"
