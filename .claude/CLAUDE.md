# Stock-Folio 프로젝트 가이드

## Git 커밋 규칙

커밋 메시지 작성 시 prefix(feat:, fix:, chore: 등)를 사용하지 않습니다.

### 예시
- (O) 매매일지 작성 기능 추가
- (O) 포트폴리오 차트 버그 수정
- (X) feat: 매매일지 작성 기능 추가
- (X) fix: 포트폴리오 차트 버그 수정

## GitHub Issue 관리

이슈와 작업은 라벨로 구분합니다:
- `portfolio`: 포트폴리오 관련 기능
- `trading-journal`: 매매일지 관련 기능

## 설계서 위치

설계서는 `docs/` 폴더 아래 기능별로 구분합니다:
- `docs/portfolio/`: 포트폴리오 관련 설계서
- `docs/trading-journal/`: 매매일지 관련 설계서
