# 매매 일지 개선 요구사항 정의서

## 1. 개요

### 1.1 목적
사용자 피드백을 반영하여 매매 일지 기능의 사용성을 개선하고, 필요한 기능을 추가하여 사용자 경험을 향상시킵니다.

### 1.2 개선 범위
- UI 개선 (불필요한 요소 제거)
- 편의성 향상 (저장 버튼, 수정 기능)
- 검색/필터링 기능 추가
- 다국어 지원 (한글화)

## 2. 기능 요구사항

### 2.1 타이틀 요소 제거

#### 배경
현재 AddTradingJournalView에서 "매매 일지 작성" 타이틀이 중복 표시되어 화면이 복잡함

#### 요구사항
- [ ] AddTradingJournalView의 navigation title 제거 또는 간소화
- [ ] 화면 상단 여백 최적화

#### 우선순위
Medium

### 2.2 매매 기록 수정 기능

#### 배경
현재 매매 기록을 수정하려면 삭제 후 재작성해야 하는 불편함 존재

#### 요구사항
- [ ] TradingJournalCardView 탭 시 수정 화면 표시
- [ ] AddTradingJournalView에 수정 모드 지원
- [ ] 수정 시 기존 데이터 자동 로드
- [ ] 수정 완료 후 목록 자동 갱신

#### 수정 플로우
```
목록 화면 → 카드 탭 → 수정 시트 표시 → 데이터 편집 → 저장 → 목록 갱신
```

#### 우선순위
High

### 2.3 저장 버튼 개선

#### 배경
현재 입력 필드에 포커스가 있을 때만 저장 버튼이 표시되어 사용성이 떨어짐

#### 요구사항
- [ ] 입력 필드 포커스 여부와 관계없이 저장 버튼 항상 표시
- [ ] 유효성 검사 통과 시 저장 버튼 활성화
- [ ] 유효성 검사 실패 시 저장 버튼 비활성화 (시각적 피드백)

#### 적용 범위
- AddTradingJournalView (매매 일지)
- AddStockView (포트폴리오 종목)

#### UI 변경사항
```
[현재] 포커스 있을 때: 저장 버튼 + 완료 버튼
       포커스 없을 때: 버튼 숨김

[개선] 항상: 저장 버튼 표시 (유효성에 따라 활성화/비활성화)
       포커스 있을 때: 키보드 완료 버튼 추가 표시
```

#### 우선순위
High

### 2.4 승률 표시 제거

#### 배경
현재 승률 계산 로직이 부정확하고, 매수-매도 매칭 없이 단순 계산되어 의미 없음

#### 요구사항
- [ ] TradingJournalStatsView에서 승률 카드 제거
- [ ] TradingJournalViewModel의 winRate 계산 로직 제거 또는 deprecated 처리

#### 향후 계획
Phase 2에서 매수-매도 매칭 로직 추가 후 정확한 승률 계산 재도입

#### 우선순위
Medium

### 2.5 삭제 버튼 한글화

#### 배경
현재 스와이프 삭제 시 "Delete" 영문 표시

#### 요구사항
- [ ] 스와이프 삭제 버튼 텍스트를 "삭제"로 변경
- [ ] 삭제 확인 알림 메시지 한글화

#### 적용 범위
- TradingJournalListView
- StockListView (포트폴리오 종목 목록)

#### 우선순위
Low

### 2.6 검색 기능 추가

#### 배경
매매 기록이 많아지면 원하는 기록을 찾기 어려움

#### 요구사항

##### 2.6.1 날짜 필터
- [ ] 일별 검색: 특정 날짜의 매매 기록만 표시
- [ ] 월별 검색: 특정 월의 매매 기록만 표시
- [ ] 년도별 검색: 특정 연도의 매매 기록만 표시
- [ ] 전체 보기: 모든 기록 표시 (기본값)

