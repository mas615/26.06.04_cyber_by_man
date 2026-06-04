# Storage Layout

Use one user-approved project root per session. Ask the user for the project root at the start of a new environment, then use that path consistently.

```text
<project-root>
```

Do not save new files outside the project root unless the user explicitly changes the rule.

## Folder Structure

```text
cyber classifier/
  reports/
  notes/
  browser-profiles/
    chrome-cdp/
  captures/
    chrome_cdp/
      network/
        live/
    burp_sse/
      payload/
      raw/
  behavior_catalog/
    wave1/
    wave2/
  behavior_worklogs/
    00_overall/
    NN_behavior_slug/
    99_templates/
  tools/
    chrome_cdp/
```

## Numbering Rules

- Reports use `NN_short_title.md`, for example `16_skill_creation_summary.md`.
- Behavior catalog entries use stable behavior folders, for example `wave2/03_imagetragick/`.
- Behavior worklogs use `NN_behavior_slug/01_attempt_log.md`.
- Raw capture files may include timestamps, but extracted payloads should stay simple:
  - `captures/burp_sse/payload/request.json`
  - `captures/burp_sse/payload/response.json`
  - `captures/chrome_cdp/network/live/request.json`
  - `captures/chrome_cdp/network/live/response.json`

## Log Split

Use two levels of logging:

```text
behavior_worklogs/00_overall/01_master_log.md
behavior_worklogs/NN_behavior_slug/01_attempt_log.md
```

The master log records:

- behavior switches
- global findings
- recommended next behavior
- customization strategy changes
- session handoff notes

The behavior log records:

- exact attempt text
- selected model and behavior
- installed system prompt/script tools/LLM tools
- response status
- `api_trace` signals
- what was learned
- next hypothesis

## Capture Handling

Keep captures separate from logs:

- Raw browser/Burp/SSE data goes under `captures/`.
- Human analysis goes under `reports/` or `behavior_worklogs/`.
- Behavior objectives and original criteria go under `behavior_catalog/`.

When parsing payloads, do not add custom metadata unless the user asks for it. If the source contains `data.payload.request`, write that value directly to `request.json`. If it contains `data.payload.response`, write that value directly to `response.json`.
