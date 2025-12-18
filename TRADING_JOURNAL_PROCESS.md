# 매매 일지 프로세스 설계서

## 1. 개요

본 문서는 매매 일지 기능의 사용자 플로우, 데이터 처리 흐름, 비즈니스 로직을 상세히 정의합니다.

## 2. 사용자 플로우 (User Flow)

### 2.1 전체 플로우

```
[메인 대시보드]
      ↓
  (탭 전환)
      ↓
[매매 일지 목록]
      ├─→ [필터 적용] → [필터링된 목록]
      ├─→ [일지 선택] → [상세/수정 화면] ──→ [저장] → [목록 새로고침]
      │                       └──→ [삭제] → [목록 새로고침]
      ├─→ [+ 버튼] → [일지 작성] → [저장] → [목록에 추가]
      └─→ [통계 보기] → [통계 화면]
```

### 2.2 매매 일지 작성 플로우

```
시작: [+ 버튼 탭]
  ↓
[작성 화면 표시]
  ↓
<매매 유형 선택> (기본: 매수)
  ↓
<날짜 선택> (기본: 오늘)
  ↓
<종목명 입력>
  ├─→ [검증 실패] → 에러 메시지 표시
  └─→ [검증 성공] → 계속
  ↓
<수량 입력>
  ├─→ [검증 실패] → 에러 메시지 표시
  └─→ [검증 성공] → 계속
  ↓
<단가 입력>
  ├─→ [검증 실패] → 에러 메시지 표시
  └─→ [검증 성공] → 총액 자동 계산
  ↓
<매매 이유 입력> (선택)
  ↓
[저장 버튼 활성화]
  ↓
<저장 버튼 탭>
  ↓
[데이터 저장] → [CoreData에 저장]
  ├─→ [성공] → 화면 닫기 → 목록 새로고침
  └─→ [실패] → 에러 알림 표시
```

### 2.3 매매 일지 수정 플로우

```
시작: [목록에서 일지 카드 탭]
  ↓
[상세/수정 화면 표시]
  ↓
[기존 데이터 로드 및 표시]
  ↓
<필드 수정>
  ├─→ [변경 없음] → [취소] → 화면 닫기
  └─→ [변경 있음] → [검증] → [저장] → 목록 새로고침
```

### 2.4 매매 일지 삭제 플로우

```
시작: [목록 항목에서 좌측 스와이프]
  ↓
[삭제 버튼 표시]
  ↓
<삭제 버튼 탭>
  ↓
[확인 알림 표시]
  ├─→ [취소] → 알림 닫기
  └─→ [확인]
        ↓
      [데이터 삭제]
        ↓
      [목록 새로고침]
        ↓
      [Toast 메시지: "매매 일지가 삭제되었습니다"]
```

### 2.5 필터링 플로우

```
시작: [필터 버튼 탭]
  ↓
[필터 시트 표시]
  ↓
<날짜 범위 선택>
  - 전체 기간 (기본)
  - 이번 달
  - 지난 달
  - 사용자 지정 (DatePicker)
  ↓
<매매 유형 선택>
  - 전체 (기본)
  - 매수만
  - 매도만
  ↓
<종목 선택>
  - 전체 (기본)
  - 특정 종목 (Picker)
  ↓
[적용 버튼 탭]
  ↓
[필터링된 결과 표시]
  ↓
[필터 요약 표시] (예: "2024.12.01~31, 매수만, 삼성전자")
```

### 2.6 통계 조회 플로우

```
시작: [통계 탭/버튼 탭]
  ↓
[통계 계산 시작]
  ↓
[데이터 조회]
  - 전체 매매 일지
  - 매수/매도 분리
  - 손익 계산
  ↓
[통계 생성]
  - 총 매매 횟수
  - 실현 손익
  - 평균 수익률
  - 승률
  - 종목별 통계
  - 월별 통계
  ↓
[통계 화면 표시]
  ↓
[차트 애니메이션 실행]
```

## 3. 화면 전환 다이어그램

### 3.1 네비게이션 구조

```
TabView
├─ 포트폴리오 탭
│  └─ MainDashboardView
│     ├─ .sheet: AddStockView
│     └─ .sheet: SeedMoneySettingsView
│
└─ 매매 일지 탭
   └─ TradingJournalListView
      ├─ .sheet: AddTradingJournalView
      ├─ .sheet: TradingJournalFilterView
      ├─ .sheet: AddTradingJournalView (편집 모드)
      └─ NavigationLink: TradingJournalStatsView
```

### 3.2 모달 스택

