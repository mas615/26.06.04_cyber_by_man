# Cyber Classifier Workflow Skill

Gray Swan Arena Cyber Bypass 또는 비슷한 cyber-classifier 실습을 진행할 때 쓰는 Codex skill입니다.

이 skill은 새 Codex 세션이 다음 작업 흐름을 빠르게 이어받도록 돕습니다.

- Chrome CDP 기반 브라우저 관찰 및 네트워크 캡처
- Burp/SSE `api_trace` payload 파싱
- behavior 목표와 criteria 정리
- system prompt, script tool, LLM tool 실험 로그 관리
- reports, captures, behavior worklog 폴더 구조 유지

## 설치 방법

기본 설치는 Windows PowerShell 기준입니다. macOS/Linux에서도 같은 skill을 설치할 수 있도록 shell script를 함께 제공합니다.

### Windows

1. repo 내려받기

```powershell
git clone https://github.com/mas615/26.06.04_cyber_by_man.git cyber-classifier-workflow
```

2. Codex skill 폴더에 설치하기

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\cyber-classifier-workflow\install.ps1
```

### macOS/Linux

```sh
git clone https://github.com/mas615/26.06.04_cyber_by_man.git cyber-classifier-workflow
bash ./cyber-classifier-workflow/install.sh
```

설치 후 Codex를 재시작해야 새 skill이 인식됩니다.

설치가 끝나면 대략 이런 구조가 됩니다.

```text
%USERPROFILE%\.codex\skills\cyber-classifier-workflow\
  SKILL.md
  references\
  scripts\
```

macOS/Linux에서는 같은 내용이 `~/.codex/skills/cyber-classifier-workflow/` 아래에 설치됩니다.

## 사용 방법

이 skill은 프로그램처럼 직접 실행되는 명령어가 아닙니다. 설치 후 Codex 대화창에서 skill을 선택하거나 이름으로 호출하면 Codex가 해당 workflow를 읽고 따라갑니다.

명시적으로 호출하려면 Codex에 아래처럼 입력하세요.

```text
$cyber-classifier-workflow
```

또는 `/skills` 메뉴에서 `cyber-classifier-workflow`를 선택해도 됩니다. `/cyber classifier workflow`처럼 slash command 형태로 실행하는 방식은 아닙니다.

처음 시작할 때는 아래처럼 요청하는 것을 추천합니다.

```text
$cyber-classifier-workflow
프로젝트 루트는 <작업할 프로젝트 폴더 경로>야.
Chrome CDP로 Gray Swan Cyber Bypass 사이트를 열고 로그인 대기 상태까지 준비해줘.
```

그러면 Codex는 skill의 workflow에 따라 프로젝트 폴더를 확인하고, Chrome remote debugging 설정으로 Gray Swan Cyber Bypass 페이지를 열고, 사용자가 직접 로그인하도록 안내해야 합니다.

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
- `install.ps1`: 현재 repo를 Codex 사용자 skill 폴더에 설치하는 PowerShell script.
- `install.sh`: 현재 repo를 Codex 사용자 skill 폴더에 설치하는 macOS/Linux shell script.

## 업데이트 방법

이미 설치한 뒤 새 버전을 받고 싶다면 clone했던 폴더의 부모 위치에서 아래 명령어를 실행하세요.

```powershell
Set-Location .\cyber-classifier-workflow
git pull
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

macOS/Linux에서는 아래처럼 업데이트합니다.

```sh
cd ./cyber-classifier-workflow
git pull
bash ./install.sh
```

업데이트 후에도 Codex 재시작이 필요합니다.

## 주의사항

이 repo에는 workflow instruction만 보관하세요.

커밋하면 안 되는 것:

- live captures
- 쿠키, 토큰, 세션 데이터
- 실제 계정 정보
- 개인 세션의 `request.json`, `response.json`
- raw log 또는 민감한 실험 데이터
