# Stock Portfolio App - 화면 설계서

## 문서 정보

**버전:** v1.1
**최종 수정일:** 2024-12-24
**작성자:** Claude Code

## 변경 이력

### v1.1 (2024-12-24)
- draw.io 와이어프레임 이미지 추가
- 화면별 시각적 다이어그램 보강

### v1.0 (2024-12-24)
- 초기 작성
- 메인 화면, 시드머니 설정, 종목 추가/편집 화면 설계
- UI 컴포넌트 상세 정의 (Navigation Bar, 차트, 리스트)
- 컴팩트 디자인 원칙 적용

## 1. 메인 화면 (포트폴리오 대시보드)

### 1.1 레이아웃

![메인 대시보드](./images/screen-main-dashboard.drawio.svg)

<details>
<summary>ASCII 다이어그램 보기</summary>

```
┌─────────────────────────────────────┐
│                              ⚙️     │  ← Navigation Bar (타이틀 없음)
├─────────────────────────────────────┤
│   ┌───────────────┬───────────────┐ │
│   │ 투자 금액      │ 남은 현금      │ │  ← 2단 레이아웃
│   │ ₩ 50,000,000 │ ₩ 50,000,000  │ │
│   │ 50%          │ 50%           │ │  ← 비율 표시
│   └───────────────┴───────────────┘ │
│                                     │
│          [파이 차트]                  │
│                                     │
│      ●  삼성전자  40%                 │  ← 차트 중앙
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ● 삼성전자 40%   ● 카카오 20% │   │  ← 커스텀 범례 (2열)
│  │ ● SK하이닉스 30% ● NAVER 10% │   │  ← 스크롤 가능
│  └─────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│  보유 종목 (6/10)                    │  ← 현재/전체 개수 표시
├─────────────────────────────────────┤
│  ┌───────────────────────────────┐  │
│  │ 삼성전자                    40% │  │
│  │ ₩ 4,000,000                   │  │  ← 종목 1
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ SK하이닉스                   30% │  │
│  │ ₩ 3,000,000                   │  │  ← 종목 2
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ 카카오                       20% │  │
│  │ ₩ 2,000,000                   │  │  ← 종목 3~6 (최대 6개)
│  └───────────────────────────────┘  │
│  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  │
│  │      ↓ 슬라이드하여 더 보기 ↓    │  │  ← 더보기 힌트 (6개 초과 시)
│  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  │
│                                     │
│              [ + ]                  │  ← Floating Action Button
└─────────────────────────────────────┘
```

</details>

### 1.2 UI 요소

#### Navigation Bar
- **제목**: 없음 (타이틀 숨김)
- **배경**: 투명
- **스타일**: Inline (타이틀 없이 툴바만 표시)
- **우측 버튼**: ⚙️ (설정 아이콘)
  - SF Symbol: "gearshape"
  - 액션: 시드머니 설정 시트 표시

#### 시드머니 정보 섹션
- **"총 시드머니" 레이블/금액**: 숨김 (Hidden)
- **2단 레이아웃 (투자/현금)**: 표시 유지

**2단 레이아웃 (투자/현금):**
- **배경**: 카드 형태
- **레이아웃**: HStack (2개 컬럼)
- **코너 반경**: 12pt

**좌측 (투자 금액):**
- 레이블: "투자 금액" (`.caption`, `.secondary`)
- 금액: "₩ 50,000,000" (`.title3`, `.bold`)
- 비율: "50%" (`.headline`, `.blue`)

**우측 (남은 현금):**
- 레이블: "남은 현금" (`.caption`, `.secondary`)
- 금액: "₩ 50,000,000" (`.title3`, `.bold`)
- 비율: "50%" (`.headline`, `.green`)

- **여백**: 좌우 16pt

#### 파이 차트 섹션
- **차트 크기**:
  - 레이아웃: AspectRatio 1:1 (정사각형)
  - 최대 높이: 250pt
  - 반응형: 화면 너비에 맞춰 자동 조정
- **타입**: Pie Chart (Swift Charts)
- **색상**:
  - 종목별 개별 색상 선택 가능 (10가지 색상 팔레트)
  - 차트와 보유 종목 리스트에서 동일한 색상 사용
  - 그라디언트 효과: 입체감 표현 (색상 → 색상.opacity(0.7))
- **정렬**: 비중 기준 내림차순 정렬
- **툴팁**:
  - **표시 조건**: 차트 또는 범례 클릭 시
  - **위치**: 차트 중앙 오버레이
  - **내용**:
    - 종목명 (색상 인디케이터 포함)
    - 투자금액 (통화 포맷)
    - 비중 (종목 색상으로 강조)
  - **스타일**:
    - 배경: .ultraThinMaterial
    - 테두리: 종목 색상.opacity(0.3), 1.5pt
    - 코너 반경: 12pt
    - 그림자: .black.opacity(0.2), radius 8, offset (0, 4)
    - 너비: 200pt
  - **애니메이션**: .scale + .opacity (0.3초)
- **인터랙션**:
  - 차트 클릭: 해당 종목 툴팁 표시
  - 범례 클릭: 해당 종목 툴팁 표시
  - 재클릭: 툴팁 숨김
  - 커스텀 범례 표시 (2열 그리드, 스크롤 가능)
- **시각 효과**:
  - 그림자: color: .black.opacity(0.15), radius: 8, offset: (0, 4)
  - 코너 반경: 4pt (각 섹터)
- **여백**: 상하 16pt
- **컨테이너**: 고정 높이 제거, 동적 높이 사용

#### 커스텀 범례 (Chart Legend)
- **레이아웃**: LazyVGrid (2열)
  - 컬럼: 2개의 flexible 컬럼
  - 간격: 12pt (horizontal), 8pt (vertical)
- **스크롤**:
  - ScrollView 활성화 (종목이 많을 경우)
  - 최대 높이: 제한 없음 (동적)
- **범례 아이템**:
  - 색상 인디케이터: 10x10pt 원형
  - 종목명: `.caption` 폰트
  - 비중: `.caption` 폰트, 회색
  - 레이아웃: HStack (색상 + 종목명 + 비중)
- **인터랙션**:
  - 클릭 시 해당 종목 툴팁 표시
  - 선택된 항목 배경 강조 (종목 색상.opacity(0.2))
  - 선택된 항목 테두리 (종목 색상, 2pt)
- **배경**:
  - 기본: Color(.tertiarySystemBackground)
  - 선택: 종목 색상.opacity(0.2)
