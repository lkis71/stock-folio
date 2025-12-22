# Changelog

프로젝트의 모든 중요한 변경사항이 이 파일에 기록됩니다.

## [Unreleased] - 2025-12-22

### Added
- 매매 기록에서 포트폴리오 종목 선택 기능
  - 포트폴리오에 등록된 종목을 Menu로 선택 가능
  - 빈 포트폴리오 처리 (안내 메시지 표시)
  - 종목명 자동 정렬 (가나다순)
  - 중복 제거 및 빈 문자열 필터링
  - 실시간 포트폴리오 업데이트 반영
- TradingJournalViewModel에 포트폴리오 종목 조회 기능
  - `portfolioStocks: [String]` Published 속성 추가
  - `fetchPortfolioStocks()` 메서드 추가
  - StockRepository 의존성 주입 (DIP)
- 접근성 지원
  - VoiceOver 레이블 및 힌트 제공
  - Dynamic Type 지원

### Changed
- AddTradingJournalView 종목 입력 방식 변경
  - TextField (직접 입력) → Menu (선택)
  - 데이터 일관성 개선
- TradingJournalViewModel.refresh() 메서드 개선
  - 매매 기록과 함께 포트폴리오 종목 목록도 갱신

### Technical
- 보안 검토 완료 (등급: 9.5/10)
  - Critical: 0건
  - High: 0건
  - Medium: 0건
  - Low: 1건 (MainActor 명시적 선언 권장, 선택 사항)
- SOLID 원칙 검증 완료 (평균: 9.8/10)
  - SRP: 10/10 (명확한 책임 분리)
  - OCP: 10/10 (프로토콜 기반 확장)
  - LSP: 10/10 (완벽한 치환 가능)
  - ISP: 9/10 (현재 적절, 향후 개선 가능)
  - DIP: 10/10 (프로토콜 의존, DI 적용)

### Tests
- 단위 테스트: 26개 모두 통과
  - TradingJournalPortfolioStockSelectionTests: 10개 (신규)
    - 포트폴리오 종목 조회 테스트
    - 빈 목록 처리 테스트
    - 중복 제거 테스트
    - 정렬 테스트
    - Edge case 테스트 (특수문자, 빈 문자열 등)
    - 성능 테스트

### Documentation
- 요구사항 정의서 작성 (`PORTFOLIO_STOCK_SELECTION_SPEC.md`)
- 화면 설계서 작성 (`PORTFOLIO_STOCK_SELECTION_SCREEN.md`)
- 보안 검토 문서 작성 (`SECURITY_REVIEW.md`)
- SOLID 원칙 검증 문서 작성 (`SOLID_REVIEW.md`)

### GitHub
- Issue #13: 매매 기록에서 포트폴리오 종목 선택 기능 추가

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
