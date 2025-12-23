# 매매일지 캘린더 화면 설계서

## 1. 화면 개요

### 1.1 화면 목적
- 월별 매매 활동을 한눈에 파악
- 특정 날짜의 매매 기록 빠른 접근
- 손익 패턴 시각적 확인

### 1.2 접근 경로
- 매매일지 탭 → 캘린더/리스트 세그먼트 전환
- 또는 별도 탭으로 제공 (추후 결정)

## 2. 화면 레이아웃

### 2.1 전체 구조 (ASCII)
```
┌─────────────────────────────────────┐
│ ◀ 2025년 1월           ▶  [리스트] │ ← 헤더
├─────────────────────────────────────┤
│ 월 총 손익: +123,456원 | 거래: 15건 │ ← 월별 통계 (접기 가능)
├─────────────────────────────────────┤
│  일  월  화  수  목  금  토        │ ← 요일 행
├─────────────────────────────────────┤
│          1   2   3   4              │
│      [$] [%] [%] [$]                │ ← 날짜 + 손익 인디케이터
│                                     │
│  5   6   7   8   9   10  11        │
│ [$] [%] [%] [$] [%] [$] [%]        │
│                                     │
│  12  13  14  15  16  17  18        │
│ [$] [%] [%] [$] [%] [$] [%]        │
│                                     │
│  19  20  21  22  23  24  25        │
│ [%] [$] [%] [$] [%] [$] [%]        │
│                                     │
│  26  27  28  29  30  31            │
│ [$] [%] [%] [$] [%] [$]            │
└─────────────────────────────────────┘

[$] = 수익 (파란색 인디케이터)
[%] = 손실 (빨간색 인디케이터)
```

### 2.2 날짜 셀 상세 (확대)
```
┌─────────┐
│   15    │ ← 날짜 (14pt, semibold)
│  ●●●    │ ← 거래 건수 인디케이터 (3개 = 3건)
│ +12.3K  │ ← 손익 금액 (12pt, caption)
│ +4.5%   │ ← 수익률 (11pt, caption2)
└─────────┘
 ↑ 파란색 테두리 (수익)
```

## 3. UI 컴포넌트 상세

### 3.1 헤더 영역

#### 3.1.1 월 선택 컨트롤
```swift
HStack {
    Button {
        // 이전 달
    } label: {
        Image(systemName: "chevron.left")
            .font(.title3)
    }

    Spacer()

    Text("2025년 1월")
        .font(.headline)
        .fontWeight(.semibold)

    Spacer()

    Button {
        // 다음 달
    } label: {
        Image(systemName: "chevron.right")
            .font(.title3)
    }
}
.padding(.horizontal, 16)
.padding(.vertical, 12)
```

**스타일**:
- 폰트: `.headline` (16pt)
- 패딩: 좌우 16pt, 상하 12pt
- 버튼 탭 영역: 최소 44×44pt

#### 3.1.2 뷰 전환 버튼
```swift
Button("리스트") {
    // 리스트 뷰로 전환
}
.font(.subheadline)
.foregroundColor(.accentColor)
```

### 3.2 월별 통계 카드 (접기 가능)

```swift
VStack(alignment: .leading, spacing: 6) {
    HStack {
        Text("월 통계")
            .font(.subheadline)
            .fontWeight(.semibold)

        Spacer()

        Button {
            withAnimation { isExpanded.toggle() }
        } label: {
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.caption)
        }
    }

    if isExpanded {
        HStack(spacing: 16) {
            StatItem(title: "총 손익", value: "+123,456원", color: .blue)
            StatItem(title: "거래", value: "15건", color: .secondary)
            StatItem(title: "승률", value: "73%", color: .green)
        }
    }
}
.padding(12)
.background(Color(.secondarySystemBackground))
.cornerRadius(10)
.padding(.horizontal, 16)
```

**스타일**:
- 배경색: `.secondarySystemBackground`
- 패딩: 내부 12pt, 외부 16pt
- 코너: 10pt
- 폰트: 제목 `.subheadline`, 값 `.caption`

### 3.3 캘린더 그리드

#### 3.3.1 요일 헤더
```swift
LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
    ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
        Text(day)
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }
}
```

