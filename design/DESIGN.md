# DESIGN.md

> 이 프로젝트의 디자인 규칙. UI 코드를 작성하기 전에 반드시 읽고, 여기 정의된 토큰과 규칙만 사용한다.
> 임의의 색상값·여백값·radius를 새로 만들지 않는다. 필요하면 이 문서를 먼저 수정한다.
>
> **검증됨** — 이 값들은 운동 플래너 3화면(홈 / 세트 기록 / 설정) 목업으로 실제 확인한 결과다.

---

## 1. 무드

> 장식이 없고 정보 위주지만, 모서리와 여백은 부드럽다.
> **도구처럼 정확하되 딱딱하지 않게.**

| 참고 | 가져오는 것 |
|---|---|
| Linear, Things 3 | 정보 위계, 액센트 절제, 흑백 대비 |
| Toss, Apple 설정 | 둥근 모서리, 그룹 카드, 여백 리듬 |

기준선은 미니멀 쪽이되, radius와 여백에서 부드러움을 준다. 이 균형이 이 앱의 정체성이다.

---

## 2. 컬러

액센트는 **딱 하나**. 나머지는 전부 무채색으로 해결한다.

### Light

| 토큰 | 값 | 용도 |
|---|---|---|
| `bg` | `#FFFFFF` | 화면 배경 |
| `surface` | `#FFFFFF` | 카드 |
| `bgSubtle` | `#F7F7F8` | 카드 내부 채움, 입력 필드, 아이콘 박스 |
| `border` | `#E9E9EC` | 카드 테두리 |
| `borderStrong` | `#D4D4D8` | Secondary 버튼, 토글 OFF |
| `text` | `#18181B` | 본문·제목 |
| `textSecondary` | `#71717A` | 보조 설명, 값, 섹션 라벨 |
| `textTertiary` | `#A1A1AA` | 플레이스홀더, chevron, 비활성 |
| `accent` | `#2563EB` | 주 액션 |
| `accentSoft` | `#EFF4FF` | 활성 입력 필드 배경 |
| `accentPressed` | `#1D4ED8` | 눌림 |
| `success` | `#16A34A` | |
| `danger` | `#DC2626` | 파괴적 액션·에러 |
| `warning` | `#CA8A04` | |

### Dark

| 토큰 | 값 |
|---|---|
| `bg` | `#09090B` |
| `surface` | `#161619` |
| `bgSubtle` | `#202024` |
| `border` | `#26262A` |
| `borderStrong` | `#3F3F46` |
| `text` | `#FAFAFA` |
| `textSecondary` | `#A1A1AA` |
| `textTertiary` | `#71717A` |
| `accent` | `#3B82F6` |
| `accentSoft` | `#17233D` |
| `accentPressed` | `#60A5FA` |
| `success` | `#22C55E` |
| `danger` | `#EF4444` |
| `warning` | `#EAB308` |

**규칙**
- 다크 모드는 처음부터 함께 만든다. 나중에 붙이지 않는다.
- **다크에서 `bg` < `surface` < `bgSubtle` 순으로 밝아진다.** 이 순서가 깨지면 카드 위의 아이콘 박스나 입력 필드가 배경에 묻혀 사라진다. 실제로 한 번 겪은 문제다.
- 순수 검정(`#000`)은 배경에 쓰지 않는다.
- 상태 색(success/danger/warning)은 텍스트·아이콘·테두리에만. 배경을 그 색으로 꽉 채우지 않는다.
- 액센트는 화면당 2곳까지. 그 이상이면 위계가 무너진 것이다.

---

## 3. 타이포그래피

**폰트: Pretendard 하나만.** 숫자(무게·횟수·시간·통계)는 전부 `tabular-nums`.

