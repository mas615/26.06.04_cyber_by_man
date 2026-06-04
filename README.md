# Cyber Classifier Workflow Skill

Gray Swan Arena Cyber Bypass 또는 비슷한 cyber-classifier 실습을 진행할 때 쓰는 Codex skill입니다.

이 skill은 새 Codex 세션이 다음 작업 흐름을 빠르게 이어받도록 돕습니다.

- Chrome CDP 기반 브라우저 관찰 및 네트워크 캡처
- Burp/SSE `api_trace` payload 파싱
- behavior 목표와 criteria 정리
- system prompt, script tool, LLM tool 실험 로그 관리
- reports, captures, behavior worklog 폴더 구조 유지

## 설치 방법

macOS에서는 아래 명령어를 실행하세요.

1. repo 내려받기

```sh
git clone https://github.com/mas615/26.06.04_cyber_by_man.git cyber-classifier-workflow
```

2. Codex skill 폴더에 설치하기

```sh
bash ./cyber-classifier-workflow/install.sh
```

Windows PowerShell에서는 아래처럼 설치할 수 있습니다.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\cyber-classifier-workflow\install.ps1
```

설치 후 Codex를 재시작해야 새 skill이 인식됩니다.

설치가 끝나면 대략 이런 구조가 됩니다.

```text
~/.codex/skills/cyber-classifier-workflow/
  SKILL.md
  references/
  scripts/
```

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

macOS에서 Chrome CDP를 직접 열 때는 아래 형태를 사용합니다.

```sh
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --remote-debugging-port=9222 \
  --remote-debugging-address=127.0.0.1 \
  --user-data-dir "<project-root>/browser-profiles/chrome-cdp" \
  --no-first-run \
  --no-default-browser-check \
  "https://app.grayswan.ai/arena/challenge/cyber-bypass/chat"
```

## 구성

- `SKILL.md`: skill trigger metadata와 핵심 workflow.
- `references/`: Chrome CDP, capture/parsing, behavior discovery, storage layout, experiment 기록 방식.
- `scripts/`: 프로젝트 폴더 생성과 SSE payload 추출을 돕는 helper script.
- `install.sh`: 현재 repo를 Codex 사용자 skill 폴더에 설치하는 macOS/Linux shell script.
- `install.ps1`: 현재 repo를 Codex 사용자 skill 폴더에 설치하는 PowerShell script.

## 업데이트 방법

이미 설치한 뒤 새 버전을 받고 싶다면 clone했던 폴더의 부모 위치에서 아래 명령어를 실행하세요.

```sh
cd ./cyber-classifier-workflow
git pull
bash ./install.sh
```

Windows PowerShell에서는 아래처럼 업데이트합니다.

```powershell
Set-Location .\cyber-classifier-workflow
git pull
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
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