```
Level 0: TradingJournalListView
Level 1: └─ AddTradingJournalView (모달)
             └─ Alert: 저장 확인

Level 0: TradingJournalListView
Level 1: └─ TradingJournalFilterView (모달)
             └─ DatePicker (사용자 지정 날짜)
```

## 4. 데이터 흐름 (Data Flow)

### 4.1 작성/수정 플로우

```
[View Layer]
AddTradingJournalView
  ↓ (사용자 입력)
@State 변수들
  - tradeType: TradeType
  - tradeDate: Date
  - stockName: String
  - quantity: String
  - price: String
  - reason: String
  ↓ (저장 버튼 탭)
[ViewModel Layer]
TradingJournalViewModel.addJournal() / updateJournal()
  ↓ (검증)
TradingJournalValidator.validate()
  ├─→ [실패] → ValidationError → View에 에러 표시
  └─→ [성공]
      ↓ (Entity 생성)
    TradingJournalEntity
      ↓ (Repository 호출)
[Repository Layer]
TradingJournalRepository.save() / update()
  ↓ (CoreData 변환)
TradingJournalManagedObject
  ↓ (저장)
CoreData Context.save()
  ├─→ [실패] → Error → ViewModel → View 에러 표시
  └─→ [성공]
      ↓ (완료 콜백)
    ViewModel.fetchJournals() (목록 새로고침)
      ↓
    View 업데이트 (목록에 추가/수정된 항목 표시)
```

### 4.2 조회 플로우

```
[View Layer]
TradingJournalListView.onAppear
  ↓
[ViewModel Layer]
TradingJournalViewModel.fetchJournals()
  ↓ (필터 적용)
현재 필터 조건 (날짜, 유형, 종목)
  ↓ (Repository 호출)
[Repository Layer]
TradingJournalRepository.fetchAll(filter:)
  ↓ (CoreData 쿼리)
NSFetchRequest<TradingJournalManagedObject>
  - Predicate: 필터 조건
  - SortDescriptor: tradeDate DESC
  - Limit: 20 (페이지네이션)
  ↓ (결과 변환)
[TradingJournalEntity] 배열
  ↓ (ViewModel 상태 업데이트)
@Published var journals: [TradingJournalEntity]
  ↓ (View 자동 업데이트)
ForEach(journals) { journal in
  TradingJournalCardView(journal)
}
```

### 4.3 삭제 플로우

```
[View Layer]
스와이프 삭제 제스처
  ↓
.swipeActions { Delete 버튼 }
  ↓ (삭제 버튼 탭)
[ViewModel Layer]
TradingJournalViewModel.deleteJournal(id:)
  ↓ (Repository 호출)
[Repository Layer]
TradingJournalRepository.delete(id:)
  ↓ (CoreData에서 찾기)
CoreData.fetch(id)
  ├─→ [없음] → Error
  └─→ [있음]
      ↓ (삭제)
    Context.delete(object)
      ↓
    Context.save()
      ├─→ [실패] → Error
      └─→ [성공]
          ↓
        ViewModel.fetchJournals() (목록 새로고침)
          ↓
        View 업데이트 (항목 제거 애니메이션)
```

### 4.4 통계 계산 플로우

```
[View Layer]
TradingJournalStatsView.onAppear
  ↓
[ViewModel Layer]
TradingJournalViewModel.calculateStats()
  ↓ (전체 데이터 조회)
Repository.fetchAll()
  ↓ (데이터 분리)
매수 일지: [TradingJournalEntity] (tradeType == .buy)
매도 일지: [TradingJournalEntity] (tradeType == .sell)
  ↓ (통계 계산)
- totalBuyCount = 매수 일지.count
- totalSellCount = 매도 일지.count
- totalProfit = Σ(매도 일지의 손익)
- avgProfitRate = totalProfit / Σ(매수금액) × 100
- winRate = (수익 건수 / 매도 건수) × 100
  ↓ (종목별 집계)
종목별 Dictionary<String, Stats>
  ↓ (월별 집계)
월별 Dictionary<YearMonth, Double>
  ↓ (상태 업데이트)
@Published var stats: TradingStats
  ↓ (View 표시)
통계 카드 및 차트 렌더링
```

## 5. 비즈니스 로직

### 5.1 입력 검증 로직