| 토큰 | size / line-height / weight / spacing | 용도 |
|---|---|---|
| `timer` | 24 / 30 / 600 / -0.4 | 타이머, 대형 숫자 |
| `title` | 22 / 28 / 600 / -0.3 | 통계 값 |
| `heading` | 18 / 24 / 600 / -0.2 | 화면 타이틀, 카드 제목 |
| `subhead` | 16 / 22 / 600 / -0.1 | 리스트 항목 제목, 입력 필드 값 |
| `body` | 15 / 22 / 400 | 본문, 설정 라벨, 값 |
| `button` | 15 / 20 / 600 | 버튼 라벨 |
| `label` | 13 / 18 / 500 | 섹션 라벨 (textSecondary) |
| `caption` | 13 / 18 / 400 | 부제, 타임스탬프 |
| `micro` | 12 / 16 / 500 | 배지, 통계 키, 요일 |
| `tab` | 11 / 14 / 500 | 탭바 라벨 |

**규칙**
- weight는 `400 / 500 / 600` 세 단계만. 700 이상 금지.
- **Large title을 쓰지 않는다.** 화면 타이틀은 `heading`(18px)으로 헤더 안에 둔다.
- 좌측 정렬 기본. 중앙 정렬은 빈 상태와 버튼 라벨에만.
- 섹션 라벨은 **uppercase나 letter-spacing을 주지 않는다.** 딱딱해진다.

---

## 4. 여백

**Spacing** — `2, 4, 6, 8, 10, 12, 14, 16, 20, 24, 28, 32, 40`

| 상황 | 값 |
|---|---|
| 화면 좌우 패딩 | **20** |
| 카드 내부 패딩 | **20** |
| 그룹 행 좌우 패딩 | **16** |
| 그룹/리스트 행 높이 | **60** |
| 섹션 사이 | **32** |
| 섹션 라벨 → 카드 | **10** |
| 관련 요소 사이 | 8 ~ 10 |

여백은 넉넉한 쪽이 맞다. 밀도를 높이고 싶은 유혹이 들면 항목 수를 줄이지, 여백을 줄이지 않는다.

---

## 5. Radius

| 토큰 | 값 | 용도 |
|---|---|---|
| `badge` | `10` | 배지 |
| `input` | `12` | 입력 필드 |
| `btn` | `14` | 버튼 |
| `card` | `18` | 카드, 그룹 |
| `sheet` | `24` | 바텀시트 상단 |
| `full` | `999` | 아바타, 토글, 날짜 원, 진행 바 |

**Border / Shadow**
- 구분은 **border 1px**. 그림자로 구분하지 않는다.
- 그림자는 실제로 떠 있는 것(바텀시트, FAB)에만, `opacity 0.08 / radius 12 / offsetY 4` 이하로.
- 카드에 border와 shadow를 동시에 주지 않는다.

---

## 6. 모션

| 상황 | 값 |
|---|---|
| 상태 변화 (색·투명도) | `150ms` ease-out |
| 위치 이동 | `200ms` ease-out |
| 화면 전환 | 플랫폼 기본값 |
| 바텀시트 | spring — damping `20`, stiffness `250` |

- 튕기는(overshoot) 모션 금지.
- 리스트 항목 stagger 진입 금지.
- 눌림 피드백은 `opacity 0.6` 또는 `bgSubtle` 배경 전환 중 하나로 통일.

---

## 7. 모바일 레이아웃

- **터치 타겟 최소 44×44pt.** 아이콘이 20px여도 히트 영역은 44 확보.
- Safe area는 `react-native-safe-area-context`로만. 상수 하드코딩 금지.
- 헤더: 높이 `48` + safe top. 타이틀은 좌측 정렬 `heading`.
- 탭바: 높이 `49` + safe bottom. 탭 최대 5개, 라벨 항상 표시.
  **아이콘 위에 4px 여백을 추가한다** (시각적으로 2px 내려옴 — 그냥 중앙 정렬하면 위로 붙어 보인다).
- 스크롤 화면 하단에는 탭바 높이만큼 `contentContainerStyle` 패딩.
- 키보드는 `KeyboardAvoidingView` 또는 `react-native-keyboard-controller`로 반드시 처리.

---

## 8. 컴포넌트 규칙

### 그룹 리스트 — 이 앱의 핵심 패턴

설정, 최근 기록, 목록 등 **행이 나열되는 곳은 전부 이 패턴을 쓴다.**