**스타일**:
- 폰트: `.caption` (11pt)
- 색상: `.secondary`
- 패딩: 상하 8pt

#### 3.3.2 날짜 셀
```swift
struct CalendarDayCell: View {
    let day: Int
    let summary: DailyTradingSummary?
    let isToday: Bool
    let isCurrentMonth: Bool

    var body: some View {
        VStack(spacing: 2) {
            // 날짜
            Text("\(day)")
                .font(.subheadline)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isCurrentMonth ? .primary : .secondary)

            // 거래 인디케이터
            if let summary = summary {
                HStack(spacing: 2) {
                    ForEach(0..<min(summary.tradeCount, 3), id: \.self) { _ in
                        Circle()
                            .fill(summary.totalProfit >= 0 ? Color.blue : Color.red)
                            .frame(width: 4, height: 4)
                    }
                }
                .padding(.vertical, 2)

                // 손익 금액
                Text(summary.totalProfit.formatted(.currency(code: "KRW")))
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundColor(summary.totalProfit >= 0 ? .blue : .red)

                // 수익률 (선택)
                if abs(summary.profitRate) >= 1 {
                    Text(summary.profitRate.formatted(.percent.precision(.fractionLength(1))))
                        .font(.caption2)
                        .foregroundColor(summary.profitRate >= 0 ? .blue : .red)
                }
            }
        }
        .frame(height: 70) // 고정 높이
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isToday ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    summary != nil
                        ? (summary!.totalProfit >= 0 ? Color.blue : Color.red).opacity(0.3)
                        : Color.clear,
                    lineWidth: 2
                )
        )
        .onTapGesture {
            if summary != nil {
                // 해당일 매매일지 표시
            }
        }
    }
}
```

**스타일**:
- 셀 높이: 70pt (고정)
- 날짜 폰트: `.subheadline` (14pt)
- 손익 폰트: `.caption2` (11pt)
- 코너: 8pt
- 테두리: 수익(파란색)/손실(빨간색) 2pt
- 오늘: 배경색 `.accentColor` 10% 투명도

#### 3.3.3 거래 인디케이터
- 원형 점(Circle) 4pt 크기
- 최대 3개까지 표시 (3건 이상은 동일)
- 색상: 수익(파란색) / 손실(빨간색)
- 간격: 2pt

### 3.4 해당일 매매일지 시트

```swift
struct DailyTradesSheet: View {
    let date: Date
    let trades: [TradingRecord]

    var body: some View {
        NavigationView {
            List(trades) { trade in
                NavigationLink {
                    TradingJournalDetailView(record: trade)
                } label: {
                    TradingRecordRow(record: trade)
                        .padding(.vertical, 4)
                }
            }
            .navigationTitle(date.formatted(date: .long, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        // 시트 닫기
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
```

**스타일**:
- 시트 높이: 중간(.medium) 또는 전체(.large)
- 제목: 날짜 (예: "2025년 1월 15일")
- 리스트 항목: 기존 `TradingRecordRow` 재사용

## 4. 인터랙션 정의

### 4.1 제스처

#### 4.1.1 스와이프 (선택 사항)
- 좌측 스와이프: 다음 달 이동
- 우측 스와이프: 이전 달 이동
- 애니메이션: `.spring(duration: 0.3)`

#### 4.1.2 탭
- 날짜 셀 탭: 해당일 매매일지 시트 표시
- 통계 카드 탭: 접기/펼치기
- 거래 없는 날짜: 탭 무반응 (시각적 피드백 없음)

### 4.2 애니메이션

#### 4.2.1 월 전환
```swift
withAnimation(.spring(duration: 0.3)) {
    currentMonth = newMonth
}
```

#### 4.2.2 통계 카드 접기/펼치기
```swift
withAnimation(.easeInOut(duration: 0.2)) {
    isExpanded.toggle()
}
```

#### 4.2.3 시트 표시
```swift
.sheet(isPresented: $showingDailyTrades) {
    DailyTradesSheet(date: selectedDate, trades: dailyTrades)
}
```

### 4.3 상태 관리

```swift
@State private var currentMonth: DateComponents
@State private var selectedDate: Date?
@State private var showingDailyTrades = false
@State private var isStatExpanded = true
```

## 5. 스타일 가이드

### 5.1 색상

