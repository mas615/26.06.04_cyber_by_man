# Cyber Classifier Workflow Skill

Gray Swan Arena Cyber Bypass 또는 비슷한 cyber-classifier 실습을 진행할 때 쓰는 Agent Skill입니다.

이 skill은 새 Codex 또는 Claude 세션이 다음 작업 흐름을 빠르게 이어받도록 돕습니다.

- Chrome CDP 기반 브라우저 관찰 및 네트워크 캡처
- Burp/SSE `api_trace` payload 파싱
- behavior 목표와 criteria 정리
- system prompt, script tool, LLM tool 실험 로그 관리
- reports, captures, behavior worklog 폴더 구조 유지

설치 파일은 Codex용과 Claude용을 별도로 제공합니다.

## 설치 방법

먼저 repo를 내려받습니다.

```sh
git clone https://github.com/mas615/26.06.04_cyber_by_man.git cyber-classifier-workflow
```

### Codex 전용

Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\cyber-classifier-workflow\install.ps1
```

macOS/Linux:

```sh
bash ./cyber-classifier-workflow/install.sh
```

설치 위치:

```text
~/.codex/skills/cyber-classifier-workflow/
```

Windows에서는 보통 아래 위치에 설치됩니다.

```text
%USERPROFILE%\.codex\skills\cyber-classifier-workflow\
```

설치 후 Codex를 재시작해야 새 skill이 인식됩니다.

### Claude 전용

Claude Code personal skill로 설치합니다.

Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\cyber-classifier-workflow\install-claude.ps1
```

macOS/Linux:

```sh
bash ./cyber-classifier-workflow/install-claude.sh
```

설치 위치:

```text
~/.claude/skills/cyber-classifier-workflow/
```

Windows에서는 보통 아래 위치에 설치됩니다.

```text
%USERPROFILE%\.claude\skills\cyber-classifier-workflow\
```

Claude Code에서 skill이 바로 보이지 않으면 Claude Code를 재시작하세요.

Claude.ai에 업로드할 ZIP이 필요하면 Claude 전용 설치 스크립트에서 ZIP만 생성할 수 있습니다.

Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\cyber-classifier-workflow\install-claude.ps1 -ZipOnly
```

macOS/Linux:

```sh
bash ./cyber-classifier-workflow/install-claude.sh --zip-only
```

생성 파일:

```text
dist/cyber-classifier-workflow.zip
```

ZIP 내부 구조는 Claude.ai 업로드용으로 `cyber-classifier-workflow/SKILL.md` 형태가 되도록 만들어집니다.
Claude.ai에서는 Settings > Capabilities > Skills에서 이 ZIP을 업로드하세요.

## 사용 방법

이 skill은 프로그램처럼 직접 실행되는 명령어가 아닙니다. 설치 후 에이전트가 관련 요청을 받으면 workflow를 읽고 따라갑니다.

Codex에서 명시적으로 호출하려면 아래처럼 입력하세요.

```text
$cyber-classifier-workflow
```

Claude Code에서 명시적으로 호출하려면 아래처럼 입력하세요.

```text
/cyber-classifier-workflow
```

처음 시작할 때는 아래처럼 요청하는 것을 추천합니다.

```text
cyber-classifier-workflow skill을 사용해줘.
프로젝트 루트는 <작업할 프로젝트 폴더 경로>야.
Chrome CDP로 Gray Swan Cyber Bypass 사이트를 열고 로그인 대기 상태까지 준비해줘.
```

그러면 에이전트는 skill의 workflow에 따라 프로젝트 폴더를 확인하고, Chrome remote debugging 설정으로 Gray Swan Cyber Bypass 페이지를 열고, 사용자가 직접 로그인하도록 안내해야 합니다.

Windows에서 Chrome CDP를 직접 열 때는 아래 형태를 사용합니다.

```powershell
$project = "<project-root>"
$profile = Join-Path $project "browser-profiles/chrome-cdp"
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

macOS/Linux 명령은 `references/chrome-cdp.md`에 함께 정리되어 있습니다.

## 구성

- `SKILL.md`: skill trigger metadata와 핵심 workflow.
- `references/`: Chrome CDP, capture/parsing, behavior discovery, storage layout, experiment 기록 방식.
- `scripts/`: 프로젝트 폴더 생성과 SSE payload 추출을 돕는 helper script.
- `install.ps1`: Codex 사용자 skill 폴더에 설치하는 PowerShell script.
- `install.sh`: Codex 사용자 skill 폴더에 설치하는 macOS/Linux shell script.
- `install-claude.ps1`: Claude Code 사용자 skill 폴더에 설치하거나 Claude.ai ZIP을 만드는 PowerShell script.
- `install-claude.sh`: Claude Code 사용자 skill 폴더에 설치하거나 Claude.ai ZIP을 만드는 macOS/Linux shell script.

## 업데이트 방법

이미 설치한 뒤 새 버전을 받고 싶다면 clone했던 폴더에서 아래 명령어를 실행하세요.

Codex:

```sh
git pull
bash ./install.sh
```

Claude:

```sh
git pull
bash ./install-claude.sh
```

Windows에서는 각 installer의 `.ps1` 파일을 다시 실행하면 됩니다.

## 주의사항

이 repo에는 workflow instruction만 보관하세요.

커밋하면 안 되는 것:

- live captures
- 쿠키, 토큰, 세션 데이터
- 실제 계정 정보
- 개인 세션의 `request.json`, `response.json`
- raw log 또는 민감한 실험 데이터
