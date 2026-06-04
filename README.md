# Cyber Classifier Workflow Skill

Gray Swan Arena Cyber Bypass 또는 비슷한 cyber-classifier 실습을 진행할 때 쓰는 Codex skill입니다.

이 skill은 새 Codex 세션이 다음 작업 흐름을 빠르게 이어받도록 돕습니다.

- Chrome CDP 기반 브라우저 관찰 및 네트워크 캡처
- Burp/SSE `api_trace` payload 파싱
- behavior 목표와 criteria 정리
- system prompt, script tool, LLM tool 실험 로그 관리
- reports, captures, behavior worklog 폴더 구조 유지

## 설치 방법

Windows PowerShell에서 아래 명령어를 실행하세요.

```powershell
git clone https://github.com/mas615/26.06.04_cyber_by_man.git cyber-classifier-workflow
powershell -NoProfile -ExecutionPolicy Bypass -File .\cyber-classifier-workflow\install.ps1
```

설치 후 Codex를 재시작해야 새 skill이 인식됩니다.

설치가 끝나면 대략 이런 구조가 됩니다.

```text
%USERPROFILE%\.codex\skills\cyber-classifier-workflow\
  SKILL.md
  references\
  scripts\
```

## 구성

- `SKILL.md`: skill trigger metadata와 핵심 workflow.
- `references/`: Chrome CDP, capture/parsing, behavior discovery, storage layout, experiment 기록 방식.
- `scripts/`: 프로젝트 폴더 생성과 SSE payload 추출을 돕는 helper script.
- `install.ps1`: 현재 repo를 Codex 사용자 skill 폴더에 설치하는 PowerShell script.

## 업데이트 방법

이미 설치한 뒤 새 버전을 받고 싶다면 clone했던 폴더의 부모 위치에서 아래 명령어를 실행하세요.

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