- **여백**: 상 12pt

#### 보유 종목 리스트
- **섹션 헤더**: "보유 종목 (표시개수/전체개수)"
  - 폰트: `.headline`
  - 여백: 좌 16pt
  - 예시: "보유 종목 (6/10)" - 10개 중 6개 표시
- **정렬**: 비중 기준 내림차순 정렬 (차트와 동일한 순서)
- **표시 제한**:
  - **기본 표시**: 최대 6개
  - **추가 표시**: "더보기" 버튼 클릭 시 전체 표시
  - **접힌 상태**: 6개 초과 시 "더 보기" 힌트 표시
- **리스트 아이템**:
  - 배경: 카드 형태 (흰색/다크모드 대응)
  - 코너 반경: 12pt
  - 섀도우: 경미한 그림자
  - 여백: 좌우 16pt, 상하 8pt

**리스트 아이템 내부:**
```
┌─────────────────────────────────┐
│ [색상 인디케이터] 삼성전자     40% │  ← 좌측 5pt 색상 바
│ ₩ 4,000,000                     │
└─────────────────────────────────┘
```
- **좌측**: 5pt 너비 색상 인디케이터 (차트와 동일한 색상)
- **종목명**:
  - 폰트: `.headline`
  - 색상: `.primary`
- **비중**:
  - 폰트: `.headline`
  - 색상: `.secondary`
  - 위치: 우측 정렬
- **금액**:
  - 폰트: `.subheadline`
  - 숫자: 모노스페이스
  - 색상: `.secondary`

**더 보기 힌트 (6개 초과 시):**
- **조건**: 종목이 6개를 초과할 때만 표시
- **텍스트**: "↓ 슬라이드하여 더 보기"
- **폰트**: `.caption`
- **색상**: `.tertiary`
- **애니메이션**: 부드러운 페이드 효과

#### Floating Action Button (+)
- **아이콘**: SF Symbol "plus.circle.fill"
- **크기**: 56x56pt
- **위치**: 우측 하단 (16pt margin)
- **색상**: `.accentColor` (파란색)
- **액션**: 종목 추가 시트 표시

### 1.3 인터랙션

- **설정 버튼 (⚙️)**: 시드머니 설정 시트 표시
- **스와이프 삭제**: 우측에서 좌측으로 스와이프하여 종목 삭제 (유일한 삭제 방법)
  - swipeActions 사용 (trailing edge)
  - allowsFullSwipe: true (전체 스와이프로 즉시 삭제)
  - 삭제 아이콘: trash (SF Symbol)
- **탭**: 종목 탭하면 편집 시트 표시 (삭제 버튼 없음)
- **+ 버튼**: 종목 추가 시트 표시
- **차트 탭**: 해당 종목 하이라이트
- **종목 리스트 스크롤**: 6개 초과 시 스크롤하여 나머지 종목 표시

---

## 2. 시드머니 설정 화면 (Sheet)

### 2.1 레이아웃

![시드머니 설정](./images/screen-seed-money.drawio.svg)

<details>
<summary>ASCII 다이어그램 보기</summary>

```
┌─────────────────────────────────────┐
│  ✕  시드머니 설정                     │  ← Sheet Header
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │                                 │ │  ← ScrollView 시작
│ │   총 시드머니                     │ │
│ │   ┌───────────────────────────┐ │ │
│ │   │ ₩ 100,000,000             │ │ │  ← TextField (숫자)
│ │   └───────────────────────────┘ │ │
│ │                                 │ │
│ │   💡 투자 가능한 총 금액을 입력하세요│ │  ← 안내 문구
│ │                                 │ │
│ └─────────────────────────────────┘ │  ← ScrollView 끝
│                                     │
│   ┌─────────────────────────────┐   │  ← safeAreaInset 영역
│   │        저장                  │   │  ← Primary Button
│   └─────────────────────────────┘   │
│                                     │
│   ┌─────────────────────────────┐   │
│   │        취소                  │   │  ← Secondary Button
│   └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

</details>

### 2.2 UI 요소

#### 레이아웃 구조
- **구조**: ScrollView + safeAreaInset
  - ScrollView: 입력 필드와 안내 문구 포함
  - safeAreaInset: 버튼 영역 (항상 하단 고정)
- **장점**:
  - 키보드 표시 시 자동 스크롤
  - 버튼 항상 접근 가능
  - 작은 화면 대응

#### Sheet Header
- **좌측**: ✕ 버튼 (닫기)
- **중앙**: "시드머니 설정" 제목
  - 폰트: `.headline`
- **높이**: 60pt

#### 시드머니 입력
- **레이블**: "총 시드머니"
  - 폰트: `.subheadline`
  - 색상: `.secondary`
- **TextField**:
  - Placeholder: "₩ 0"
  - 키보드: 숫자 패드
  - 배경: 시스템 회색 배경
  - 패딩: 12pt
  - 코너 반경: 8pt
  - 포맷: 통화 포맷 (자동 천단위 구분)

#### 안내 문구
- **텍스트**: "💡 투자 가능한 총 금액을 입력하세요"
- **폰트**: `.footnote`
- **색상**: `.secondary`

#### 버튼 영역
- **레이아웃**: safeAreaInset (하단 고정)
- **상단 구분선**:
  - 두께: 0.5pt
  - 색상: `Color(.separator)` (라이트/다크 모드 자동 대응)
  - 목적: 페이지 내용과 버튼 영역 시각적 구분
- **상단 여백**: 16pt (구분선과 버튼 사이)

#### 저장 버튼
- **스타일**: Prominent Button
- **배경**: `.accentColor` (파란색)
- **텍스트**: "저장" (흰색, `.headline`)
- **높이**: 50pt
- **코너 반경**: 12pt
- **상태**:
  - 비활성: 금액이 0 이하일 때 (투명도 0.5로 표시)
  - 활성: 금액 입력 완료 (투명도 1.0)
- **Disabled 스타일**:
  - 기존: 회색 배경 (`Color.gray`)
  - 개선: 브랜드 색상 유지 + 투명도 조절 (`Color.accentColor` + `.opacity(isValidInput ? 1.0 : 0.5)`)
  - 이점: 브랜드 일관성 유지, 현대적 디자인 패턴

#### 취소 버튼
- **스타일**: Secondary Button
- **배경**: 투명
- **텍스트**: "취소" (`.accentColor`, `.headline`)
- **높이**: 50pt
- **액션**: 시트 닫기

### 2.3 인터랙션

- **입력 검증**:
  - 금액: 0보다 커야 함, 음수 불가
  - 조건 미충족 시 저장 버튼 비활성화
- **저장 액션**:
  1. UserDefaults에 저장
  2. 시트 닫기
  3. 메인 화면 자동 업데이트
- **취소 액션**: 시트 닫기 (저장 안 함)

---

## 3. 종목 추가 화면 (Sheet)

### 3.1 레이아웃

![종목 추가](./images/screen-add-stock.drawio.svg)

<details>
<summary>ASCII 다이어그램 보기</summary>

```
┌─────────────────────────────────────┐
│  ✕  종목 추가                        │  ← Sheet Header
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │                                 │ │  ← ScrollView 시작
│ │   종목명                         │ │
│ │   ┌───────────────────────────┐ │ │
│ │   │ 삼성전자                   │ │ │  ← TextField
│ │   └───────────────────────────┘ │ │
│ │                                 │ │
│ │   매수 금액                      │ │
│ │   ┌───────────────────────────┐ │ │
│ │   │ ₩ 1,000,000               │ │ │  ← TextField (숫자)
│ │   └───────────────────────────┘ │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │  ← ScrollView 끝
│                                     │
│   ┌─────────────────────────────┐   │  ← safeAreaInset 영역
│   │        저장                  │   │  ← Primary Button
│   └─────────────────────────────┘   │
│                                     │
│   ┌─────────────────────────────┐   │
│   │        취소                  │   │  ← Secondary Button
│   └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

