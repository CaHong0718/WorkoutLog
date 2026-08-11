# 이 저장소에서 작업할 때의 규칙

> 이 파일은 세션 시작 시 자동으로 읽힌다. 어느 컴퓨터에서 클론하든 동일한 규약이 적용된다.
> 규칙이 바뀌면 이 파일을 갱신하고 커밋한다.

## 커밋

- **커밋 메시지에 Claude / AI 관련 표기를 절대 넣지 않는다.**
  `Co-Authored-By: Claude ...` 트레일러, PR 본문의 "Generated with Claude Code" 문구 모두 금지.
  이 규칙은 다른 어떤 기본 커밋 규칙보다 우선한다.
- Conventional Commits + 한국어 본문.
  ```
  feat(session): 휴식 타이머 백그라운드 동작

  - 종료 시각 기준으로 카운트다운을 다시 계산
  - AlarmManager로 알림 예약
  ```
  타입: `feat` `fix` `refactor` `chore` `docs` `test` `style`
  스코프: `core` `domain` `data` `home` `session` `routine` `history` `db` `theme`
- **작업 하나가 끝나면 검증을 통과시킨 뒤 커밋하고 `origin main`에 push한다.**
  요청을 기다리지 않는다. 브랜치를 따로 파지 않고 `main`에 바로 쌓는다.

### 자동 커밋 훅

`.claude/settings.json`의 `Stop` 훅이 매 턴이 끝날 때
`.claude/hooks/auto-commit.sh`를 돌린다. 남아 있는 변경을 전부
`chore: 작업 자동 저장 <시각>`으로 커밋하고 push한다.

훅은 안전장치일 뿐이다. **작업이 끝났으면 위 규약대로 직접 커밋해서**
훅이 쓸어 담을 게 없게 만든다. 그래야 히스토리에 의미 있는 메시지가 남는다.

훅이 건드리지 않는 경우: `main`이 아닌 브랜치, 변경 없음. 둘 다 조용히 넘어간다.
push가 실패하면 커밋만 남기고 알려준다 — 자격증명 프롬프트는 뜨지 않는다
(`GIT_TERMINAL_PROMPT=0`).

작업이 아직 안 끝났는데 턴이 끝나면(질문·중간 보고) 훅이 미완성 상태를
커밋한다. 그게 싫으면 `.claude/settings.json`에서 `hooks.Stop`을 지운다.

## 언어

- 사용자에게 보이는 모든 텍스트(설명·질문·보고)는 **한국어**.
- 코드·식별자·코드 주석은 **영어**.
- 앱 UI 문자열은 **한국어**, `lib/core/constants/app_strings.dart`에 모은다.

## 작업 방식

- 큰 작업은 착수 전에 **단계별 계획 문서를 먼저 만든다.** 진행 현황 표 + STEP별 체크리스트 +
  "새 세션 시작 시 체크리스트" 형태. 세션을 clear해도 문서만 읽으면 위치와 규약이 복원되어야 한다.
- STEP 단위로 체크박스를 갱신하고 커밋한다.
- 독립적인 STEP은 서브에이전트에 위임해도 되지만 **순차로** 돌린다.
  `build_runner`가 동시에 돌면 `.dart_tool` 경합으로 실패한다.
  위임할 때는 참조 문서·기존 구현 패턴 파일·검증 기준(analyze 무경고, 기존 테스트 수)을 명시한다.

## 먼저 읽을 문서

| 문서 | 언제 |
|---|---|
| [`docs/03-STEPS.md`](docs/03-STEPS.md) | **항상 여기부터.** 진행 현황과 다음 할 일 |
| [`design/DESIGN.md`](design/DESIGN.md) | **UI를 그리기 전에.** 색·타이포·여백·radius·컴포넌트 규칙 |
| [`docs/00-ARCHITECTURE.md`](docs/00-ARCHITECTURE.md) | 코드를 쓰기 전. 계층 규약·폴더 구조·MVI 계약·명명 규칙 |
| [`docs/01-DOMAIN-MODEL.md`](docs/01-DOMAIN-MODEL.md) | 엔티티·Repository·Drift 매핑을 다룰 때 |
| [`docs/02-ROUTINE-SEED.md`](docs/02-ROUTINE-SEED.md) | 시드 루틴·주간 볼륨 목표·디자인 토큰을 다룰 때 |
| [`docs/04-ROUTINE-EXCHANGE.md`](docs/04-ROUTINE-EXCHANGE.md) | 루틴 `.json` 가져오기/내보내기 포맷을 다룰 때. **HTML→JSON 변환 시 이 스키마가 유일한 기준** |

## 루틴을 파일로 뽑아 달라고 하면

사용자가 운동 루틴 문서(HTML·표·메모 무엇이든)를 주면서 "루틴 파일로 뽑아줘",
"이거 앱에 넣게 해줘", "루틴 추가하고 싶어" 라고 하면 **`routine-file` 스킬을 쓴다.**
`.claude/skills/routine-file/SKILL.md`에 절차·자주 틀리는 것·검증 방법이 다 있다.

요약: `docs/04` 스키마대로 `routines/<이름>.json`을 쓰고 →
`dart run tools/validate_routine.dart <파일>`로 검증 → 경로와 볼륨 요약을 보고한다.
**앱에 HTML 파서를 넣지 않는다.** 자유 형식을 읽는 일은 대화가, 스키마는 앱이 맡는 경계다.

## 디자인 토큰

`design/DESIGN.md`가 UI의 유일한 기준이다. 색·크기·여백을 위젯에 직접 쓰지 않는다.

