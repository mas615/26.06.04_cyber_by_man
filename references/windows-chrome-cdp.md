# Windows Chrome CDP Setup

Use Chrome remote debugging when the user wants Codex to observe the logged-in browser flow and network-level chat responses.

## Start Chrome

Ask the user to close any debug Chrome instance if port `9222` is already in use, or launch a separate profile:

```powershell
$project = "<project-root>"
$profile = Join-Path $project "browser-profiles\chrome-cdp"
New-Item -ItemType Directory -Force -Path $profile | Out-Null

$chromeCandidates = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "$env:LocalAppData\Google\Chrome\Application\chrome.exe"
)
$chrome = $chromeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $chrome) { throw "Chrome executable not found" }

Start-Process -FilePath $chrome -ArgumentList @(
  "--remote-debugging-port=9222",
  "--remote-debugging-address=127.0.0.1",
  "--user-data-dir=$profile",
  "--no-first-run",
  "--no-default-browser-check",
  "https://app.grayswan.ai/arena/challenge/cyber-bypass/chat"
)
```

Then tell the user:

```text
Chrome 창에서 Gray Swan에 직접 로그인해줘. 비밀번호나 인증 링크는 나에게 보내지 않아도 돼.
```

## Verify CDP

```powershell
Invoke-RestMethod http://127.0.0.1:9222/json/version -TimeoutSec 2
Invoke-RestMethod http://127.0.0.1:9222/json/list -TimeoutSec 2 |
  Select-Object title,url
```

Expected target:

```text
Cyber Bypass Chat | Gray Swan Arena | Gray Swan AI
https://app.grayswan.ai/arena/challenge/cyber-bypass/...
```

If multiple tabs exist, use the Gray Swan tab. If the tab changes after login, list tabs again.

## Use Existing CDP Tools

When this project has `tools/chrome_cdp/`, prefer those scripts:

```powershell
node "$project\tools\chrome_cdp\cdp_eval.js" --list
```

Read the page text:

```powershell
node "$project\tools\chrome_cdp\cdp_eval.js" --match "app.grayswan.ai" --expr "({title:document.title,url:location.href,text:(document.body&&document.body.innerText||'').slice(0,3000)})"
```

If CDP returns no Gray Swan page, ask the user to focus or reopen the logged-in tab, then list tabs again.

## User Handoff Language

Use short direct requests:

```text
이제 로그인만 브라우저에서 직접 해줘. 완료되면 "로그인 완료"라고 말해줘.
```

```text
New Chat을 누르기 전에 현재 behavior를 확인할게. 잠깐만 기다려줘.
```

```text
이 시도는 내가 캡처해서 로그에 남길게. 결과가 화면에 나오면 바로 알려줘.
```