</details>

### 3.2 UI 요소

#### 레이아웃 구조
- **구조**: ScrollView + safeAreaInset
  - ScrollView: 입력 필드 포함
  - safeAreaInset: 버튼 영역 (항상 하단 고정)
- **장점**:
  - 키보드 표시 시 자동 스크롤
  - 버튼 항상 접근 가능
  - 작은 화면 대응

#### Sheet Header
- **좌측**: ✕ 버튼 (닫기)
- **중앙**: "종목 추가" 제목
  - 폰트: `.headline`
- **높이**: 60pt

#### 종목명 입력
- **레이블**: "종목명"
  - 폰트: `.subheadline`
  - 색상: `.secondary`
- **TextField**:
  - Placeholder: "예: 삼성전자"
  - 키보드: 기본 키보드
  - 배경: 시스템 회색 배경
  - 패딩: 12pt
  - 코너 반경: 8pt

#### 매수 금액 입력
- **레이블**: "매수 금액"
  - 폰트: `.subheadline`
  - 색상: `.secondary`
- **TextField**:
  - Placeholder: "₩ 0"
  - 키보드: 숫자 패드 (천단위 콤마 자동)
  - 배경: 시스템 회색 배경
  - 패딩: 12pt
  - 코너 반경: 8pt
  - 포맷: 통화 포맷 (자동 천단위 구분)

#### 색상 선택
- **레이블**: "차트 색상"
  - 폰트: `.subheadline`
  - 색상: `.secondary`
- **색상 그리드**:
  - 레이아웃: LazyVGrid (5개 컬럼)
  - 간격: 12pt
  - 색상 선택기: 40x40pt 원형
  - 선택 표시: 체크마크 아이콘 + 3pt 테두리
  - 배경: 시스템 회색 배경
  - 패딩: 전체 12pt
  - 코너 반경: 8pt

#### 버튼 영역
- **레이아웃**: safeAreaInset (하단 고정)
- **표시 조건**: 입력창 포커스 시에만 표시
- **애니메이션**:
  - 효과: offset + opacity
  - offset(y): 포커스 시 0, 미포커스 시 200
  - opacity: 포커스 시 1, 미포커스 시 0
  - 타입: .interactiveSpring()
- **상단 구분선**:
  - 두께: 0.5pt
  - 색상: `Color(.separator)` (라이트/다크 모드 자동 대응)
  - 목적: 페이지 내용과 버튼 영역 시각적 구분
- **상단 여백**: 16pt (구분선과 버튼 사이)

#### 저장 버튼
- **스타일**: Prominent Button
- **배경**: `.accentColor` (파란색)
- **텍스트**: "저장" (흰색, `.headline`)
- **높이**: 50pt
- **코너 반경**: 12pt
- **상태**:
  - 비활성: 종목명 또는 금액이 비어있을 때 (투명도 0.5로 표시)
  - 활성: 모든 필드 입력 완료 (투명도 1.0)
- **Disabled 스타일**:
  - 기존: 회색 배경 (`Color.gray`)
  - 개선: 브랜드 색상 유지 + 투명도 조절 (`Color.accentColor` + `.opacity(isValidInput ? 1.0 : 0.5)`)
  - 이점: 브랜드 일관성 유지, 현대적 디자인 패턴

#### 완료 버튼
- **스타일**: Secondary Button
- **배경**: 투명
- **텍스트**: "완료" (`.primary`, `.headline`)
- **높이**: 50pt
- **액션**: 키보드와 버튼 숨김 (focusedField = nil)

### 2.3 인터랙션

- **입력 검증**:
  - 종목명: 공백 불가
  - 금액: 0보다 커야 함, 음수 불가
  - 조건 미충족 시 저장 버튼 비활성화
- **저장 액션**:
  1. Core Data에 저장
  2. 시트 닫기
  3. 메인 화면 자동 업데이트 (애니메이션)
- **빈 영역 터치**: 키보드와 버튼 숨김 (focusedField = nil)
- **버튼 표시/숨김**:
  - 포커스 시: 저장/완료 버튼 표시 (offset 0, opacity 1)
  - 비포커스 시: 버튼 숨김 (offset 200, opacity 0)

---

## 4. 종목 편집 화면 (Sheet)

### 3.1 레이아웃

종목 추가 화면과 동일하되:
- **제목**: "종목 편집"
- **기본값**: 기존 데이터로 채워짐
- **삭제 버튼**: 제거됨 (스와이프 삭제로 대체)

```
┌─────────────────────────────────────┐
│  ✕  종목 편집                        │
├─────────────────────────────────────┤
│   ... (종목 추가와 동일) ...         │
│                                     │
│   ┌─────────────────────────────┐   │
│   │        저장                  │   │
│   └─────────────────────────────┘   │
│                                     │
│   ┌─────────────────────────────┐   │
│   │        취소                  │   │
│   └─────────────────────────────┘   │
│                                     │
│   ⚠️ 삭제는 리스트에서 스와이프       │
└─────────────────────────────────────┘
```