- 관련된 행들을 **카드 하나로 묶는다** (`surface` + border 1px + radius `card` + `overflow: hidden`).
- **카드 내부에는 구분선을 넣지 않는다.** 행 구분은 왼쪽 아이콘과 60px 행 높이가 대신한다.
- 그룹 사이는 `32` 여백 + 섹션 라벨로 구분한다. 이게 구분선보다 훨씬 명확하다.
- 각 행 좌측에 **아이콘 박스**: `32×32`, radius `10`, 배경 `bgSubtle`, 아이콘 17px `textSecondary`.
- 행 구조: `[아이콘] [라벨 (flex:1)] [값 또는 토글] [chevron]`

### Button — 3종만
| 종류 | 스타일 |
|---|---|
| Primary | 배경 `accent`, 텍스트 흰색, 높이 `52`, radius `btn`, weight 600 |
| Secondary | 투명 배경, border 1px `borderStrong`, 텍스트 `text`, weight 500 |
| Ghost | 배경 없음, 텍스트 `accent`, weight 500 |

- 파괴적 액션은 Secondary에 텍스트/보더만 `danger`.
- 화면당 Primary는 1개.
- 로딩 중엔 라벨을 스피너로 교체하되 **너비 유지**.

### Input
- 높이 `44`, radius `input`, 값은 `subhead`.
- 기본: 배경 `bgSubtle`, 테두리 없음.
- **활성**: 배경 `accentSoft` + border 1.5px `accent`. 바깥 글로우 금지.
- 대기/비활성: 배경 `bgSubtle`, 텍스트 `textTertiary`.
- 에러는 필드 아래 `caption` + `danger`. 흔들림 애니메이션 금지.

### Card
- 배경 `surface`, border 1px `border`, radius `card`, 패딩 `20`.
- 카드 안에 카드를 넣지 않는다.

### Progress bar
- 높이 **7px**, radius `full`, 트랙 `bgSubtle`, 채움 `accent`.
- 2px 얇은 선은 이 톤과 안 맞는다. 라운드 끝이 보일 만큼은 두꺼워야 한다.

### Toggle
- `46×28`, radius `full`, 노브 24px 흰색.
- ON `accent`, OFF `borderStrong`.

### Badge
- `micro`, 패딩 `5/10`, radius `badge`, 배경 `bgSubtle`, 텍스트 `textSecondary`. 테두리 없음.

### Empty state
- 아이콘 24px(`textTertiary`) + 한 줄 설명 `body` + 액션 버튼 하나. 중앙 정렬.
- 큰 일러스트 금지.

### Loading
- 리스트는 **스켈레톤**(`bgSubtle` 블록, 펄스 없이 정적). 전체 화면 스피너 금지.

### Icon
- `lucide-react-native` 한 세트만. stroke `1.8`, 크기 `17 / 20 / 22` 세 단계.
- 색을 채우지 않는다(stroke만). 예외: play 아이콘.
- 기본 `textSecondary`, 활성 `accent`.

---

## 9. 하지 말 것

- ❌ 그라데이션 배경 — 배경은 단색만
- ❌ 이모지를 아이콘 대신 사용
- ❌ 보라·핑크 계열 액센트
- ❌ 액센트 색 2개 이상
- ❌ 그림자 중첩, 카드에 border+shadow 동시 적용
- ❌ **그룹 카드 내부에 구분선** — 카드로 묶는 것 자체가 구분이다
- ❌ radius를 `card`(18)·`sheet`(24)보다 크게
- ❌ 폰트 2종 이상 / weight 700 이상
- ❌ 섹션 라벨에 uppercase·letter-spacing
- ❌ Large title 헤더
- ❌ 유리 효과(blur/glassmorphism)
- ❌ 튕기는 애니메이션, 리스트 stagger 진입
- ❌ 토큰에 없는 색상값·여백값 인라인 하드코딩

---

## 10. 기술 스택 (고정)

```
Expo (SDK 최신) + React Native + TypeScript
expo-router                     라우팅
NativeWind                      스타일
React Native Reusables          컴포넌트 베이스 (shadcn/ui의 RN 포트)
lucide-react-native             아이콘
react-native-reanimated         애니메이션
@gorhom/bottom-sheet            시트
react-native-safe-area-context  safe area
expo-font (Pretendard)          폰트
```