| 가져올 것 | 어디서 |
|---|---|
| 색 | `context.palette` — `lib/core/theme/app_palette.dart` |
| 글자 | `context.type` — `lib/core/theme/app_typography.dart` |
| 여백·radius·모션 | `AppLayout` `AppRadius` `AppMotion` — `lib/core/theme/app_metrics.dart` |

**DESIGN.md의 10장(기술 스택)은 이 앱에 해당하지 않는다.** Expo/React Native 기준으로 쓰여
있는데 이 앱은 Flutter다. 1~9장과 11장의 토큰 값만 가져온다.

팔레트 필드 이름은 가이드보다 먼저 생겨서 서로 다르다. `app_palette.dart` 상단 주석에
대응표가 있다(`plane`=bg, `ink2`=textSecondary, `line`=border …).

자주 걸리는 규칙: **weight는 600까지**, 섹션 라벨에 uppercase·letter-spacing 금지,
카드에 border와 shadow 동시 금지, 화면당 Primary 버튼 1개, 액센트는 하나뿐이다.

## 검증 (커밋 전 필수)

```bash
dart run build_runner build   # --delete-conflicting-outputs 플래그는 이 버전에서 제거됐다. 붙이지 말 것
flutter analyze               # 경고 0개를 유지한다
flutter test                  # 기존 테스트를 깨뜨리지 않는다
```

- 테스트는 목(mock)을 쓰지 않고 인메모리 SQLite 위에서 Bloc → UseCase → Repository → Drift
  전 구간을 실제로 돌린다. 새 기능도 같은 방식으로 검증한다.
- 시드를 고치면 `docs/02-ROUTINE-SEED.md`도 함께 갱신하고 `test/routine_seed_test.dart`를 돌린다.
  주간 볼륨이 어깨 19 · 가슴 17 · 등 16 · 하체 12 · 팔 6 = **70세트**와 일치해야 한다.

## 코드 규약 요약

전문은 `docs/00-ARCHITECTURE.md`. 자주 틀리는 것만:

- 의존 방향은 항상 안쪽(domain)으로. `lib/domain/`에 `package:flutter`나 `package:drift`를 import하지 않는다.
- 로딩·에러는 별도 State 클래스가 아니라 **단일 State의 필드**로 표현한다.
- 네비게이션·스낵바·햅틱은 State가 아니라 **Effect**로 처리한다.
- **DB에 쓰는 Intent 핸들러에는 `transformer: sequential()`을 붙인다.**
  bloc의 기본 트랜스포머는 동시 실행이라, 버튼을 연타하면 같은 작업이 중복 실행된다.
  실제로 "세트 완료" 연타로 세트가 중복 기록되는 버그가 있었다.
- `SetLog`는 종목명·부위·블록 라벨을 스냅샷으로 들고 있다. 루틴을 편집해도 과거 기록이 변하면 안 된다.

## 플랫폼

Android만 대상으로 한다. 앱 이름 `Workout Log`, applicationId `com.shyang.workout_log`.

applicationId를 바꾸면 안드로이드가 별개 앱으로 취급해 **기존 설치본의 운동 기록이 전부 끊긴다.**
앞으로는 바꾸지 않는다.

Dart 패키지명은 `workout_log`(`package:workout_log/...`), Drift DB 파일명도 `workout_log.sqlite`다.

**DB 파일명은 바꾸지 않는다.** 바꾸면 앱이 빈 DB를 새로 만들고 기존 운동 기록에 영영 닿지 못한다.
저장소 폴더명만 아직 `health_app`인데, 이건 로컬 경로일 뿐 빌드 산출물과 무관하다.

`무분할 40분`은 앱 이름이 아니라 **시드 루틴의 이름**이다. DB에 들어 있고 사용자가 바꿀 수 있으며,
루틴은 여러 개를 두고 갈아 끼운다(STEP 10). 앱은 루틴을 담는 그릇이지 특정 루틴 전용이 아니다.

### 건드리면 빌드가 깨지는 안드로이드 설정

둘 다 이유가 있어 들어간 것이다. 정리한다고 지우지 말 것.

| 설정 | 이유 |
|---|---|
| `app/build.gradle.kts`의 `compileSdk = 37` (`flutter.compileSdkVersion` 아님) | `receive_sharing_intent` 1.9.0이 API 37을 요구한다. 1.8.0으로 내리면 JVM 타깃이 Java 11 / Kotlin 21로 어긋나 컴파일이 깨진다 |
| `gradle.properties`의 `kotlin.incremental=false` | share_plus·flutter_file_dialog·receive_sharing_intent가 각자 Kotlin Gradle Plugin을 적용해 증분 캐시가 충돌한다(`Storage for [...] is already registered`). 빼면 세 플러그인 모두 빌드가 깨진다 |

`file_picker`는 쓰지 않는다 — `share_plus`와 `win32` 버전이 충돌해 2020년 버전으로 강등된다.
파일 선택은 `flutter_file_dialog`다.

## 아이콘

`tools/generate_icon.py`가 `assets/icon/`의 원본 PNG를 그린다. 소스는 이 스크립트뿐이니
아이콘을 바꾸려면 스크립트를 고치고 아래를 순서대로 돌린다.

```bash
python tools/generate_icon.py     # Pillow 필요
dart run flutter_launcher_icons   # android/app/src/main/res/ 아래를 재생성
```

`android/.../res/mipmap-*`·`drawable-*`의 파일은 생성물이다. 직접 편집하지 않는다.