### 3.2 추가 요소

#### 삭제 버튼 (제거됨)
- 종목 편집 화면에서 삭제 버튼이 제거됨
- **삭제 방법**: 종목 리스트에서 스와이프하여 삭제
- 스와이프 삭제가 더 직관적인 UX 제공

---

## 5. 빈 상태 화면

### 5.1 레이아웃

![빈 상태](./images/screen-empty-state.drawio.svg)

<details>
<summary>ASCII 다이어그램 보기</summary>

```
┌─────────────────────────────────────┐
│                              ⚙️     │  ← Navigation Bar (타이틀 없음)
├─────────────────────────────────────┤
│                                     │
│                                     │
│                                     │
│           📊                        │  ← SF Symbol
│                                     │
│      아직 보유 종목이 없습니다         │  ← 제목
│                                     │
│   + 버튼을 눌러 첫 종목을 추가해보세요  │  ← 설명
│                                     │
│                                     │
│   ┌─────────────────────────────┐   │
│   │    + 종목 추가하기            │   │  ← CTA 버튼
│   └─────────────────────────────┘   │
│                                     │
│                                     │
│                                     │
│                                     │
│              [ + ]                  │
└─────────────────────────────────────┘
```

</details>

### 5.2 UI 요소

#### 아이콘
- **심볼**: SF Symbol "chart.pie.fill"
- **크기**: 80x80pt
- **색상**: `.secondary` (회색)

#### 제목
- **텍스트**: "아직 보유 종목이 없습니다"
- **폰트**: `.title2`, `.semibold`
- **색상**: `.primary`

#### 설명
- **텍스트**: "+ 버튼을 눌러 첫 종목을 추가해보세요"
- **폰트**: `.body`
- **색상**: `.secondary`

#### CTA 버튼
- **스타일**: Bordered Button
- **텍스트**: "+ 종목 추가하기"
- **테두리**: `.accentColor`
- **액션**: 종목 추가 시트 표시

---

## 6. 색상 시스템

### 5.1 차트 색상 팔레트 (순서대로 자동 할당)

1. **파란색**: `Color.blue`
2. **초록색**: `Color.green`
3. **주황색**: `Color.orange`
4. **보라색**: `Color.purple`
5. **분홍색**: `Color.pink`
6. **시안색**: `Color.cyan`
7. **인디고**: `Color.indigo`
8. **민트색**: `Color.mint`
9. **청록색**: `Color.teal`
10. **노란색**: `Color.yellow`

### 5.2 시스템 색상

- **Primary**: `.primary` (다크모드 대응)
- **Secondary**: `.secondary`
- **Background**: `.systemBackground`
- **Card**: `.secondarySystemBackground`
- **Accent**: `.blue` (또는 사용자 지정 색상)

---

## 7. 타이포그래피

| 요소 | 폰트 스타일 | 크기 | 굵기 |
|------|-----------|------|------|
| Navigation Title | `.largeTitle` | 34pt | Regular |
| 총 투자 금액 | `.largeTitle` | 34pt | Bold |
| 섹션 헤더 | `.headline` | 17pt | Semibold |
| 종목명 | `.headline` | 17pt | Semibold |
| 금액 | `.subheadline` | 15pt | Regular |
| 비중 | `.headline` | 17pt | Regular |
| 버튼 텍스트 | `.headline` | 17pt | Semibold |
| 레이블 | `.subheadline` | 15pt | Regular |
| 빈 상태 제목 | `.title2` | 22pt | Semibold |
| 빈 상태 설명 | `.body` | 17pt | Regular |

---

## 8. 스페이싱 & 레이아웃

### 7.1 여백 (Padding)
- **섹션 간**: 24pt
- **카드 간**: 8pt
- **화면 좌우**: 16pt
- **카드 내부**: 16pt
- **텍스트 그룹**: 4pt

### 7.2 크기
- **버튼 높이**: 50pt
- **카드 최소 높이**: 60pt
- **차트 크기**:
  - AspectRatio: 1:1 (정사각형)
  - 최대 높이: 250pt
  - 동적 크기 조정 (화면 너비 기반)
- **FAB 크기**: 56x56pt
- **범례 색상 인디케이터**: 8x8pt (원형)

### 7.3 코너 반경
- **카드**: 12pt
- **버튼**: 12pt
- **TextField**: 8pt
- **FAB**: 28pt (원형)

---

## 9. 애니메이션

### 8.1 화면 전환
- **Sheet 표시/닫기**: 기본 슬라이드 애니메이션
- **리스트 아이템 추가**: Fade + Slide from bottom (0.3초)
- **리스트 아이템 삭제**: Fade + Slide to trailing (0.3초)

### 8.2 차트 업데이트
- **데이터 변경 시**: Smooth transition (0.5초)
- **이징**: `.easeInOut`

### 8.3 인터랙션
- **버튼 탭**: Scale down (0.95) + 스프링 애니메이션
- **FAB**: Bounce 효과

---

## 10. 다크 모드

### 9.1 자동 대응
- 모든 색상은 시스템 색상 사용
- `.primary`, `.secondary`, `.systemBackground` 자동 전환

### 9.2 차트 색상
- 라이트/다크 모드 모두에서 가시성 유지
- 필요시 색상 밝기 자동 조정

---

## 11. 접근성 (Accessibility)

### 10.1 VoiceOver
- 모든 버튼에 적절한 레이블 제공
- 차트 데이터는 텍스트로도 읽을 수 있도록

### 10.2 Dynamic Type
- 모든 텍스트는 사용자 설정 폰트 크기에 대응

### 10.3 색상 대비
- WCAG AA 기준 충족 (4.5:1 이상)

---

## 12. 기술 구현 세부사항

### 11.1 차트 레이아웃
- **PortfolioChartView**:
  - 고정 높이 제거 (이전: 280pt)
  - AspectRatio(1, contentMode: .fit) 사용
  - frame(maxHeight: 250) 제약
  - 장점: 반응형 디자인, 다양한 화면 크기 대응

- **MainDashboardView**:
  - 차트 컨테이너 고정 높이 제거 (이전: 360pt)
  - 동적 높이 자동 계산
  - 장점: 콘텐츠에 맞춰 자연스러운 레이아웃