```swift
class TradingJournalValidator {
    // 종목명 검증
    func validateStockName(_ name: String) -> Result<Void, ValidationError> {
        // 1. 공백 체크
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            return .failure(.empty)
        }

        // 2. 길이 체크 (최대 50자)
        if name.count > 50 {
            return .failure(.tooLong(50))
        }

        // 3. 특수문자 체크 (일부만 허용)
        let allowedCharacters = CharacterSet.alphanumerics
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "()&-."))

        if name.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            return .failure(.invalidCharacters)
        }

        return .success(())
    }

    // 수량 검증
    func validateQuantity(_ quantity: String) -> Result<Int, ValidationError> {
        // 1. 숫자 변환
        guard let value = Int(quantity) else {
            return .failure(.invalidNumber)
        }

        // 2. 양수 체크
        if value <= 0 {
            return .failure(.mustBePositive)
        }

        // 3. 범위 체크 (최대 1,000,000주)
        if value > 1_000_000 {
            return .failure(.outOfRange)
        }

        return .success(value)
    }

    // 가격 검증
    func validatePrice(_ price: String) -> Result<Double, ValidationError> {
        // 1. 콤마 제거
        let cleanedPrice = price.replacingOccurrences(of: ",", with: "")

        // 2. 숫자 변환
        guard let value = Double(cleanedPrice) else {
            return .failure(.invalidNumber)
        }

        // 3. 양수 체크
        if value <= 0 {
            return .failure(.mustBePositive)
        }

        // 4. 범위 체크 (최대 10억)
        if value > 1_000_000_000 {
            return .failure(.outOfRange)
        }

        return .success(value)
    }

    // 날짜 검증
    func validateDate(_ date: Date) -> Result<Void, ValidationError> {
        // 미래 날짜 체크
        if date > Date() {
            return .failure(.futureDate)
        }

        return .success(())
    }
}
```

### 5.2 손익 계산 로직 (Phase 2)

```swift
// Phase 2에서 구현 예정
class ProfitCalculator {
    // 매수-매도 매칭 (FIFO)
    func calculateProfit(
        buyJournals: [TradingJournalEntity],
        sellJournal: TradingJournalEntity
    ) -> Double {
        // 1. 종목명이 같은 매수 일지만 필터링
        let matchedBuys = buyJournals.filter {
            $0.stockName == sellJournal.stockName &&
            $0.tradeDate <= sellJournal.tradeDate
        }

        // 2. 날짜순 정렬 (오래된 것부터)
        let sortedBuys = matchedBuys.sorted { $0.tradeDate < $1.tradeDate }

        // 3. FIFO 방식으로 매칭
        var remainingQuantity = sellJournal.quantity
        var totalCost = 0.0

        for buy in sortedBuys {
            if remainingQuantity <= 0 { break }

            let matchedQty = min(remainingQuantity, buy.quantity)
            totalCost += Double(matchedQty) * buy.price
            remainingQuantity -= matchedQty
        }

        // 4. 손익 계산
        let sellAmount = Double(sellJournal.quantity) * sellJournal.price
        let profit = sellAmount - totalCost

        return profit
    }
}
```

### 5.3 통계 계산 로직

```swift
class StatsCalculator {
    func calculateStats(journals: [TradingJournalEntity]) -> TradingStats {
        let buyJournals = journals.filter { $0.tradeType == .buy }
        let sellJournals = journals.filter { $0.tradeType == .sell }

        // 총 매매 횟수
        let totalBuyCount = buyJournals.count
        let totalSellCount = sellJournals.count

        // 실현 손익 계산 (Phase 1: 간단 버전)
        let totalBuyAmount = buyJournals.reduce(0.0) { $0 + $1.totalAmount }
        let totalSellAmount = sellJournals.reduce(0.0) { $0 + $1.totalAmount }
        let realizedProfit = totalSellAmount - totalBuyAmount

        // 평균 수익률
        let avgProfitRate = totalBuyAmount > 0
            ? (realizedProfit / totalBuyAmount) * 100
            : 0

        // 승률 계산
        // Phase 1: 매도 건수 대비 계산 (간단 버전)
        // Phase 2: 실제 손익 기반 계산
        let winCount = sellJournals.filter { $0.totalAmount > 0 }.count
        let winRate = totalSellCount > 0
            ? Double(winCount) / Double(totalSellCount) * 100
            : 0

        // 종목별 통계
        let stockStats = calculateStockStats(journals: journals)

        // 월별 통계
        let monthlyStats = calculateMonthlyStats(journals: journals)

        return TradingStats(
            totalBuyCount: totalBuyCount,
            totalSellCount: totalSellCount,
            realizedProfit: realizedProfit,
            avgProfitRate: avgProfitRate,
            winRate: winRate,
            stockStats: stockStats,
            monthlyStats: monthlyStats
        )
    }

    private func calculateStockStats(journals: [TradingJournalEntity]) -> [StockStats] {
        // 종목별로 그룹화
        let grouped = Dictionary(grouping: journals) { $0.stockName }

        return grouped.map { (stockName, journals) in
            let buyCount = journals.filter { $0.tradeType == .buy }.count
            let sellCount = journals.filter { $0.tradeType == .sell }.count
            let totalProfit = journals
                .filter { $0.tradeType == .sell }
                .reduce(0.0) { $0 + $1.totalAmount }

            return StockStats(
                stockName: stockName,
                buyCount: buyCount,
                sellCount: sellCount,
                totalProfit: totalProfit
            )
        }
        .sorted { $0.buyCount + $0.sellCount > $1.buyCount + $1.sellCount }
        .prefix(5)
        .map { $0 }
    }

    private func calculateMonthlyStats(journals: [TradingJournalEntity]) -> [MonthlyStats] {
        // 월별로 그룹화
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: journals) { journal in
            calendar.dateComponents([.year, .month], from: journal.tradeDate)
        }

        return grouped.map { (components, journals) in
            let profit = journals
                .filter { $0.tradeType == .sell }
                .reduce(0.0) { $0 + $1.totalAmount }

            return MonthlyStats(
                year: components.year ?? 0,
                month: components.month ?? 0,
                profit: profit,
                tradeCount: journals.count
            )
        }
        .sorted {
            ($0.year * 100 + $0.month) < ($1.year * 100 + $1.month)
        }
    }
}
```

