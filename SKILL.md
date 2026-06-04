---
name: cyber-classifier-workflow
description: "Use when working on a Gray Swan Arena Cyber Bypass or similar cyber-classifier lab session: start Chrome with remote debugging on Windows, ask the user to log in, capture chat/network/SSE api_trace data, parse request and response payloads, collect behavior criteria, configure safe system prompt/script tool/LLM tool experiments, and organize numbered reports and behavior worklogs under the project folder."
---

# Cyber Classifier Workflow

Use this skill to onboard a fresh Codex session into the same collaboration workflow used for the cyber-classifier project. The skill covers setup, observation, capture, parsing, behavior discovery, customization tracking, and file organization. It does not decide the final problem-solving strategy for a behavior.

## Ground Rules

- Work inside the user-approved project root. At the start of a new session, ask the user which folder should be treated as the project root.
- Never ask the user for passwords, magic links, cookies, JWTs, or session tokens. Start the browser and ask the user to log in manually.
- Preserve raw captures separately from analysis. Do not add arbitrary wrapper fields to extracted `request.json` or `response.json`.
- Keep all new reports numbered. Keep broad conclusions in the overall log and detailed attempts in behavior-specific logs.
- Treat the environment as an authorized lab/challenge. Record evidence and analysis; do not invent exploit payloads, jailbreak templates, or harmful operational steps.

## Standard Flow

1. Confirm or create the project layout.
   - Read `references/storage-layout.md`.
   - If needed, run `scripts/ensure_project_layout.ps1`.

2. Start or attach to Chrome CDP.
   - Read `references/windows-chrome-cdp.md`.
   - Start Chrome with `--remote-debugging-port=9222`.
   - Ask the user to complete login in the browser.

3. Attach observation and capture.
   - Read `references/chat-capture-parsing.md`.
   - Prefer Chrome CDP live captures when available.
   - Use Burp active editor or saved SSE text only as a fallback or cross-check.

4. Identify the active behavior and criteria.
   - Read `references/behavior-discovery.md`.
   - Verify selected wave/behavior before every experiment.
   - Save original overview/criteria text before analyzing.

5. Configure chat and optional customizations.
   - Read `references/customizations-and-experiments.md`.
   - Start with no customizations unless the user explicitly wants a customization experiment.
   - If testing action-limited behavior, log system prompt, script tools, LLM tools, and tags before the first chat message.

6. Analyze each attempt.
   - Classify the result as `responded`, `blocked`, `pending`, or `unknown`.
   - Record exact user message, model-visible context if known, response summary, `api_trace` signals, and next hypothesis.
   - Update both the behavior log and, when strategy changes, the master log.

## Reference Map

- `references/storage-layout.md`: folder structure, numbering, log split, file naming.
- `references/windows-chrome-cdp.md`: Windows Chrome debug launch, login handoff, CDP verification.
- `references/chat-capture-parsing.md`: chat flow, network watcher, Burp/SSE parsing, `api_trace` meaning.
- `references/behavior-discovery.md`: behavior selection, criteria extraction, catalog generation.
- `references/customizations-and-experiments.md`: system prompt, script tools, LLM tools, tags, attempt design.

## Included Scripts

- `scripts/ensure_project_layout.ps1`: creates the expected project folders and starter logs.
- `scripts/extract_sse_payloads.js`: extracts only `payload.request` and `payload.response` from raw SSE text into `request.json` and `response.json`.