| 요소 | 색상 | 용도 |
|------|------|------|
| 수익 | `.blue` | 수익 금액, 테두리, 인디케이터 |
| 손실 | `.red` | 손실 금액, 테두리, 인디케이터 |
| 오늘 배경 | `.accentColor (10%)` | 오늘 날짜 강조 |
| 통계 카드 배경 | `.secondarySystemBackground` | 통계 카드 |
| 이전/다음 달 날짜 | `.secondary` | 비활성 날짜 |

### 5.2 타이포그래피

| 요소 | 폰트 | 크기 | 굵기 |
|------|------|------|------|
| 월 제목 | `.headline` | 16pt | semibold |
| 날짜 | `.subheadline` | 14pt | regular (오늘: bold) |
| 손익 금액 | `.caption2` | 11pt | regular |
| 수익률 | `.caption2` | 11pt | regular |
| 통계 제목 | `.subheadline` | 14pt | semibold |
| 통계 값 | `.caption` | 12pt | regular |

### 5.3 스페이싱

| 요소 | 값 |
|------|------|
| 헤더 패딩 (좌우) | 16pt |
| 헤더 패딩 (상하) | 12pt |
| 통계 카드 패딩 (내부) | 12pt |
| 통계 카드 패딩 (외부) | 16pt |
| 날짜 셀 간격 | 0pt (붙임) |
| 셀 내부 요소 간격 | 2pt |
| 인디케이터 간격 | 2pt |

### 5.4 크기

| 요소 | 값 |
|------|------|
| 날짜 셀 높이 | 70pt |
| 인디케이터 원 크기 | 4pt |
| 코너 라디우스 (셀) | 8pt |
| 코너 라디우스 (통계 카드) | 10pt |
| 테두리 두께 | 2pt |

## 6. 다크 모드 대응

### 6.1 색상 조정
- 수익/손실 색상은 다크 모드에서도 동일 유지
- 배경색: 시스템 자동 대응 (`.secondarySystemBackground`)
- 텍스트: 시스템 자동 대응 (`.primary`, `.secondary`)

### 6.2 시각적 대비
- 테두리 투명도 조정: 라이트(30%) / 다크(40%)
- 오늘 배경 투명도: 일관되게 10% 유지

## 7. 접근성

### 7.1 VoiceOver
```swift
.accessibilityLabel("\(day)일, \(summary?.tradeCount ?? 0)건 거래, \(summary?.totalProfit.formatted() ?? "거래 없음")")
.accessibilityHint("탭하여 상세 보기")
```

### 7.2 Dynamic Type
- 모든 폰트는 Dynamic Type 지원
- `.minimumScaleFactor(0.7)` 적용으로 레이아웃 유지

### 7.3 색상 대비
- WCAG AA 기준 충족
- 색맹 모드 대응 (테두리 + 텍스트 조합)

## 8. 반응형 대응

### 8.1 가로 모드
- 날짜 셀 크기 자동 조정 (`.flexible()`)
- 통계 카드는 가로로 확장
- 시트는 `.large` 크기로 표시

### 8.2 작은 화면 (SE 시리즈)
- 셀 높이: 60pt로 축소
- 폰트 크기: `.minimumScaleFactor(0.6)` 적용
- 수익률 표시 생략 가능

## 9. 성능 최적화

### 9.1 데이터 로딩
- 월별 데이터만 쿼리 (당월 ±1개월)
- 캐싱 적용 (동일 월 재방문 시 캐시 사용)

### 9.2 렌더링
- `LazyVGrid` 사용으로 지연 렌더링
- 날짜 셀 재사용 최적화

### 9.3 애니메이션
- `.spring(duration: 0.3)` 사용으로 부드러운 전환
- 과도한 애니메이션 지양

## 10. 화면 플로우

```
TradingJournalView
  │
  ├─ [리스트 모드] ─────────────┐
  │   └─ TradingRecordRow       │
  │        └─ Detail View        │
  │                              │
  └─ [캘린더 모드] ──────────────┤
      ├─ 월 선택 (◀ ▶)          │
      ├─ 통계 카드 (접기 가능)   │
      └─ 날짜 셀 탭              │
           └─ DailyTradesSheet ──┘
                └─ TradingRecordRow
                     └─ Detail View
```