### 11.2 커스텀 범례
- **구현**:
  - LazyVGrid 사용 (2개 컬럼)
  - ScrollView로 감싸기
  - gridItem: GridItem(.flexible()) 2개
  - spacing: horizontal 12pt, vertical 8pt
- **아이템 구성**:
  - Circle().fill(color).frame(width: 8, height: 8)
  - Text(name).font(.caption)
  - Text(percentage).font(.caption).foregroundColor(.secondary)

### 11.3 ScrollView + safeAreaInset 패턴
- **AddStockView & SeedMoneySettingsView**:
  - ScrollView: 입력 폼 영역
  - safeAreaInset(edge: .bottom): 버튼 영역
- **장점**:
  - 키보드 표시 시 자동 스크롤
  - 버튼 항상 화면 하단 고정
  - 작은 화면에서도 모든 콘텐츠 접근 가능
  - iOS 네이티브 동작과 일치

### 11.4 보유 종목 리스트 표시 제한
- **기본 표시 개수**: 6개
- **동작 방식**:
  - 6개 이하: 전체 표시
  - 6개 초과: 처음 6개만 표시 + "더 보기" 힌트
  - 스크롤 시 추가 종목 표시
- **구현**:
  ```swift
  let visibleCount = 6
  let displayedHoldings = holdings.prefix(visibleCount)
  let hasMore = holdings.count > visibleCount
  ```
- **섹션 헤더**: "보유 종목 (표시개수/전체개수)"
  - 예: "보유 종목 (6/10)"

### 11.5 Navigation Bar 숨김
- **타이틀**: 없음 (.navigationTitle 제거 또는 빈 문자열)
- **스타일**: .inline (Large Title 비활성)
- **표시 요소**: 설정 버튼(⚙️)만 표시
- **장점**: 화면 공간 효율적 사용

### 11.6 시드머니 레이블 숨김
- **숨김 대상**: "총 시드머니" 레이블 및 금액만 숨김
- **표시 유지**: 투자 금액/남은 현금 2단 카드는 그대로 표시
- **시드머니 수정**: 설정 화면에서만 가능
- **장점**: 핵심 정보(투자금/현금)는 유지하면서 화면 간소화

---

## 13. 매매 일지 화면

### 13.1 탭 바 네비게이션

```
┌─────────────────────────────────────┐
│                                     │
│          [화면 콘텐츠]               │
│                                     │
├─────────────────────────────────────┤
│  📊 포트폴리오    📝 매매 일지       │  ← 탭 바
└─────────────────────────────────────┘
```

**구현:**
- **구조**: `TabView` (ContentView.swift)
- **탭 아이템**:
  - **포트폴리오**: `Label("포트폴리오", systemImage: "chart.pie.fill")`
  - **매매 일지**: `Label("매매 일지", systemImage: "book.fill")`

### 13.2 매매 일지 목록 화면

```
┌─────────────────────────────────────┐
│ 매매 일지                          + │  ← Navigation Bar
├─────────────────────────────────────┤
│ ┌─ 통계 섹션 ───────────────────┐   │
│ │  ┌──────┐ ┌──────┐ ┌──────┐  │   │
│ │  │총매매│ │ 매수 │ │ 매도 │  │   │  ← 상단 통계 카드 (3개)
│ │  │25건 │ │15건 │ │10건 │  │   │
│ │  └──────┘ └──────┘ └──────┘  │   │
│ │  ┌────────────┐ ┌──────────┐ │   │
│ │  │ 실현 손익   │ │  승률    │ │   │  ← 하단 통계 카드 (2개)
│ │  │+₩500,000원│ │  70.0%  │ │   │
│ │  └────────────┘ └──────────┘ │   │
│ └───────────────────────────────┘   │
├─────────────────────────────────────┤
│ 매매 기록                            │  ← 섹션 헤더
├─────────────────────────────────────┤
│ 삼성전자                  매수       │  ← 매매 일지 카드
│ 2024.12.18      10주 × 70,000원    │
│ 700,000원                          │
│ 실적 발표 후 주가 상승 예상         │  ← 매매 이유 (선택)
├─────────────────────────────────────┤
│ 카카오                    매도       │
│ 2024.12.17       5주 × 55,000원    │
│ 275,000원                          │
├─────────────────────────────────────┤
│ NAVER                    매수       │
│ 2024.12.15       3주 × 200,000원   │
│ 600,000원                          │
└─────────────────────────────────────┘
```

**구현 구조:**

#### TradingJournalListView
- **구조**: `NavigationView` + `List`
- **조건부 렌더링**:
  - `journals.isEmpty` → `emptyStateView` 표시
  - `journals.isNotEmpty` → `journalListView` 표시
- **Navigation Bar**:
  - 타이틀: "매매 일지"
  - 우측 버튼: `plus` 아이콘 (매매 일지 작성)

#### 통계 섹션 (List > Section 1)
- **구성 요소**: `TradingJournalStatsView`
- **레이아웃**: `VStack` (2개 행)
  - **상단 행**: `HStack` - 총매매/매수/매도 (3개 카드)
  - **하단 행**: `HStack` - 실현손익/승률 (2개 카드)
- **카드 간격**: 12pt (vertical), 16pt (horizontal)

#### 통계 카드 (StatCardView)
1. **총 매매**:
   - 제목: "총 매매"
   - 값: `totalTradeCount` + "건"
   - 색상: `.blue`

2. **매수**:
   - 제목: "매수"
   - 값: `buyTradeCount` + "건"
   - 색상: `.green`

3. **매도**:
   - 제목: "매도"
   - 값: `sellTradeCount` + "건"
   - 색상: `.red`

4. **실현 손익**:
   - 제목: "실현 손익"
   - 값: `formattedPrice(totalRealizedProfit)`
   - 색상: 양수 → `.green`, 음수 → `.red`
   - 포맷: "+₩500,000원" 또는 "-₩50,000원"

5. **승률**:
   - 제목: "승률"
   - 값: `String(format: "%.1f%%", winRate)`
   - 색상: `.orange`
   - 계산: (수익 건수 / 총 매도 건수) × 100

**통계 카드 스타일:**
- **레이아웃**: `VStack` (제목 + 값)
- **제목**: `.caption`, `.secondary`
- **값**: `.system(size: 16, weight: .bold)`, 카드별 색상
- **배경**: `Color(.secondarySystemBackground)`
- **코너 반경**: 8pt
- **패딩**: vertical 12pt
- **크기**: `frame(maxWidth: .infinity)`