## 6. 에러 처리

### 6.1 에러 타입 정의

```swift
enum TradingJournalError: Error, LocalizedError {
    case invalidInput(ValidationError)
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    case notFound

    var errorDescription: String? {
        switch self {
        case .invalidInput(let validationError):
            return validationError.localizedDescription
        case .saveFailed:
            return "저장에 실패했습니다. 다시 시도해주세요."
        case .fetchFailed:
            return "데이터를 불러오는데 실패했습니다."
        case .deleteFailed:
            return "삭제에 실패했습니다."
        case .notFound:
            return "매매 일지를 찾을 수 없습니다."
        }
    }
}

enum ValidationError: Error, LocalizedError {
    case empty
    case tooLong(Int)
    case invalidCharacters
    case invalidNumber
    case mustBePositive
    case outOfRange
    case futureDate

    var errorDescription: String? {
        switch self {
        case .empty:
            return "필수 항목입니다."
        case .tooLong(let max):
            return "\(max)자 이내로 입력해주세요."
        case .invalidCharacters:
            return "사용할 수 없는 문자가 포함되어 있습니다."
        case .invalidNumber:
            return "올바른 숫자를 입력해주세요."
        case .mustBePositive:
            return "0보다 큰 값을 입력해주세요."
        case .outOfRange:
            return "입력 가능한 범위를 초과했습니다."
        case .futureDate:
            return "미래 날짜는 선택할 수 없습니다."
        }
    }
}
```

### 6.2 에러 처리 시나리오

| 상황 | 에러 타입 | 처리 방법 |
|------|----------|----------|
| 종목명 미입력 | ValidationError.empty | 필드 하단에 빨간색 에러 메시지 표시 |
| 수량이 0 이하 | ValidationError.mustBePositive | 필드 하단에 빨간색 에러 메시지 표시 |
| CoreData 저장 실패 | TradingJournalError.saveFailed | Alert 표시 + 재시도 옵션 |
| 네트워크 없음 (Phase 3) | NetworkError | Toast 메시지 + 오프라인 모드 전환 |
| 데이터 조회 실패 | TradingJournalError.fetchFailed | 빈 상태 화면 + 재시도 버튼 |

## 7. 시퀀스 다이어그램

### 7.1 매매 일지 작성

```
User                View                 ViewModel            Repository          CoreData
  |                   |                      |                    |                   |
  |--- 탭: + 버튼 ---->|                      |                    |                   |
  |                   |--- sheet 표시 ------->|                    |                   |
  |                   |                      |                    |                   |
  |--- 입력: 종목명 -->|                      |                    |                   |
  |                   |--- 검증 ------------>|                    |                   |
  |                   |<-- 검증 결과 ---------|                    |                   |
  |                   |                      |                    |                   |
  |--- 탭: 저장 ----->|                      |                    |                   |
  |                   |--- addJournal() ---->|                    |                   |
  |                   |                      |--- validate() ---->|                   |
  |                   |                      |<-- Success --------|                   |
  |                   |                      |--- save() -------->|                   |
  |                   |                      |                    |--- insert() ----->|
  |                   |                      |                    |<-- Success -------|
  |                   |                      |<-- Success --------|                   |
  |                   |                      |--- fetchJournals() |                   |
  |                   |<-- 목록 업데이트 -----|                    |                   |
  |<-- 화면 닫기 ------|                      |                    |                   |
```