- 스타일은 컴포넌트 파일에 흩뿌리지 말고 토큰을 참조한다.
- 새 UI 라이브러리를 추가하기 전에 먼저 물어본다.

---

## 11. 토큰 코드

`src/theme/tokens.ts` — 그대로 시작점으로 쓴다.

```ts
export const palette = {
  light: {
    bg: '#FFFFFF',
    surface: '#FFFFFF',
    bgSubtle: '#F7F7F8',
    border: '#E9E9EC',
    borderStrong: '#D4D4D8',
    text: '#18181B',
    textSecondary: '#71717A',
    textTertiary: '#A1A1AA',
    accent: '#2563EB',
    accentSoft: '#EFF4FF',
    accentPressed: '#1D4ED8',
    success: '#16A34A',
    danger: '#DC2626',
    warning: '#CA8A04',
  },
  dark: {
    bg: '#09090B',
    surface: '#161619',
    bgSubtle: '#202024',   // surface보다 밝게 유지할 것
    border: '#26262A',
    borderStrong: '#3F3F46',
    text: '#FAFAFA',
    textSecondary: '#A1A1AA',
    textTertiary: '#71717A',
    accent: '#3B82F6',
    accentSoft: '#17233D',
    accentPressed: '#60A5FA',
    success: '#22C55E',
    danger: '#EF4444',
    warning: '#EAB308',
  },
} as const

export const space = {
  0.5: 2, 1: 4, 1.5: 6, 2: 8, 2.5: 10, 3: 12,
  3.5: 14, 4: 16, 5: 20, 6: 24, 7: 28, 8: 32, 10: 40,
} as const

export const radius = {
  badge: 10, input: 12, btn: 14, card: 18, sheet: 24, full: 999,
} as const

export const type = {
  timer:   { fontSize: 24, lineHeight: 30, fontWeight: '600', letterSpacing: -0.4 },
  title:   { fontSize: 22, lineHeight: 28, fontWeight: '600', letterSpacing: -0.3 },
  heading: { fontSize: 18, lineHeight: 24, fontWeight: '600', letterSpacing: -0.2 },
  subhead: { fontSize: 16, lineHeight: 22, fontWeight: '600', letterSpacing: -0.1 },
  body:    { fontSize: 15, lineHeight: 22, fontWeight: '400' },
  button:  { fontSize: 15, lineHeight: 20, fontWeight: '600' },
  label:   { fontSize: 13, lineHeight: 18, fontWeight: '500' },
  caption: { fontSize: 13, lineHeight: 18, fontWeight: '400' },
  micro:   { fontSize: 12, lineHeight: 16, fontWeight: '500' },
  tab:     { fontSize: 11, lineHeight: 14, fontWeight: '500' },
} as const

export const layout = {
  screenPadding: 20,
  cardPadding: 20,
  rowPadding: 16,
  rowHeight: 60,
  sectionGap: 32,
  minTouchTarget: 44,
  headerHeight: 48,
  tabBarHeight: 49,
  tabIconOffset: 4,     // 탭 아이콘 위 여백
  buttonHeight: 52,
  inputHeight: 44,
  iconBox: 32,
  progressHeight: 7,
} as const

export const motion = {
  fast: 150,
  normal: 200,
  spring: { damping: 20, stiffness: 250 },
} as const
```

---

## 12. 작업 전 체크리스트

- [ ] 다크 모드에서도 확인했는가 (특히 `bgSubtle` 요소가 카드 위에서 보이는지)
- [ ] 모든 터치 타겟이 44pt 이상인가
- [ ] 색상·여백·radius를 토큰에서만 가져왔는가
- [ ] 액센트 색이 화면에 2곳 이하인가
- [ ] Primary 버튼이 화면에 1개인가
- [ ] 나열되는 행을 그룹 카드로 묶었는가, 내부에 구분선을 넣지 않았는가
- [ ] 로딩·빈 상태·에러 상태가 모두 있는가
- [ ] Safe area와 키보드를 처리했는가
- [ ] 9번 "하지 말 것"에 걸리는 게 없는가
