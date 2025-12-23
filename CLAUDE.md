# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

StockFolio는 SwiftUI 기반 iOS 주식 포트폴리오 관리 앱입니다.
- **언어**: Swift 5.9+
- **UI**: SwiftUI
- **데이터**: Core Data
- **아키텍처**: MVVM + Repository Pattern
- **최소 버전**: iOS 17.0+

## 빌드 및 실행

### 기본 빌드
```bash
# Xcode에서 프로젝트 열기
open StockFolio.xcodeproj

# 또는 명령줄 빌드
xcodebuild -scheme StockFolio -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.0' build
```

### XcodeGen 사용
프로젝트는 `project.yml`로 관리됩니다:
```bash
xcodegen generate  # project.pbxproj 재생성
```

**새 파일 추가 후 반드시 실행**하여 Xcode 프로젝트에 반영해야 합니다.

### 테스트 실행
```bash
# 전체 테스트
xcodebuild test -scheme StockFolio -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0'

# 특정 테스트만 실행
xcodebuild test -scheme StockFolio -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0' -only-testing:StockFolioTests/TradingJournalViewModelTests
```

## 아키텍처

### MVVM + Repository Pattern
```
View (SwiftUI)
  ↓ @StateObject/@ObservedObject
ViewModel (@Observable, 비즈니스 로직)
  ↓ Protocol 의존성 주입
Repository (CoreData CRUD)
  ↓
Core Data (영구 저장소)
```

### 핵심 원칙
1. **Protocol 기반 의존성 주입**: 모든 Repository는 Protocol로 추상화
2. **단방향 데이터 흐름**: View → ViewModel → Repository → Core Data
3. **ViewModel 테스트 가능성**: Mock Repository 사용

### 주요 컴포넌트

**포트폴리오 기능**
- `PortfolioViewModel`: 종목 관리, 시드머니, 차트 데이터
- `CoreDataStockRepository`: 종목 CRUD
- `StockInputValidator`: 입력 검증
- `SeedMoneyStorage`: UserDefaults 기반 시드머니 저장

**매매일지 기능**
- `TradingJournalViewModel`: 매매 기록, 필터링, 통계, 페이지네이션
- `TradingCalendarViewModel`: 캘린더 월 탐색, 일일/월별 집계
- `CoreDataTradingJournalRepository`: 매매일지 CRUD
- `TradingCalendarModels`: DailyTradingSummary, MonthlyStatistics

**공통**
- `PersistenceController`: Core Data 스택 관리 (NSPersistentContainer)
- `Logger`: 통합 로깅 유틸리티

## Git 및 이슈 관리

### 커밋 메시지 규칙
**prefix를 사용하지 않습니다:**
- ✅ "매매일지 작성 기능 추가"
- ✅ "포트폴리오 차트 버그 수정"
- ❌ "feat: 매매일지 작성 기능 추가"
- ❌ "fix: 포트폴리오 차트 버그 수정"

### GitHub 라벨
- `portfolio`: 포트폴리오 관련 기능
- `trading-journal`: 매매일지 관련 기능

## 설계 문서

모든 설계서는 `docs/` 폴더에 기능별로 구분됩니다:
- `docs/portfolio/`: 포트폴리오 설계서
- `docs/trading-journal/`: 매매일지 설계서
  - `CALENDAR_REQUIREMENTS.md`: 캘린더 요구사항
  - `CALENDAR_SCREEN_DESIGN.md`: 캘린더 화면설계서
  - `CALENDAR_USECASE.md`: 캘린더 유스케이스

**중요**: 기능 구현 시 설계서를 먼저 확인하고, 코드 변경 후 설계서도 업데이트합니다.

## UI 디자인 가이드라인

### 컴팩트 디자인 원칙
- **폰트**: 제목 `.subheadline`, 본문 `.caption`~`.subheadline`, 보조 `.caption2`
- **패딩**: 카드 내부 `10~12pt`, 요소 간격 `6~8pt`, 섹션 간격 `12~16pt`
- **카드**: 색상 인디케이터 `4pt`, 코너 라디우스 `8~10pt`

### 페이지네이션 규칙
**모든 리스트는 10개씩 로드**:
- 최초 로드: 10개만 조회
- "↓ 더보기" 버튼 클릭 시 10개씩 추가
- "↑ 접기" 버튼으로 처음 10개로 축소
- **자동 스크롤 로딩 금지** (수동 버튼만 허용)
- 10개 초과 시 `(표시개수/전체개수)` 표시

### 숫자 표시
- `.lineLimit(1)` + `.minimumScaleFactor(0.7)` 적용
- 금액과 비율 통합: `+1,234,567원 (+12.3%)`
- 수익=빨간색, 손실=파란색 (한국 주식 시장 관례)

## 데이터 모델

### Core Data Entity
- `StockHoldingMO`: 포트폴리오 종목 (종목명, 금액, 색상)
- `TradingJournalMO`: 매매일지 (매수/매도, 날짜, 종목명, 수량, 단가, 실현손익)

### Domain Model
- `StockHoldingEntity`: StockHoldingMO → UI 모델 변환
- `TradingJournalEntity`: TradingJournalMO → UI 모델 변환
- `Portfolio`: 계산된 포트폴리오 데이터 (총액, 비율, 차트용)

### Filter & Statistics
- `FilterType`: 전체/일별/월별/연별
- `TradingJournalStatistics`: 매매 통계 (총 건수, 매수/매도, 실현손익)
- `PaginationState`: 페이지네이션 상태 관리

## 프로젝트 파일 구조
```
StockFolio/
├── App/                    # 앱 진입점
├── Models/                 # Domain Models & Core Data Entities
├── Views/                  # SwiftUI Views
│   ├── TradingJournalView.swift      # 캘린더/리스트 탭 전환
│   ├── TradingCalendarView.swift     # 월별 캘린더
│   ├── DailyTradesSheet.swift        # 일일 거래 상세
│   └── TradingJournalListView.swift  # 리스트 + 인라인 필터
├── ViewModels/             # MVVM ViewModels
├── Services/               # Repository & Storage
├── Protocols/              # DI용 Protocol 인터페이스
├── Utils/                  # 로깅, 포매터 등
└── Resources/              # Assets, Core Data 모델 파일
```

## 주의사항

1. **새 Swift 파일 추가 후**: `xcodegen generate` 실행 필수
2. **ViewModel 테스트**: Mock Repository 사용하여 비즈니스 로직만 테스트
3. **Core Data 마이그레이션**: 모델 변경 시 마이그레이션 전략 수립
4. **UI 레이아웃 안정성**: ZStack + `.frame(maxHeight:)` 사용하여 높이 변화 방지
5. **색상 규칙**: 수익은 빨간색(`.red`), 손실은 파란색(`.blue`)
