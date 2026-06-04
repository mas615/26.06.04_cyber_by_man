# cyber-classifier-workflow

Codex skill for a Gray Swan Arena Cyber Bypass or similar cyber-classifier lab workflow.

## Install

Clone this repository, then copy the cloned folder into your Codex skills directory as `cyber-classifier-workflow`:

```powershell
git clone https://github.com/mas615/26.06.04_cyber_by_man.git
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.codex\skills"
Copy-Item -Recurse -Force ".\26.06.04_cyber_by_man" "$env:USERPROFILE\.codex\skills\cyber-classifier-workflow"
```

Restart Codex after installing the skill.

## Contents

- `SKILL.md`: trigger metadata and core workflow.
- `references/`: setup, capture, behavior discovery, storage, and experiment notes.
- `scripts/`: small helper scripts for project layout and SSE payload extraction.

## Safety Notes

Do not commit live captures, cookies, tokens, request/response payloads from private sessions, or account data. This repository is intended to store workflow instructions only.