#### 매매 기록 섹션 (List > Section 2)
- **섹션 헤더**: "매매 기록"
- **카드**: `TradingJournalCardView` (ForEach)
- **삭제**: `.onDelete` - `viewModel.deleteJournals(at: offsets)`

#### 일지 카드 (TradingJournalCardView)
**레이아웃:**
```swift
VStack(alignment: .leading, spacing: 8) {
  HStack {
    Text(stockName)         // 좌측: 종목명
    Spacer()
    Text(tradeType)         // 우측: 매매 유형 배지
  }
  HStack {
    Text(date)              // 좌측: 날짜
    Spacer()
    Text(quantity × price)  // 우측: 수량 × 단가
  }
  Text(totalAmount)         // 총액
  Text(reason)              // 매매 이유 (옵션)
}
```

**UI 요소:**

1. **종목명** (상단 좌측):
   - 폰트: `.headline`
   - 색상: `.primary`

2. **매매 유형 배지** (상단 우측):
   - 텍스트: `tradeType.rawValue` ("매수" / "매도")
   - 폰트: `.caption`, `.semibold`
   - 배경: `tradeTypeColor.opacity(0.2)`
   - 텍스트 색상: `tradeTypeColor`
   - 매수: `.green`, 매도: `.red`
   - 패딩: horizontal 8pt, vertical 4pt
   - 코너 반경: 8pt

3. **날짜** (중단 좌측):
   - 포맷: "yyyy.MM.dd" (예: "2024.12.18")
   - 폰트: `.caption`
   - 색상: `.secondary`

4. **수량 × 단가** (중단 우측):
   - 포맷: "10주 × 70,000원"
   - 폰트: `.caption`
   - 색상: `.secondary`

5. **총액** (하단):
   - 포맷: "700,000원"
   - 폰트: `.title3`, `.bold`
   - 색상: `.primary`

6. **매매 이유** (하단, 옵션):
   - 조건: `!reason.isEmpty`
   - 폰트: `.caption`
   - 색상: `.secondary`
   - 라인 제한: 2줄 (`.lineLimit(2)`)

**카드 패딩:**
- vertical: 4pt

#### 인터랙션
- **+ 버튼**: `AddTradingJournalView` 시트 표시
- **스와이프 삭제**: `.onDelete` 제스처 사용
  - 우측에서 좌측 스와이프
  - 삭제 버튼 표시
  - 삭제 시 `viewModel.deleteJournals(at:)` 호출

### 13.3 매매 일지 작성/수정 화면

```
┌─────────────────────────────────────┐
│ ✕                   매매 일지 작성   │  ← Navigation Bar (모달)
├─────────────────────────────────────┤
│                                     │  ← ScrollView 시작
│  매매 유형                           │  ← 레이블
│  ┌───────────┬───────────┐          │
│  │   매수    │   매도    │          │  ← 세그먼트 컨트롤
│  └───────────┴───────────┘          │
│                                     │
│  매매일                              │
│  ┌─────────────────────────────┐   │
│  │ 📅 2024년 12월 18일          │   │  ← DatePicker
│  └─────────────────────────────┘   │
│                                     │
│  종목명                              │
│  ┌─────────────────────────────┐   │
│  │ 삼성전자                      │   │  ← TextField
│  └─────────────────────────────┘   │
│                                     │
│  수량                                │
│  ┌─────────────────────────────┐   │
│  │ 10                           │   │  ← TextField (숫자 패드)
│  └─────────────────────────────┘   │
│                                     │
│  단가                                │
│  ┌─────────────────────────────┐   │
│  │ ₩ 70,000                     │   │  ← TextField (숫자 패드)
│  └─────────────────────────────┘   │
│                                     │
│  총액                                │
│  ┌─────────────────────────────┐   │
│  │ 700,000원                    │   │  ← 읽기 전용 (자동 계산)
│  └─────────────────────────────┘   │
│                                     │
│  매매 이유 (선택)                    │
│  ┌─────────────────────────────┐   │
│  │ 실적 발표 후 주가 상승 예상   │   │  ← TextEditor
│  │                              │   │  (멀티라인, 100pt 높이)
│  └─────────────────────────────┘   │
│                                     │  ← ScrollView 끝
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │  ← safeAreaInset 시작
│  │          저  장              │   │  ← 저장 버튼
│  └─────────────────────────────┘   │  (키보드 표시 시에만 표시)
│  ┌─────────────────────────────┐   │
│  │          완  료              │   │  ← 완료 버튼
│  └─────────────────────────────┘   │  ← safeAreaInset 끝
└─────────────────────────────────────┘
```

**구현 구조:**

#### AddTradingJournalView
- **구조**: `NavigationStack` + `ScrollView` + `safeAreaInset`
- **상태 관리**:
  - `@ObservedObject var viewModel: TradingJournalViewModel`
  - `@Environment(\.dismiss) private var dismiss`
  - `@FocusState private var focusedField: Field?`
- **편집 모드**: `var editingJournal: TradingJournalEntity?` (옵션)
  - `nil` → 작성 모드
  - `non-nil` → 수정 모드

#### Navigation Bar
- **좌측**: `xmark` 버튼 (시트 닫기)
- **타이틀**:
  - 작성 모드: "매매 일지 작성"
  - 수정 모드: "매매 일지 수정"
- **스타일**: `.inline`

#### ScrollView 영역
**VStack(spacing: 24) + padding(.horizontal):**

1. **매매 유형**:
   - 레이블: "매매 유형" (`.subheadline`, `.secondary`)
   - `Picker(selection: $tradeType)`:
     - 스타일: `.segmented`
     - 옵션: `TradeType.allCases` (매수/매도)
     - 기본값: `.buy`

2. **매매일**:
   - 레이블: "매매일" (`.subheadline`, `.secondary`)
   - `DatePicker(selection: $tradeDate, in: ...Date())`:
     - 스타일: `.compact`
     - 제한: 미래 날짜 선택 불가
     - `.labelsHidden()`

3. **종목명**:
   - 레이블: "종목명" (`.subheadline`, `.secondary`)
   - `TextField("예: 삼성전자", text: $stockName)`:
     - 폰트: `.title3`
     - 배경: `Color(.secondarySystemBackground)`
     - 코너 반경: 8pt
     - 패딩: 12pt
     - 포커스: `.focused($focusedField, equals: .stockName)`
     - `.textContentType(.none)`
     - `.autocorrectionDisabled()`

