param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectRoot
)

$resolvedRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
New-Item -ItemType Directory -Force -Path $resolvedRoot | Out-Null

$dirs = @(
  "reports",
  "notes",
  "browser-profiles\chrome-cdp",
  "captures\chrome_cdp\network\live",
  "captures\burp_sse\payload",
  "captures\burp_sse\raw",
  "behavior_catalog\wave1",
  "behavior_catalog\wave2",
  "behavior_worklogs\00_overall",
  "behavior_worklogs\99_templates",
  "tools\chrome_cdp"
)

foreach ($dir in $dirs) {
  New-Item -ItemType Directory -Force -Path (Join-Path $resolvedRoot $dir) | Out-Null
}

$masterLog = Join-Path $resolvedRoot "behavior_worklogs\00_overall\01_master_log.md"
if (-not (Test-Path $masterLog)) {
  Set-Content -Path $masterLog -Encoding UTF8 -Value @"
# Master Log

## Purpose

Overall session log for behavior switches, broad findings, and handoff notes.

## Entries

"@
}

$template = Join-Path $resolvedRoot "behavior_worklogs\99_templates\01_behavior_attempt_log_template.md"
if (-not (Test-Path $template)) {
  Set-Content -Path $template -Encoding UTF8 -Value @"
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

"@
}

Write-Output "Project layout ready: $resolvedRoot"