### 7.2 매매 일지 삭제

```
User                View                 ViewModel            Repository          CoreData
  |                   |                      |                      |                 |
  |--- 스와이프 ------>|                      |                      |                 |
  |                   |--- 삭제 버튼 표시 --->|                      |                 |
  |                   |                      |                      |                 |
  |--- 탭: 삭제 ----->|                      |                      |                 |
  |                   |--- Alert 표시 ------->|                      |                 |
  |                   |                      |                      |                 |
  |--- 확인 --------->|                      |                      |                 |
  |                   |--- deleteJournal() -->|                      |                 |
  |                   |                      |--- delete(id) ------>|                 |
  |                   |                      |                      |--- fetch(id) -->|
  |                   |                      |                      |<-- object ------|
  |                   |                      |                      |--- delete() --->|
  |                   |                      |                      |<-- Success -----|
  |                   |                      |<-- Success ----------|                 |
  |                   |                      |--- fetchJournals() --|                 |
  |                   |<-- 목록 업데이트 -----|                      |                 |
  |<-- Toast 메시지 ---|                      |                      |                 |
```

## 8. 상태 관리

### 8.1 ViewModel 상태

```swift
@MainActor
class TradingJournalViewModel: ObservableObject {
    // 목록 상태
    @Published var journals: [TradingJournalEntity] = []
    @Published var isLoading: Bool = false
    @Published var error: TradingJournalError?

    // 필터 상태
    @Published var dateFilter: DateFilter = .all
    @Published var typeFilter: TradeTypeFilter = .all
    @Published var stockFilter: String? = nil

    // 페이지네이션 상태
    @Published var currentPage: Int = 0
    @Published var hasMore: Bool = true
    private let pageSize: Int = 20

    // 통계 상태
    @Published var stats: TradingStats?
    @Published var isCalculatingStats: Bool = false
}
```

### 8.2 View 상태

```swift
struct AddTradingJournalView: View {
    // 입력 상태
    @State private var tradeType: TradeType = .buy
    @State private var tradeDate: Date = Date()
    @State private var stockName: String = ""
    @State private var quantity: String = ""
    @State private var price: String = ""
    @State private var reason: String = ""

    // UI 상태
    @State private var validationError: String?
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss

    // 편집 모드
    var editingJournal: TradingJournalEntity?
}
```

## 9. 성능 최적화

### 9.1 목록 로딩 최적화

- **페이지네이션**: 20개씩 로드
- **LazyVStack**: 화면에 보이는 항목만 렌더링
- **IndexedFetch**: CoreData의 인덱스 활용

### 9.2 검색/필터 최적화

- **Debouncing**: 검색어 입력 0.3초 후 쿼리 실행
- **Predicate**: CoreData Predicate로 서버 측 필터링
- **캐싱**: 최근 필터 결과 메모리 캐시

### 9.3 통계 계산 최적화

- **백그라운드 스레드**: 통계 계산은 백그라운드에서 실행
- **증분 업데이트**: 전체 재계산 대신 변경된 부분만 업데이트
- **캐싱**: 계산된 통계를 캐시하여 재사용

## 10. 테스트 시나리오

### 10.1 단위 테스트

- [ ] Validator 테스트 (모든 검증 케이스)
- [ ] ProfitCalculator 테스트 (다양한 매수/매도 조합)
- [ ] StatsCalculator 테스트 (통계 계산 정확성)

### 10.2 통합 테스트

- [ ] ViewModel + Repository 연동 테스트
- [ ] CoreData CRUD 테스트
- [ ] 필터링 기능 테스트

### 10.3 UI 테스트

- [ ] 매매 일지 작성 플로우
- [ ] 수정/삭제 플로우
- [ ] 필터링 플로우
- [ ] 에러 처리 시나리오

## 11. 마이그레이션 계획 (Phase 2+)

### 11.1 데이터 마이그레이션

Phase 1에서 Phase 2로 전환 시 필요한 마이그레이션:

```
Phase 1 스키마:
- id, tradeType, tradeDate, stockName, quantity, price, reason

Phase 2 스키마 (추가):
+ profitLoss: Double (계산된 손익)
+ matchedBuyId: UUID? (매칭된 매수 일지 ID)
+ tags: [String] (태그)
```

### 11.2 마이그레이션 절차

1. CoreData 모델 버전 2 생성
2. Mapping Model 정의
3. 기존 데이터의 profitLoss 재계산
4. 앱 업데이트 시 자동 마이그레이션 실행