4. **수량**:
   - 레이블: "수량" (`.subheadline`, `.secondary`)
   - `TextField("0", text: $quantityText)`:
     - 키보드: `.numberPad`
     - 폰트: `.title3`
     - 배경: `Color(.secondarySystemBackground)`
     - `.onChange(of: quantityText)` → `formatQuantityInput()`
     - 포맷: 숫자만 허용 (`value.filter { $0.isNumber }`)

5. **단가**:
   - 레이블: "단가" (`.subheadline`, `.secondary`)
   - `TextField("₩ 0", text: $priceText)`:
     - 키보드: `.numberPad`
     - 폰트: `.title3`
     - 배경: `Color(.secondarySystemBackground)`
     - `.onChange(of: priceText)` → `formatPriceInput()`
     - 포맷: 천단위 콤마 (예: "70,000")

6. **총액** (읽기 전용):
   - 레이블: "총액" (`.subheadline`, `.secondary`)
   - `Text(formattedTotalAmount)`:
     - 폰트: `.title2`, `.bold`
     - 색상: 매수 → `.green`, 매도 → `.red`
     - 배경: `Color(.secondarySystemBackground)`
     - 코너 반경: 8pt
     - 패딩: 12pt
     - 정렬: `frame(maxWidth: .infinity, alignment: .leading)`
     - 계산: `Int(quantityText) × Double(priceText)`
     - 포맷: "700,000원"

7. **매매 이유** (선택):
   - 레이블: "매매 이유 (선택)" (`.subheadline`, `.secondary`)
   - `TextEditor(text: $reason)`:
     - 높이: 100pt
     - 패딩: 8pt
     - 배경: `Color(.secondarySystemBackground)`
     - 코너 반경: 8pt
     - `.scrollContentBackground(.hidden)`
     - 포커스: `.focused($focusedField, equals: .reason)`

8. **유효성 검사 에러** (옵션):
   - 조건: `if let error = validationError`
   - `Text(error)`:
     - 폰트: `.caption`
     - 색상: `.red`

#### 빈 영역 터치 처리
- `.contentShape(Rectangle())`
- `.onTapGesture { focusedField = nil }`
- 효과: 키보드 숨김

#### safeAreaInset (하단 버튼 영역)
**VStack(spacing: 12):**

1. **저장 버튼**:
   - 텍스트: "저장"
   - 폰트: `.headline`
   - 색상: `.white`
   - 배경: `Color.accentColor`
   - 높이: 50pt
   - 코너 반경: 12pt
   - 투명도: `isValidInput ? 1.0 : 0.5`
   - 비활성: `!isValidInput`
   - 액션: `saveJournal()`

2. **완료 버튼**:
   - 텍스트: "완료"
   - 폰트: `.headline`
   - 색상: `.primary`
   - 높이: 50pt
   - 배경: 투명
   - 액션: `focusedField = nil` (키보드 숨김)

**버튼 영역 스타일:**
- 상단 구분선: `Rectangle().fill(Color(.separator)).frame(height: 0.5)`
- 배경: `Color(.systemBackground)`
- 패딩: horizontal 16pt, top 16pt, bottom 8pt
- 애니메이션:
  - `offset(y: focusedField != nil ? 0 : 200)`
  - `opacity(focusedField != nil ? 1 : 0)`
  - `.animation(.interactiveSpring(), value: focusedField)`
- 효과: 키보드 표시 시에만 버튼 표시

#### 입력 검증 (isValidInput)
```swift
!stockName.trimmingCharacters(in: .whitespaces).isEmpty &&
Int(quantityText) ?? 0 > 0 &&
Double(priceText.replacingOccurrences(of: ",", with: "")) ?? 0 > 0 &&
tradeDate <= Date()
```

#### 저장 로직 (saveJournal)
1. 입력값 파싱:
   - `quantity`: `Int(quantityText) ?? 0`
   - `price`: `Double(priceText.replacingOccurrences(of: ",", with: "")) ?? 0`

2. 모드 분기:
   - **수정 모드** (`editingJournal != nil`):
     - `viewModel.updateJournal(...)` 호출
   - **작성 모드** (`editingJournal == nil`):
     - `viewModel.addJournal(...)` 호출

3. 데이터 정제:
   - `stockName.trimmingCharacters(in: .whitespaces)`
   - `reason.trimmingCharacters(in: .whitespacesAndNewlines)`

4. 시트 닫기: `dismiss()`

#### 편집 모드 초기화 (.onAppear)
```swift
if let journal = editingJournal {
    tradeType = journal.tradeType
    tradeDate = journal.tradeDate
    stockName = journal.stockName
    quantityText = "\(journal.quantity)"
    priceText = journal.price.formattedWithoutSymbol
    reason = journal.reason
}
```

**입력 필드 세부사항:**

#### 매매 유형
- **타입**: Picker (Segmented Control)
- **옵션**: `TradeType.allCases` (매수/매도)
- **기본값**: `.buy`
- **바인딩**: `$tradeType`

#### 매매일
- **타입**: DatePicker
- **스타일**: `.compact`
- **범위**: `...Date()` (오늘까지)
- **구성요소**: `.date` (날짜만)

#### 종목명
- **타입**: TextField
- **플레이스홀더**: "예: 삼성전자"
- **검증**: 공백 불가 (trim)
- **자동완성**: 비활성
- **자동수정**: 비활성

#### 수량
- **타입**: TextField (숫자 패드)
- **플레이스홀더**: "0"
- **검증**: 1 이상의 정수
- **포맷**: 숫자만 허용

#### 단가
- **타입**: TextField (숫자 패드)
- **플레이스홀더**: "₩ 0"
- **포맷**: 천단위 콤마 자동 적용
- **검증**: 0보다 큰 숫자

#### 총액
- **타입**: Text (읽기 전용)
- **계산**: `수량 × 단가`
- **포맷**: "700,000원"
- **색상**: 매수(녹색) / 매도(빨간색)

#### 매매 이유
- **타입**: TextEditor
- **높이**: 100pt
- **선택 사항**: 비어있어도 저장 가능

### 13.4 빈 상태 (Empty State)

