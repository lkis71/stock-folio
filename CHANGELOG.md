# Changelog

프로젝트의 모든 중요한 변경사항이 이 파일에 기록됩니다.

## [Unreleased] - 2025-12-19

### Added
- 매매 일지 기능 추가
  - 매매 기록 작성 및 수정 (종목명, 수량, 단가, 매매일, 이유)
  - 매매 기록 삭제 (스와이프 제스처, 한글 삭제 버튼)
  - 매매 기록 탭으로 수정 화면 이동
  - 통계 표시 (총 매매, 매수/매도 건수, 실현 손익)
- 매매 일지 필터링 기능
  - 일별/월별/년도별 조회
  - FilterSheetView 추가
  - TradingJournalFilteringTests (13개 테스트)
- Repository 메서드 추가
  - `fetchByDate(_:)`: 특정 날짜의 매매 기록 조회
  - `fetchByMonth(year:month:)`: 특정 월의 매매 기록 조회
  - `fetchByYear(_:)`: 특정 년도의 매매 기록 조회

### Changed
- 매매 일지 타이틀 제거 (네비게이션 바 간소화)
- 저장 버튼 UX 개선
  - 매매 일지 작성: 저장 버튼 항상 표시
  - 포트폴리오 종목 추가/수정: 저장 버튼 항상 표시
  - 완료 버튼은 포커스 시에만 표시

### Technical
- 보안 검토 완료 (등급: MEDIUM)
  - High: 1건 (AddTradingJournalView 입력 검증 개선 필요)
  - Medium: 3건
  - Low: 2건
- SOLID 원칙 검증 완료 (평균: 8.0/10)
  - SRP: 7/10
  - OCP: 8/10
  - LSP: 9/10
  - ISP: 7/10
  - DIP: 9/10

### Tests
- 빌드 성공
- Unit 테스트: 108개 모두 통과
  - CoreDataIntegrationTests: 12개
  - CoreDataTradingJournalRepositoryTests: 15개
  - InputValidatorTests: 13개
  - PortfolioTests: 10개
  - PortfolioViewModelTests: 11개
  - TradingJournalEntityTests: 8개
  - TradingJournalFilteringTests: 13개 (신규)
  - TradingJournalViewModelTests: 16개
  - ViewModelIntegrationTests: 10개
