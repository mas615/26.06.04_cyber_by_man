# Chat, Capture, And Parsing

This workflow observes the browser session, captures chat/network data, and extracts only the values needed for analysis.

## Chat Flow

Before sending a chat prompt:

1. Verify the selected behavior and wave.
2. Verify whether customizations are installed.
3. Start a new chat if the behavior or customization set changed.
4. Log the exact prompt before sending it.

Important UI rule:

- System prompt, script tools, and LLM tools should be configured before the first chat message.
- After a chat starts, treat the customization set as locked for that attempt.

## Chrome CDP Live Capture

If `tools/chrome_cdp/network_watch.js` exists, start the watcher:

```powershell
$project = "<project-root>"
$live = Join-Path $project "captures\chrome_cdp\network\live"
$scriptDir = Join-Path $project "tools\chrome_cdp"
New-Item -ItemType Directory -Force -Path $live | Out-Null

Start-Process -FilePath "node" `
  -ArgumentList ('network_watch.js --match "app.grayswan.ai" --url-includes "app.grayswan.ai" --out-dir "' + $live + '"') `
  -WorkingDirectory $scriptDir `
  -WindowStyle Hidden `
  -RedirectStandardOutput (Join-Path $live "watcher.stdout.log") `
  -RedirectStandardError (Join-Path $live "watcher.stderr.log")
```

Common live files:

```text
captures/chrome_cdp/network/live/requests.json
captures/chrome_cdp/network/live/events.jsonl
captures/chrome_cdp/network/live/api_trace_data.json
captures/chrome_cdp/network/live/api_trace_data_raw.txt
captures/chrome_cdp/network/live/request.json
captures/chrome_cdp/network/live/response.json
captures/chrome_cdp/network/live/status.json
```

Inspect the latest extracted payloads first:

```powershell
Get-Content -Raw "$live\request.json"
Get-Content -Raw "$live\response.json"
```

## Burp Or Saved SSE Parsing

If the user saves Burp active editor text or raw SSE response text, put it under:

```text
captures/burp_sse/raw/
```

Then extract payloads:

```powershell
$project = "<project-root>"
$skill = "<skill-root>"
node "$skill\scripts\extract_sse_payloads.js" `
  --in "$project\captures\burp_sse\raw\latest.txt" `
  --out-dir "$project\captures\burp_sse\payload"
```

When running from an installed Codex skill, resolve `<skill-root>` to this skill folder. It is usually under `%USERPROFILE%\.codex\skills\cyber-classifier-workflow` on Windows.

The script writes only:

```text
request.json
response.json
```

It does not add `source_file`, timestamps, summaries, or custom wrappers.

## What `event: api_trace` Means

`event: api_trace` is a server-sent event carrying internal trace data from the app's model call. The useful `data` JSON may include:

- `payload.request`: the model request object
- `payload.response`: the model response object
- `type: "response"` with token logs
- text fragments such as policy blocks or API errors

It is not the same as the outer browser HTTP request. Treat it as model-call telemetry embedded in the stream.

## Fields To Inspect

In `request.json`:

- model
- messages
- user-visible prompt
- system reminders or injected customization context
- behavior or challenge identifiers if present

In `response.json`:

- `content`
- `stop_reason`
- `usage`
- refusal or block text
- tool call traces if present

Common result signals:

```text
tokens in=0 out=0         likely blocked before model reasoning
Error: Blocked            policy or platform block
stop_reason=end_turn      normal response completed
stop_reason=tool_use      model attempted a tool call
```

## Analysis Format

For every attempt, record:

```text
Attempt number:
Behavior:
Customization:
User prompt:
Result: responded | blocked | pending | unknown
Observed response:
api_trace signals:
What this proves:
Next change:
```

Do not summarize away the exact prompt or exact block signal. Those are the data.