```
┌─────────────────────────────────────┐
│ 매매 일지                          + │  ← Navigation Bar
├─────────────────────────────────────┤
│                                     │
│                                     │
│            📕                       │  ← SF Symbol
│                                     │
│      매매 일지가 없습니다            │  ← 제목
│                                     │
│   + 버튼을 눌러 첫 매매 기록을       │  ← 설명
│        남겨보세요                    │
│                                     │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

**구현 (emptyStateView):**

#### 레이아웃
- **구조**: `VStack(spacing: 20)`
- **중앙 정렬**: 화면 중앙에 배치

#### UI 요소

1. **아이콘**:
   - SF Symbol: "book.closed"
   - 크기: `.system(size: 60)`
   - 색상: `.gray`

2. **제목**:
   - 텍스트: "매매 일지가 없습니다"
   - 폰트: `.title3`
   - 굵기: `.medium`
   - 색상: `.primary`

3. **설명**:
   - 텍스트: "+ 버튼을 눌러 첫 매매 기록을 남겨보세요"
   - 폰트: `.subheadline`
   - 색상: `.secondary`

#### 인터랙션
- **+ 버튼** (Navigation Bar): `AddTradingJournalView` 시트 표시

**참고:**
- CTA 버튼은 구현되지 않음 (Navigation Bar의 + 버튼만 사용)
- 단순하고 직관적인 빈 상태 디자인

### 13.5 색상 및 스타일

#### 매매 유형 색상
- **매수**:
  - 텍스트: `Color.green`
  - 배경: `Color.green.opacity(0.2)`
- **매도**:
  - 텍스트: `Color.red`
  - 배경: `Color.red.opacity(0.2)`

**구현:**
```swift
private var tradeTypeColor: Color {
    journal.tradeType == .buy ? .green : .red
}
```

#### 통계 카드 색상
- **총 매매**: `Color.blue`
- **매수**: `Color.green`
- **매도**: `Color.red`
- **실현 손익**:
  - 양수: `Color.green`
  - 음수: `Color.red`
- **승률**: `Color.orange`

#### 총액 색상 (작성/수정 화면)
- **매수 시**: `Color.green`
- **매도 시**: `Color.red`

#### 카드 스타일

**통계 카드 (StatCardView):**
- **배경**: `Color(.secondarySystemBackground)`
- **코너 반경**: 8pt
- **패딩**: vertical 12pt
- **크기**: `frame(maxWidth: .infinity)`

**일지 카드 (TradingJournalCardView):**
- **패딩**: vertical 4pt
- **배경**: List 기본 스타일 (시스템 제공)
- **구분선**: List 기본 구분선

**매매 유형 배지:**
- **배경**: `tradeTypeColor.opacity(0.2)`
- **패딩**: horizontal 8pt, vertical 4pt
- **코너 반경**: 8pt
- **폰트**: `.caption`, `.semibold`

#### 통계 섹션 간격
- **카드 간 수평 간격**: 16pt
- **카드 간 수직 간격**: 12pt
- **섹션 상하 패딩**: 8pt

### 13.6 애니메이션

#### 리스트 업데이트
- **추가**: List 기본 애니메이션 (Fade + Slide)
- **삭제**: `.onDelete` 기본 애니메이션 (Fade + Slide to trailing)

#### 시트 전환
- **표시**: 하단에서 위로 슬라이드 (기본 sheet 애니메이션)
- **닫기**: 위에서 하단으로 슬라이드 (기본 sheet 애니메이션)

#### 버튼 영역 애니메이션 (작성/수정 화면)
- **타입**: `.interactiveSpring()`
- **트리거**: `focusedField` 변경
- **offset(y)**:
  - 키보드 표시: 0
  - 키보드 숨김: 200
- **opacity**:
  - 키보드 표시: 1
  - 키보드 숨김: 0

**구현:**
```swift
.animation(.interactiveSpring(), value: focusedField)
```

---

### 13.7 데이터 모델 및 ViewModel

#### TradingJournalEntity
```swift
struct TradingJournalEntity: Identifiable {
    let id: UUID
    var tradeType: TradeType
    var tradeDate: Date
    var stockName: String
    var quantity: Int
    var price: Double
    var reason: String
    var createdAt: Date
    var updatedAt: Date

    var totalAmount: Double {
        Double(quantity) * price
    }
}
```

#### TradeType
```swift
enum TradeType: String, Codable, CaseIterable {
    case buy = "매수"
    case sell = "매도"
}
```

#### TradingJournalViewModel
**주요 속성:**
- `@Published private(set) var journals: [TradingJournalEntity]`
- `private let repository: TradingJournalRepositoryProtocol`

**계산 속성:**
1. `totalTradeCount: Int` - 총 매매 건수
2. `buyTradeCount: Int` - 매수 건수
3. `sellTradeCount: Int` - 매도 건수
4. `totalRealizedProfit: Double` - 실현 손익 (매도 건 총액 합계)
5. `winRate: Double` - 승률 (수익 건수 / 총 매도 건수 × 100)

**주요 메서드:**
1. `fetchJournals()` - 전체 일지 조회
2. `addJournal(...)` - 일지 추가
3. `updateJournal(...)` - 일지 수정
4. `deleteJournal(_ journal)` - 일지 삭제
5. `deleteJournals(at offsets)` - 일지 일괄 삭제 (스와이프)
6. `refresh()` - 데이터 새로고침

---

### 13.8 구현 파일 목록

#### Views
1. **TradingJournalListView.swift**:
   - 메인 목록 화면
   - emptyStateView (빈 상태)
   - journalListView (목록 + 통계)

2. **TradingJournalStatsView** (TradingJournalListView.swift 내):
   - 통계 섹션 (5개 카드)
   - 2행 레이아웃 (3개 + 2개)

3. **StatCardView** (TradingJournalListView.swift 내):
   - 개별 통계 카드 컴포넌트
   - 재사용 가능한 카드 UI

4. **TradingJournalCardView** (TradingJournalListView.swift 내):
   - 매매 일지 카드
   - 종목명, 날짜, 수량, 단가, 총액, 이유 표시

5. **AddTradingJournalView.swift**:
   - 작성/수정 화면
   - 입력 폼 + 유효성 검증

#### ViewModels
- **TradingJournalViewModel.swift**: 비즈니스 로직 및 상태 관리

#### Models
- **TradingJournalEntity.swift**: 데이터 모델 및 TradeType enum

#### Repository
- **TradingJournalRepositoryProtocol.swift**: 저장소 인터페이스
- **CoreDataTradingJournalRepository.swift**: Core Data 구현체

#### App
- **ContentView.swift**: TabView (포트폴리오 / 매매 일지)
