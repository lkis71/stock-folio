# 매매 일지 프로세스 설계서

## 문서 정보

**버전:** v1.0
**최종 수정일:** 2024-12-24
**작성자:** Claude Code

## 변경 이력

### v1.0 (2024-12-24)
- 초기 작성
- 매매 일지 작성, 수정, 삭제, 필터링, 통계 조회 플로우 정의
- 데이터 흐름 및 비즈니스 규칙 수립
- 입력 검증, 손익 계산, 에러 처리 시나리오 정의

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

## 5. 비즈니스 규칙

### 5.1 입력 검증 규칙

#### 종목명 검증
1. 공백 체크: 빈 문자열 불허
2. 길이 체크: 최대 50자
3. 문자 제한: 영문, 숫자, 한글, 일부 특수문자만 허용 `()&-.`
4. SQL Injection 방지: 특수문자 필터링

#### 수량 검증
1. 숫자 변환 가능 여부 확인
2. 양수 체크: 0보다 큰 값만 허용
3. 범위 체크: 1 ~ 1,000,000주
4. 정수 체크: 소수점 불허

#### 가격 검증
1. 천단위 콤마 제거 후 숫자 변환
2. 양수 체크: 0보다 큰 값만 허용
3. 범위 체크: 최대 10억원
4. 소수점: 최대 2자리까지 허용

#### 날짜 검증
1. 미래 날짜 불허
2. 유효한 날짜 형식 확인

### 5.2 손익 계산 규칙 (Phase 2)

#### FIFO (First In First Out) 방식
1. 같은 종목의 매수 일지 필터링
2. 날짜순 정렬 (오래된 것부터)
3. 매도 수량만큼 순차적으로 매칭
4. 손익 = 매도금액 - 매칭된 매수금액

**예시**:
```
매수 1: 2024.01.10, 10주 × 50,000원 = 500,000원
매수 2: 2024.02.15, 5주 × 55,000원 = 275,000원
매도: 2024.03.01, 12주 × 60,000원 = 720,000원

→ 매칭: 매수1의 10주 + 매수2의 2주
→ 비용: 500,000원 + (2 × 55,000원) = 610,000원
→ 손익: 720,000원 - 610,000원 = +110,000원
```

### 5.3 통계 계산 규칙

#### 총 매매 횟수
- 매수 일지 개수
- 매도 일지 개수

#### 실현 손익
- **Phase 1**: 전체 매도금액 - 전체 매수금액 (단순 계산)
- **Phase 2**: FIFO 매칭 기반 정확한 손익 계산

#### 평균 수익률
- 계산식: (실현 손익 / 총 매수금액) × 100

#### 승률
- **Phase 1**: 매도 건수 대비 계산 (간단 버전)
- **Phase 2**: 실제 손익 기반 (수익 건수 / 총 매도 건수) × 100

#### 종목별 통계
1. 종목별로 그룹화
2. 각 종목의 매수/매도 횟수 집계
3. 각 종목의 총 손익 계산
4. 거래 횟수 기준 내림차순 정렬
5. TOP 5 종목만 표시

#### 월별 통계
1. 년/월 기준으로 그룹화
2. 각 월의 총 손익 계산
3. 각 월의 거래 횟수 집계
4. 시간순 정렬 (오래된 달부터)

## 6. 에러 처리

### 6.1 에러 유형

#### 검증 에러 (ValidationError)
- `empty`: 필수 항목 미입력
- `tooLong`: 입력 길이 초과
- `invalidCharacters`: 허용되지 않는 문자 포함
- `invalidNumber`: 숫자 형식 오류
- `mustBePositive`: 양수가 아님
- `outOfRange`: 허용 범위 초과
- `futureDate`: 미래 날짜 선택

#### 데이터 처리 에러 (TradingJournalError)
- `invalidInput`: 입력 검증 실패
- `saveFailed`: 저장 실패
- `fetchFailed`: 조회 실패
- `deleteFailed`: 삭제 실패
- `notFound`: 데이터 없음

### 6.2 에러 메시지

| 에러 유형 | 사용자 메시지 |
|----------|-------------|
| empty | "필수 항목입니다." |
| tooLong | "N자 이내로 입력해주세요." |
| invalidCharacters | "사용할 수 없는 문자가 포함되어 있습니다." |
| invalidNumber | "올바른 숫자를 입력해주세요." |
| mustBePositive | "0보다 큰 값을 입력해주세요." |
| outOfRange | "입력 가능한 범위를 초과했습니다." |
| futureDate | "미래 날짜는 선택할 수 없습니다." |
| saveFailed | "저장에 실패했습니다. 다시 시도해주세요." |
| fetchFailed | "데이터를 불러오는데 실패했습니다." |
| deleteFailed | "삭제에 실패했습니다." |
| notFound | "매매 일지를 찾을 수 없습니다." |

### 6.3 에러 처리 시나리오

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

#### 목록 상태
- `journals`: 매매 일지 목록
- `isLoading`: 로딩 중 여부
- `error`: 에러 정보

#### 필터 상태
- `dateFilter`: 날짜 필터 (전체/이번달/지난달/사용자지정)
- `typeFilter`: 매매 유형 필터 (전체/매수/매도)
- `stockFilter`: 종목 필터 (전체/특정 종목)

#### 페이지네이션 상태
- `currentPage`: 현재 페이지 번호
- `hasMore`: 추가 데이터 존재 여부
- `pageSize`: 페이지당 항목 수 (20개)

#### 통계 상태
- `stats`: 통계 데이터
- `isCalculatingStats`: 통계 계산 중 여부

### 8.2 View 상태

#### 입력 상태
- `tradeType`: 매매 유형 (매수/매도)
- `tradeDate`: 매매 날짜
- `stockName`: 종목명
- `quantity`: 수량
- `price`: 단가
- `reason`: 매매 이유

#### UI 상태
- `validationError`: 검증 에러 메시지
- `focusedField`: 현재 포커스된 입력 필드
- `dismiss`: 화면 닫기 액션

#### 편집 모드
- `editingJournal`: 수정할 매매 일지 (nil이면 작성 모드)

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