##### 2.6.2 UI 구성
```
┌─────────────────────────────────────┐
│ 매매 일지                      [+]  │
├─────────────────────────────────────┤
│ [필터] 전체 ▼                       │
│   ├─ 전체                           │
│   ├─ 일별: [날짜 선택]              │
│   ├─ 월별: [월 선택]                │
│   └─ 년도별: [년도 선택]            │
├─────────────────────────────────────┤
│ [통계 섹션]                         │
├─────────────────────────────────────┤
│ 매매 기록 (필터링 결과)             │
│ ┌─────────────────────────────┐    │
│ │ 카드 1                       │    │
│ └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

##### 2.6.3 필터 동작
- 필터 선택 시 목록 즉시 갱신
- 통계도 필터링된 데이터 기준으로 계산
- 필터 상태는 화면 이동 시 유지

##### 2.6.4 DatePicker 스타일
- 일별: `.graphical` 스타일 (캘린더)
- 월별: `.wheel` 스타일 (월/년도 선택)
- 년도별: Picker (최근 10년)

#### 우선순위
High

## 3. 비기능 요구사항

### 3.1 성능
- 필터링 적용: 0.3초 이내
- 목록 갱신: 0.5초 이내
- 수정 화면 로딩: 즉시

### 3.2 사용성
- 수정 시 기존 데이터 즉시 표시
- 필터 선택 UI 직관적
- 저장 버튼 항상 접근 가능

### 3.3 접근성
- VoiceOver로 모든 기능 접근 가능
- 동적 텍스트 크기 지원
- 색상 대비 WCAG AA 준수

## 4. 데이터 모델 변경사항

### 4.1 TradingJournalViewModel 확장

```swift
// 추가 필터링 속성
@Published var filterType: FilterType = .all
@Published var selectedDate: Date = Date()
@Published var selectedMonth: Date = Date()
@Published var selectedYear: Int = Calendar.current.component(.year, from: Date())

enum FilterType {
    case all
    case daily
    case monthly
    case yearly
}

// 필터링 메서드
func applyFilter() {
    switch filterType {
    case .all:
        fetchJournals()
    case .daily:
        fetchJournalsByDate(selectedDate)
    case .monthly:
        fetchJournalsByMonth(selectedMonth)
    case .yearly:
        fetchJournalsByYear(selectedYear)
    }
}
```

### 4.2 Repository Protocol 확장

```swift
protocol TradingJournalRepositoryProtocol {
    // 기존 메서드들...

    // 추가 필터링 메서드
    func fetchByDate(_ date: Date) -> [TradingJournalEntity]
    func fetchByMonth(year: Int, month: Int) -> [TradingJournalEntity]
    func fetchByYear(_ year: Int) -> [TradingJournalEntity]
}
```

## 5. 화면 변경사항

### 5.1 TradingJournalListView
- 필터 버튼 추가 (상단 툴바)
- 필터 시트/메뉴 추가
- 승률 통계 제거

### 5.2 TradingJournalCardView
- onTapGesture 추가 (수정 화면 표시)
- NavigationLink 또는 sheet 연동

### 5.3 AddTradingJournalView
- 타이틀 간소화
- 저장 버튼 항상 표시
- editingJournal 파라미터 활용

### 5.4 AddStockView
- 저장 버튼 항상 표시 로직 추가

## 6. 개발 우선순위

### Phase 1 (필수)
1. 매매 기록 수정 기능 (2.2)
2. 저장 버튼 개선 (2.3)
3. 검색 기능 추가 (2.6)

### Phase 2 (권장)
4. 승률 표시 제거 (2.4)
5. 타이틀 요소 제거 (2.1)

### Phase 3 (선택)
6. 삭제 버튼 한글화 (2.5)

## 7. 테스트 계획

### 7.1 단위 테스트
- [ ] TradingJournalViewModel 필터링 로직
- [ ] Repository 날짜별 조회 메서드
- [ ] 승률 계산 로직 제거 검증

### 7.2 UI 테스트
- [ ] 매매 기록 탭 → 수정 화면 표시
- [ ] 필터 선택 → 목록 갱신
- [ ] 저장 버튼 활성화/비활성화

### 7.3 통합 테스트
- [ ] 수정 → 저장 → 목록 갱신 플로우
- [ ] 필터 + 통계 연동

## 8. 제약사항

- 기존 데이터 구조 유지 (마이그레이션 불필요)
- CoreData 스키마 변경 없음
- 오프라인 전용 (서버 동기화 없음)

## 9. 성공 지표

- 매매 기록 수정 기능 사용률: 주 1회 이상
- 필터 기능 사용률: 30% 이상
- 저장 버튼 접근성 만족도: 90% 이상

## 10. 참고사항

### 관련 이슈
- GitHub Issue: 생성 예정
- Label: `trading-journal`

### 관련 문서
- `/docs/trading-journal/TRADING_JOURNAL_SPEC.md`
- `/docs/trading-journal/TRADING_JOURNAL_PROCESS.md`
