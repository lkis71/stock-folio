# StockFolio

주식 포트폴리오 관리 iOS 앱

## 소개

StockFolio는 개인 투자자를 위한 간단하고 직관적인 포트폴리오 관리 앱입니다. 시드머니를 설정하고 보유 종목을 입력하면 투자 현황과 종목별 비중을 한눈에 확인할 수 있습니다.

## 스크린샷

| 메인 대시보드 | 종목 추가 | 시드머니 설정 |
|:---:|:---:|:---:|
| 파이 차트로 비중 시각화 | 종목명/금액 입력 | 총 투자 가능 금액 설정 |

## 주요 기능

- **시드머니 설정**: 총 투자 가능 금액 설정
- **종목 관리**: 종목명과 매수 금액을 수동으로 입력/수정/삭제
- **색상 선택**: 종목별 차트 색상 개별 선택 (10가지 색상 팔레트)
- **투자 현황**: 투자 금액과 남은 현금을 비율과 함께 표시
- **포트폴리오 차트**:
  - Swift Charts를 활용한 파이 차트로 종목별 비중 시각화
  - 그라디언트 효과로 입체감 표현
  - 비중 기준 자동 정렬
  - 차트/범례 클릭 시 상세 정보 툴팁 표시
- **직관적인 UX**:
  - 입력 포커스 시에만 버튼 표시
  - 빈 영역 터치로 키보드 숨김
  - 부드러운 애니메이션 효과
- **반응형 UI**: 모든 iPhone 화면 크기에 최적화
- **다크 모드**: 시스템 설정에 따른 자동 테마 전환

## 기술 스택

| 구분 | 기술 |
|------|------|
| Language | Swift 5.9+ |
| UI Framework | SwiftUI |
| Charts | Swift Charts (iOS 16+) |
| Data Persistence | Core Data |
| Architecture | MVVM |
| Minimum iOS | iOS 17.0+ |

## 프로젝트 구조

```
StockFolio/
├── App/
│   ├── StockFolioApp.swift      # 앱 진입점
│   └── ContentView.swift        # 루트 뷰
├── Models/
│   ├── StockHoldingEntity.swift # Core Data Entity
│   └── Portfolio.swift          # 포트폴리오 모델
├── Views/
│   ├── MainDashboardView.swift  # 메인 대시보드
│   ├── PortfolioChartView.swift # 파이 차트 뷰
│   ├── StockListView.swift      # 종목 리스트
│   ├── AddStockView.swift       # 종목 추가/수정
│   └── SeedMoneySettingsView.swift # 시드머니 설정
├── ViewModels/
│   └── PortfolioViewModel.swift # 비즈니스 로직
├── Services/
│   ├── PersistenceController.swift   # Core Data 관리
│   ├── CoreDataStockRepository.swift # 종목 CRUD
│   ├── SeedMoneyStorage.swift        # UserDefaults 저장
│   ├── StockInputValidator.swift     # 입력 검증
│   └── CurrencyFormatter.swift       # 통화 포맷팅
├── Protocols/
│   ├── StockRepositoryProtocol.swift
│   ├── InputValidatorProtocol.swift
│   └── CurrencyFormatterProtocol.swift
└── Utils/
    └── Logger.swift             # 로깅 유틸리티
```

## 설치 및 실행

### 요구 사항

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### 빌드 방법

1. 저장소 클론
   ```bash
   git clone https://github.com/lkis71/stock-folio.git
   cd stock-folio
   ```

2. Xcode에서 프로젝트 열기
   ```bash
   open StockFolio.xcodeproj
   ```

3. 시뮬레이터 또는 실제 기기에서 실행 (Cmd + R)

### XcodeGen 사용 (선택)

```bash
brew install xcodegen
xcodegen generate
```

## 테스트

```bash
xcodebuild test \
  -project StockFolio.xcodeproj \
  -scheme StockFolio \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0'
```

## 아키텍처

### MVVM 패턴

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│      View       │────▶│   ViewModel     │────▶│    Services     │
│   (SwiftUI)     │◀────│  (Observable)   │◀────│   (Core Data)   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### 데이터 흐름

1. 사용자가 View에서 액션 수행
2. ViewModel이 비즈니스 로직 처리
3. Services가 데이터 저장/조회
4. ViewModel이 상태 업데이트
5. View가 자동으로 리렌더링

## 개발 가이드

### 코드 스타일

- SOLID 원칙 준수
- Protocol 기반 의존성 주입
- SwiftUI의 단방향 데이터 흐름

### 브랜치 전략

- `main`: 프로덕션 브랜치
- `feature/*`: 기능 개발
- `fix/*`: 버그 수정

## 향후 계획

- [ ] 매수일 기록 기능
- [ ] 종목별 메모 기능
- [ ] 카테고리 분류 (국내주식, 해외주식, 채권 등)
- [ ] CSV 내보내기/가져오기
- [ ] iOS 위젯 지원
- [ ] iPad 지원

## 라이선스

이 프로젝트는 개인 학습 목적으로 제작되었습니다.

## 기여

버그 리포트나 기능 제안은 [Issues](https://github.com/lkis71/stock-folio/issues)에 등록해주세요.
