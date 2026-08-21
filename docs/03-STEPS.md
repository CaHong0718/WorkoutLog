# 단계별 진행 계획

> **세션을 clear한 뒤 이어서 작업할 때 이 문서부터 읽는다.**
> 순서: `03-STEPS.md`(현재 위치 확인) → `00-ARCHITECTURE.md`(규약) → 필요 시 `01-DOMAIN-MODEL.md` / `02-ROUTINE-SEED.md`
>
> 각 STEP을 끝낼 때마다 아래 체크박스를 갱신하고 커밋한다.

## 진행 현황

| STEP | 내용 | 상태 |
|---|---|---|
| 0 | 프로젝트 골격 · 설계 문서 | ✅ |
| 1 | Core 레이어 | ✅ |
| 2 | Domain 레이어 | ✅ |
| 3 | Data 레이어 (Drift + 시드) | ✅ |
| 4 | 홈 / 오늘의 루틴 화면 | ✅ |
| 5 | 운동 세션 화면 (기록 + 휴식 타이머) | ✅ |
| 6 | 루틴 편집 화면 | ✅ |
| 7 | 히스토리 / 통계 화면 | ✅ |
| 8 | Android 빌드 검증 · 마무리 | ✅ |
| 9 | 실사용 피드백 반영 (키보드·기록 삭제·백그라운드 타이머·구분선) | ✅ |
| 10 | 복수 루틴 · 루틴 가져오기/내보내기 | ✅ |
| 11 | 하단 탭 좌우 스와이프 · 탭 전환 시 화면 갱신 | ✅ |
| 12 | `design/DESIGN.md` 디자인 시스템 적용 | ✅ |
| 13 | 드래그 프록시 모양 정리 · iOS 빌드 준비 | ✅ |
| 14 | 운동 기록 백업 · 복원 · 공유 | 🚧 |

---

## STEP 0 — 프로젝트 골격 · 설계 문서

- [x] `git init` (원격 없음, 로컬 로그만)
- [x] `flutter create --org com.yeoboya --platforms=android --empty .`
- [x] pubspec 의존성 추가
- [x] `docs/00-ARCHITECTURE.md` `01-DOMAIN-MODEL.md` `02-ROUTINE-SEED.md` `03-STEPS.md`
- [x] `analysis_options.yaml` 린트 강화 + `build.yaml` (drift 옵션)

**의존성 목록**

```
dependencies:
  flutter_bloc      # MVI
  equatable         # State 동등성
  get_it            # DI 컨테이너
  injectable        # DI 코드 생성
  drift             # SQLite ORM
  drift_flutter     # Flutter 통합 (DB 경로/네이티브 로더)
  go_router         # 라우팅
  intl              # 날짜/숫자 포맷
  fl_chart          # 통계 그래프

dev_dependencies:
  build_runner
  injectable_generator
  drift_dev
  flutter_lints
```

**완료 조건**: `flutter analyze` 통과, 문서 4종 존재.

---

## STEP 1 — Core 레이어

- [x] `core/result/result.dart` — `Result<T>` sealed (`Ok` / `Err`)
- [x] `core/error/failure.dart` — `Failure` sealed (`DatabaseFailure`, `NotFoundFailure`, `ValidationFailure`, `UnknownFailure`)
- [x] `core/mvi/` — `MviIntent`, `MviState`, `MviEffect`, `MviBloc<I,S,E>` (Effect 브로드캐스트 스트림 포함)
- [x] `core/mvi/effect_listener.dart` — Effect 구독 위젯
- [x] `core/theme/app_palette.dart` — `02-ROUTINE-SEED.md` §10 토큰 전체를 `ThemeExtension`으로 이식 (light/dark)
- [x] `core/theme/app_typography.dart` — tabular figures 적용 텍스트 스타일
- [x] `core/theme/app_theme.dart` — `ThemeData` light/dark
- [x] `core/router/app_router.dart` — go_router 라우트 뼈대 (home / session / routine / history)
- [x] `core/di/injection.dart` — `configureDependencies()`
- [x] `core/constants/app_strings.dart` — 한국어 문자열
- [x] `core/extensions/` — `DateTime` (주 시작일, 날짜 절삭), `Duration` (mm:ss 포맷)
- [x] `presentation/common/body_part_ui.dart` — `BodyPart` → 색상/라벨 (STEP 2에서 BodyPart 정의 후)

**완료 조건**: 빈 홈 화면이 테마 적용된 상태로 뜬다.

---

## STEP 2 — Domain 레이어

`01-DOMAIN-MODEL.md`의 §2·§3·§5를 그대로 코드로 옮긴다.

- [x] `domain/entity/` — `enums.dart`(BodyPart·BlockType·RepMode·SessionStatus), `exercise.dart`,
      `routine.dart`, `routine_day.dart`, `routine_block.dart`, `routine_item.dart`,
      `workout_session.dart`, `set_log.dart`, `exercise_progress_point.dart`,
      `progression_suggestion.dart`, `date_range.dart`
- [x] Repository 인터페이스 4종 (`RoutineRepository`, `ExerciseRepository`, `WorkoutRepository`, `HistoryRepository`)
- [x] UseCase — 아래 목록

UseCase는 영역별로 한 파일에 모았다(`domain/usecase/*_usecases.dart`). 클래스는 여전히 1개 = 1 UseCase.

```
routine_usecases.dart
  GetActiveRoutine, WatchActiveRoutine, GetRoutineDays, GetDayDetail, GetNextDay,
  UpsertDay, DeleteDay, ReorderDays, UpsertBlock, DeleteBlock, ReorderBlocks,
  UpsertItem, DeleteItem, ReorderItems
exercise_usecases.dart
  GetAllExercises, WatchExercises, GetExercisesByBodyPart, SearchExercises,
  GetExercisesByIds, UpsertExercise, DeleteExercise
workout_usecases.dart
  GetInProgressSession, StartSession, GetSession, WatchSession, LogSet, UpdateSet,
  DeleteSet, CompleteSession, AbortSession, GetLastLogsForExercise, SuggestProgression
history_usecases.dart
  GetSessions, GetSessionDetail, GetSessionsOn, GetWeeklyVolume,
  GetExerciseProgress, GetWorkoutDates, GetTotalSessionCount
```

`SuggestProgression`은 이중 프로그레션 규칙(모든 세트가 반복 상단 도달 → +2.5%, 1.25kg 단위 올림)을
구현한 유일한 계산형 UseCase다.

`DateRange`는 Flutter의 `DateTimeRange` 대신 도메인이 직접 소유한다(계층 순수성 유지).

**완료 조건**: Domain 폴더 어디에도 `package:flutter` / `package:drift` import가 없다. → 확인 완료

---

## STEP 3 — Data 레이어 (Drift + 시드)

- [x] `data/database/tables/` — 7개 테이블 (`01-DOMAIN-MODEL.md` §6)
- [x] `data/database/app_database.dart` — schemaVersion 1, FK cascade 활성화(`PRAGMA foreign_keys = ON`)
- [x] `data/database/daos/` — `RoutineDao`, `ExerciseDao`, `WorkoutDao`, `HistoryDao`
- [x] `data/database/seed/routine_seed.dart` — `02-ROUTINE-SEED.md` §2~§5, §7, §8 전체 삽입
- [x] 시드는 최초 실행 시 1회만 (`routines` 테이블이 비어 있을 때)
- [x] `data/mapper/` — Row ↔ Entity
- [x] `data/repository/` — RepositoryImpl 4종, 예외 → `Failure` 변환
- [x] `dart run build_runner build`

**완료 조건**: 시드 삽입 후 주간 볼륨 집계가 `02-ROUTINE-SEED.md` §6 표(어깨19·가슴17·등16·하체12·팔6 = 70)와 일치. 이 검증은 테스트로 남긴다.

---

## STEP 4 — 홈 / 오늘의 루틴

- [x] `HomeBloc` — Intent: `Load`, `SelectDay`, `StartSession`, `ResumeSession`
- [x] 오늘의 DAY 카드 (코드/제목/총 세트/예상 시간, 부위 색상 적용)
- [x] 블록별 종목 미리보기 (슈퍼세트 묶음 시각화)
- [x] DAY 선택 시트 (순번 자동 + 수동 변경)
- [x] 진행 중 세션이 있으면 "이어서 하기" 배너
- [x] 이번 주 볼륨 요약 (부위별 막대, HTML의 vchart 스타일)
- [x] 하단 네비게이션 (홈 / 기록 / 루틴)

**완료 조건**: 앱 실행 → DAY A 표시 → 세션 시작 버튼 동작.

---

## STEP 5 — 운동 세션 화면 (핵심)

- [x] `SessionBloc` — Intent: `Load`, `CompleteSet`, `EditSet`, `SkipSet`, `SkipBlock`, `SwitchExercise`, `StartRest`, `SkipRest`, `AddRestTime`, `Tick`, `FinishSession`, `AbortSession`
- [x] 블록 단위 진행 UI (현재 블록 강조, 완료 블록 접기)
- [x] 슈퍼세트 라운드 진행 (A→B→휴식 사이클)
- [x] 세트 입력: 무게(± 2.5kg 스텝, 직접 입력 가능) · 반복 · RIR
- [x] 지난 기록 프리필 (`GetLastLogsForExercise`)
- [x] 세트 완료 → 휴식 타이머 자동 시작 (블록 `restSeconds` 기준)
- [x] 타이머: 원형 진행 표시, +15s / 건너뛰기, 종료 시 햅틱
- [x] 총 세션 경과 시간 (상단 고정), 40분 기준 진행 바
- [x] 대체 종목 스위치 (롱프레스)
- [x] 세션 완료 시 요약 + 증량 제안 (이중 프로그레션 규칙)
- [x] 앱 종료 후 재진입 시 진행 중 세션 복원

**완료 조건**: 세션 하나를 처음부터 끝까지 기록하고 DB에 저장된다.

---

## STEP 6 — 루틴 편집

- [x] `RoutineBloc` / `DayEditBloc` / `ExerciseLibraryBloc` (화면마다 1개)
- [x] DAY 목록 · 추가 · 삭제 · 순서 변경 (드래그)
- [x] 블록 추가/삭제/순서 변경, 타입(straight/superset) 전환, 휴식·목표시간 편집
- [x] 종목 추가/삭제/순서 변경 (드래그)
- [x] 세트 수 · 반복 구간 · RepMode · RIR · 메모 편집
- [x] 종목 마스터 관리 (검색 · 커스텀 추가 · 부위 지정)
- [x] 대체 종목 지정 (종목 선택 바텀시트 재사용)
- [x] 편집 결과가 과거 기록에 영향 없음을 확인 (SetLog 스냅샷)

DB에 쓰는 Intent 핸들러는 전부 `transformer: sequential()`. 블록 순서 변경만 별도 시트로 뺐다 —
블록 카드 안에 이미 종목용 `ReorderableListView`가 있어 드래그 대상을 중첩하면 둘 다 불안정해진다.

**완료 조건**: DAY A에 종목 추가 → 세션 시작 시 반영, 과거 기록은 원본 유지.

---

## STEP 7 — 히스토리 / 통계

- [x] `HistoryBloc`, `StatsBloc` (+ `SessionDetailBloc` — 상세는 별도 라우트라 화면당 1블록 규칙을 따랐다)
- [x] 월 달력 — 운동한 날 마킹(그날 최다 부위 색 점), 월 이동
- [x] 날짜 탭 → 그날 세션 목록 → 세션 상세 (블록별 세트 목록, 총 볼륨, 소요 시간, 메모)
- [x] 종목별 무게 추이 그래프 (`fl_chart`, 최고 중량 + 추정 1RM 2계열)
- [x] 주간 부위별 볼륨 차트 + 목표(70세트) 대비, 주 이동
- [x] 연속 운동 주 수 / 총 세션 수 요약

화면은 `달력 / 볼륨 / 추이` 3분할이다. `TabBar`가 아니라 자체 `SegmentedTabs`를 쓴다 —
`TabBar`를 쓰려면 `app_theme.dart`에 전역 테마 항목을 넣어야 하는데, 이 화면 하나 때문에
전역 테마를 늘리지 않는다. 본문은 `IndexedStack`이라 세그먼트를 오가도 재조회가 없다.

추이 종목 후보는 종목 마스터가 아니라 **최근 180일 기록의 SetLog 스냅샷**에서 뽑는다.
한 번도 하지 않은 종목을 고르게 하면 항상 빈 그래프가 나오기 때문이다.

**완료 조건**: 기록한 세션이 달력·상세·그래프에 모두 나타난다. → `test/history_test.dart`

---

## STEP 8 — Android 빌드 검증 · 마무리

- [x] `flutter analyze` 무경고
- [x] `flutter test` 통과 — 63개 (시드 볼륨 검증 포함)
- [x] `flutter build apk --debug` 성공
- [x] 실기기 실행 확인 (Galaxy S21 · Android 15 / API 35)
- [x] 앱 이름 `Workout Log` · applicationId `com.shyang.workout_log`
- [x] `README.md` 작성
- [x] 앱 아이콘 — `tools/generate_icon.py`로 생성, flutter_launcher_icons로 배포

---

## STEP 9 — 실사용 피드백 반영

- [x] **지표 사이 세로 구분선 제거** — `16 Sets | 45 Min | 7 Sets`의 구분선이 텍스트 사이에
      정렬되지 않아 전부 제거했다. 홈·루틴·기록의 동일 컴포넌트를 모두 정리.
- [x] **빈 공간 탭 시 키보드 닫기** — `core/widgets/dismiss_keyboard.dart`를
      `MaterialApp.router`의 `builder`에 물려 전 화면(다이얼로그·바텀시트 포함)에 적용.
      `HitTestBehavior.translucent`라 버튼·스크롤 제스처는 그대로 동작한다.
- [x] **운동 기록 삭제** — 세션 상세 앱바에서 삭제(확인 다이얼로그). `set_logs`는 FK cascade로
      함께 지워지고, 돌아오면 달력·주간 볼륨이 자동 갱신된다.
- [x] **휴식 타이머 백그라운드 동작 + 알림** — 아래 별도 설명.

### 휴식 타이머 설계 변경 (중요)

문제: 화면을 끄거나 앱을 백그라운드로 보내면 `Timer.periodic`이 멈춰 카운트다운이 어긋났다.

해결은 두 축이다.

1. **표시는 벽시계 기준.** `RestState`가 남은 초를 세는 대신 **종료 시각(`endsAt`)** 을 들고 있고,
   매 tick마다 `endsAt - now`로 다시 계산한다. 앱이 몇 분간 얼어 있었어도 복귀 즉시 정확하다.
   (`RestState.tick(now)` / `extend(by)`)
2. **알림은 시스템이 낸다.** `RestNotifier`가 휴식 시작 시점에 **종료 시각으로 알림을 예약**한다.
   Dart 타이머가 아니라 `AlarmManager` 기반이라 화면이 꺼져 있어도, Doze 상태여도 울린다.
   `exactAllowWhileIdle` → 거부되면 `inexactAllowWhileIdle`로 자동 폴백.

`RestNotifier`의 모든 플랫폼 호출은 try/catch로 감싸 실패해도 운동 화면이 멈추지 않는다
(테스트 호스트에서는 자동으로 no-op이 되며, 그 동작 자체를 테스트가 통과시킨다).

권한은 앱 시작이 아니라 **세션 진입 시점**에 요청한다 — 랙 앞에 선 순간이 사용자가
"왜 알림이 필요한지" 이해하는 시점이기 때문.

Android 설정: `POST_NOTIFICATIONS`·`SCHEDULE_EXACT_ALARM`·`VIBRATE`·`RECEIVE_BOOT_COMPLETED` 권한,
`isCoreLibraryDesugaringEnabled = true` + `desugar_jdk_libs`(`zonedSchedule` 요구사항).

---

## STEP 10 — 복수 루틴 · 루틴 가져오기/내보내기

앱을 "무분할 40분 전용"에서 **루틴을 갈아 끼울 수 있는 그릇**으로 바꿨다.
무분할 40분은 여전히 기본으로 깔리는 시드일 뿐, 고정이 아니다.

포맷 명세는 [`04-ROUTINE-EXCHANGE.md`](04-ROUTINE-EXCHANGE.md)가 유일한 기준이다.

**DB 스키마는 바꾸지 않았다.** `routines` 테이블에 이미 여러 행이 들어갈 수 있고
`isActive`·`getNextDay(routineId)`도 루틴별로 분리돼 있었다. `schemaVersion`은 1 그대로라
마이그레이션이 없고, 기존 설치본의 운동 기록이 그대로 남는다.

### STEP 10-1 — 교환 포맷 코덱

- [x] `domain/entity/routine_package.dart` — 저장 전 루틴 그래프(`RoutinePackage` /
      `RoutineDayDraft` / `RoutineBlockDraft` / `RoutineItemDraft` / `ExerciseDraft`).
      대체 종목을 **이름**으로 들고 있다는 점이 기존 엔티티와 다르다(id가 아직 없으므로).
- [x] `domain/repository/routine_exchange.dart` — `decode` / `encode` / `fileNameFor` 포트
- [x] `data/exchange/routine_codec.dart` — 구현. `dart:convert` + domain만 import한다.
      **flutter·drift를 import하지 않는다** (검증 CLI가 이 파일을 그대로 쓰기 때문)
- [x] 오류는 **전부 모아** 경로와 함께 보고한다:
      `routine.days[1].blocks[0].items[2].repMax: repMin(12)보다 작습니다 (8)`.
      첫 오류에서 멈추면 손으로 쓴 파일을 한 번에 하나씩 고치게 된다
- [x] 알 수 없는 enum 값은 기본값으로 떨어뜨리지 않고 **오류**로 보고 (`legs` → `leg` 오타 사고 방지)
- [x] 경고는 가져오기를 막지 않는다 — 슈퍼세트 세트/라운드 불일치 보정, 미해결 대체 종목

### STEP 10-2 — 루틴 CRUD · 가져오기/내보내기 (domain + data)

- [x] `RoutineRepository`에 `getRoutines` / `watchRoutines` / `watchRoutine` /
      `createRoutine` / `updateRoutine` / `deleteRoutine` / `setActiveRoutine` /
      `importRoutine` / `exportRoutine` / `duplicateRoutine` 추가
- [x] `setActiveRoutine`은 한 트랜잭션에서 전부 `false` → 대상만 `true`
- [x] `importRoutine`은 **단일 트랜잭션**. 종목 대조는 이름 정확 일치(`04` §7.1)
- [x] `deleteRoutine` 방어 3종 — 마지막 루틴 거부 / 진행 중 세션 있는 루틴 거부 /
      활성 루틴을 지우면 남은 것을 자동 활성화
- [x] `duplicateRoutine` = export → import (` 복사본`, 겹치면 ` 복사본 2`)
- [x] UseCase 추가, `dart run build_runner build`

**감시 스트림을 `async*`로 쓰지 않는다 (중요).**
`_watchRoutineGraph`는 원래 `async*` + `await for (updates)`였는데, 제너레이터가 `await for`에서
대기 중일 때 **구독 취소가 영영 끝나지 않는다.** 그 스트림을 듣는 Bloc의 `close()`가 멎고
테스트가 30초 타임아웃으로 죽었다. 지금은 `StreamController` + `asyncMap`이다 —
취소가 즉시 끝나고, `asyncMap`이 로드를 직렬화해 편집이 몰려도 순서가 뒤집히지 않는다.

### STEP 10-3 — 루틴 목록 · 선택 UI

- [x] `RoutineListBloc` + `routine_list_page.dart`, 라우트 `/routines`
- [x] 루틴 카드: 이름 · DAY 수 · 주간 세트 · 부위 볼륨 레일 · `사용 중` 배지
- [x] 카드 액션: 활성화 / 정보 편집 / 복제 / 내보내기 / 삭제
- [x] `RoutinePage(routineId)` — null이면 활성 루틴(루틴 탭), id면 그 루틴.
      **비활성 루틴도 편집된다** — 쓰던 루틴을 유지한 채 새 루틴을 짜는 흐름
- [x] 앱바 제목이 루틴 이름이고, 루틴 탭에는 전환 버튼이 붙는다
- [x] 홈 앱바 제목도 활성 루틴 이름 + 탭하면 루틴 목록

**홈은 활성 루틴 스트림을 구독한다.** 홈은 셸 안에 살아 있어 다시 만들어지지 않는다
(STEP 11). 다른 화면에서 루틴을 전환하거나 DAY를 고쳐도 오늘 카드가 낡은 채로 남기 때문에,
`HomeBloc`이 `WatchActiveRoutine().skip(1)`을 듣고 `LoadHome`을 다시 던진다
(`skip(1)`은 페이지가 이미 보낸 최초 로드와 중복되는 리플레이를 버린다).

### STEP 10-4 — 파일 가져오기 · 내보내기

- [x] `flutter_file_dialog` + `share_plus` 추가.
      **`file_picker`는 쓰지 않는다** — `share_plus`와 `win32` 버전이 충돌해 `file_picker`가
      3.0.4(2020년)로 강등된다. `flutter_file_dialog`는 Android/iOS 전용이라 이 프로젝트에 맞고
      충돌이 없다
- [x] `core/platform/routine_file_io.dart` — 선택·읽기·공유. 모든 플랫폼 호출을 try/catch로
      감싸 실패해도 "아무 일도 안 일어남"으로 떨어진다(`rest_notifier.dart`와 같은 규칙).
      4MB 상한을 둬 잘못 고른 큰 파일을 통째로 읽지 않는다
- [x] 파일 선택 시 확장자 필터를 걸지 않는다 — `.json`을 `text/plain`으로 내보내는 앱이 있어
      필터를 걸면 파일이 아예 안 보인다. 잘못 고르면 코덱이 읽을 수 있는 오류를 낸다
- [x] 가져오기는 **미리보기 → 확인** 2단계. 루틴명·DAY·총 세트·부위 볼륨·경고를 먼저 보여준다
- [x] 내보내기: `루틴이름_yyyyMMdd.json` → 공유 시트 (share_plus가 임시 파일을 대신 쓴다)

### STEP 10-5 — 다른 앱에서 공유받기

- [x] `receive_sharing_intent` + `core/platform/shared_routine_receiver.dart`
- [x] `AndroidManifest.xml`에 `application/json` SEND / VIEW 인텐트 필터.
      **`*/*`로 열지 않는다** — 사진·링크 공유 시트마다 Workout Log가 끼어든다.
      `text/plain`으로 오는 `.json`은 앱 안의 `가져오기`로 넣으면 된다
- [x] 콜드 스타트(`getInitialMedia`)와 실행 중(`getMediaStream`) 양쪽 수신 → 같은 미리보기로 연결
- [x] 수신 후 `reset()`으로 인텐트를 소비 표시 (앱에 다시 들어올 때 같은 파일이 또 열리지 않게)
- [x] 플러그인 실패가 앱 기동을 막지 않는다. 첫 프레임 뒤에 `start()` — 라우터가 붙은 다음이라야
      공유가 앱을 띄운 경우에도 push할 대상이 있다

**안드로이드 빌드 설정 2가지가 이 STEP에서 바뀌었다.**

| 설정 | 이유 |
|---|---|
| `app/build.gradle.kts` `compileSdk = 37` | `receive_sharing_intent` 1.9.0이 API 37을 요구한다. 1.8.0으로 내리면 JVM 타깃이 Java 11 / Kotlin 21로 어긋나 컴파일이 깨진다. `targetSdk`·`minSdk`는 그대로라 런타임 동작은 변하지 않는다 |
| `gradle.properties` `kotlin.incremental=false` | share_plus·flutter_file_dialog·receive_sharing_intent가 각자 Kotlin Gradle Plugin을 적용해 증분 캐시가 충돌한다(`Storage for [...] is already registered`). 빼면 세 플러그인 모두 빌드가 깨지는 것을 확인했다 |

`android.suppressUnsupportedCompileSdk=37`은 AGP 9.0.1이 내는 "권장 최대 36" 경고를 끈다.

### STEP 10-6 — 검증 CLI · 테스트 · 문서

- [x] `tools/validate_routine.dart` — `dart run tools/validate_routine.dart <파일.json>`.
      앱과 **같은 코덱**으로 검증하고 DAY·총 세트·부위별 볼륨을 찍는다. 폰에 넣기 전 단계
- [x] `test/routine_exchange_test.dart` (23개) — 시드 루틴 export→import 왕복 동일성,
      왕복 후에도 주간 70세트, 종목 재사용/신규 생성, 오류 경로 보고, 경고 처리,
      활성 전환, 삭제 방어 3종, 복제
- [x] `test/routine_list_test.dart` (12개) — Bloc 관점의 목록·가져오기·내보내기.
      플랫폼 다이얼로그만 가짜로 두고 나머지는 인메모리 SQLite 실물
- [x] `README.md`에 루틴 가져오기/내보내기 사용법 추가

### STEP 10-7 — 변환을 저장소에 상주시키기

"루틴 문서를 파일로 뽑아줘"는 앞으로 반복해서 요청될 작업이다. 세션이 바뀌어도 매번 같은
품질로 나오도록 **환경을 저장소에 박아뒀다.** 어느 컴퓨터에서 클론하든 그대로 따라온다.

- [x] `.claude/skills/routine-file/SKILL.md` — 변환 스킬. 절차(스키마 읽기 → 종목 이름 확인 →
      작성 → CLI 검증 → 인계), 원문에 없는 값을 채우는 기준, 자주 틀리는 것,
      거부당한 파일 진단법
- [x] `CLAUDE.md`에 진입점 한 단락 — 스킬 목록을 못 봐도 걸리도록 이중으로 건다
- [x] `routines/` — 루틴 파일 보관함 + `README.md`
- [x] `routines/무분할-40분.json` — 시드 루틴 내보내기. **작성 예시 겸 복구 지점**.
      슈퍼세트·시간 슬롯·대체 종목·`isCuttable`이 전부 들어 있어 형식을 그대로 흉내 낼 수 있다
- [x] `test/routine_export_file_test.dart` — 위 파일이 시드와 어긋나면 실패한다.
      예시가 낡으면 그걸 보고 쓴 루틴이 전부 틀어지므로 손으로 관리하지 않는다
      ```bash
      UPDATE_ROUTINE_EXPORT=1 flutter test test/routine_export_file_test.dart
      ```

종목 이름은 `routines/무분할-40분.json`(실사용 27개)과, 빠짐없는 목록이 필요하면
`lib/data/database/seed/routine_seed.dart`를 `_ExerciseSpec\(\s*'([^']+)'`로 멀티라인 Grep한다
(29개). **이름이 한 글자만 달라도 새 종목이 생겨 무게 추이가 갈라진다.**

**검증 결과**: `flutter analyze` 무경고 · `flutter test` 103개 통과 ·
`flutter build apk --debug` 성공.

---

## STEP 11 — 하단 탭 좌우 스와이프 · 탭 전환 시 화면 갱신

증상: 홈에서 운동을 끝내고 `기록` 탭으로 넘어가도 캘린더가 그 세션을 **아직 진행 중**으로
그렸다. 셸이 세 브랜치를 살려 두는데 각 페이지는 처음 만들어질 때 한 번만 읽기 때문이다.

- [x] `StatefulShellRoute.indexedStack` → `StatefulShellRoute` + `navigatorContainerBuilder`.
      `presentation/common/branch_pager.dart`가 브랜치를 `PageView`에 담아 좌우로 밀 수 있게 한다
- [x] 세 브랜치 모두 `preload: true` — 없으면 처음 그 탭으로 미는 동안 빈 페이지가 끌려 들어온다
- [x] `presentation/common/branch_reveal.dart` — 브랜치가 화면에 올라올 때마다 신호를 보내는
      `BranchVisibility`(InheritedWidget) + 그걸 듣는 `OnBranchReveal`
- [x] 홈 `LoadHome`, 기록 `LoadHistory`+`LoadStats`, 루틴 `LoadRoutine`을 각각 다시 던진다
- [x] `test/tab_navigation_test.dart` — DB 없이 셸만 세워 스와이프·갱신 횟수를 검증 (4개)

**첫 방문에는 신호를 보내지 않는다.** 그 순간 페이지가 만들어지면서 자기 초기 로드를 돌리므로
이미 최신이다. 신호는 *돌아왔을 때*를 위한 것이다.

**건너뛴 탭은 갱신하지 않는다.** 탭을 눌러 A→C로 가면 애니메이션이 B를 스쳐 지나가고
`PageView.onPageChanged`가 B를 보고한다. `_settling` 플래그로 그 보고를 무시한다 —
무시하지 않으면 브랜치가 B로 바뀌면서 애니메이션이 중간에 끊긴다.

**`late` 초기화에 걸렸던 곳.** `late int _index = widget.navigationShell.currentIndex`로 두면
첫 읽기가 `didUpdateWidget` 안에서 일어나 *이미 옮겨간* 인덱스를 집는다. 그래서 변화를 영영
못 알아챈다. `initState`에서 값을 박아 둔다.

기록 화면 안쪽의 `캘린더/볼륨/추이` 세그먼트는 그대로 `IndexedStack`이다. 같은 화면의 세 얼굴이라
오갈 때 재조회가 없어야 한다.

---

## STEP 12 — `design/DESIGN.md` 디자인 시스템 적용

기존 토큰은 `무분할-40분-루틴.html`에서 가져온 것이었다. 그 자리를 `design/DESIGN.md`가
대신한다. **토큰 값만 바꾸고 이름은 그대로 뒀다** — 팔레트·타이포 이름이 350곳에서 쓰이고
있어, 이름까지 갈아엎으면 롤백이 어려워진다. 대응표는 `app_palette.dart` 상단에 있다.

- [x] `app_palette.dart` — 청록 액센트 → 파랑 하나. zinc 계열 무채색.
      `lineStrong`(Secondary 버튼)·`danger`(에러) 추가, `warn`은 주의 전용으로 분리
- [x] `app_typography.dart` — weight 상한 600, Large title 제거, 섹션 라벨의
      uppercase·letter-spacing 제거
- [x] `app_metrics.dart` (신규) — `AppRadius` `AppLayout` `AppMotion`
- [x] `app_theme.dart` — 버튼 3종·테두리 없는 입력(포커스 시 액센트 틴트)·배지·탭바 49
- [x] `common_widgets.dart` — 카드 radius 18 / 패딩 20, `LoadingView`를 스켈레톤으로,
      `SkeletonBlock` 추가
- [x] 화면 좌우 패딩 16 → 20, 섹션 간격 32, 라벨→카드 10
- [x] `test/design_system_test.dart` — 라이트/다크 양쪽에서 공용 표면이 예외 없이 그려지는지 (6개)

**라이트 모드에서 페이지와 카드가 둘 다 흰색이다.** 가이드가 그렇게 정했다(`bg`=`surface`=
`#FFFFFF`). 카드는 1px 테두리로만 구분된다. 다크는 `bg` < `surface` < `bgSubtle` 순으로
밝아져야 하며, 이 순서가 깨지면 카드 위의 입력 필드가 배경에 묻힌다.

**부위 색은 액센트가 아니다.** 가이드의 "액센트는 하나" 규칙은 액션 색 이야기고, 가슴·등·하체
색은 정보다. Tailwind 600/500 계열로 다시 맞추되 액센트 파랑과 겹치지 않게 등을 시안으로 옮겼다.

**휴식 타이머가 작아졌다.** 타입 스케일의 최대가 24라 링을 150 → 120으로 줄여 비율을 맞췄다.
운동 중 멀리서 읽기 어렵다면 여기가 먼저 되돌릴 곳이다.

**아직 적용하지 않은 것**: 가이드 8장의 "그룹 리스트" 패턴(행을 카드 하나로 묶고 내부 구분선을
없애며 32×32 아이콘 박스를 두는 것). 루틴 DAY 목록·기록 세션 목록을 다시 짜야 해서
기능 회귀 위험이 크다. 별도 STEP으로 다룬다.

---

## STEP 13 — 드래그 프록시 모양 정리 · iOS 빌드 준비

**드래그 중인 항목이 직사각형으로 보였다.** `ReorderableListView`의 기본 `proxyDecorator`가
`Material(elevation: 6)`으로 감싸는데, 이게 canvas 색 + 각진 모서리다. radius 18짜리 DAY 카드를
집어 올리면 모서리가 잘리고 그림자가 카드 아래 여백까지 덮었다.

- [x] `lib/presentation/common/drag_proxy.dart` — `roundedDragProxy()`.
      항목이 제 표면·테두리를 계속 그리게 두고 **둥근 그림자만** 뒤에 깐다.
      `bottomGap`으로 항목 간 여백만큼 아래를 잘라내 카드 끝에서 그림자가 멈춘다
- [x] 적용 3곳 — 루틴 DAY 목록(카드, radius 18) · 블록 안 종목 행(채움, radius 12) ·
      블록 순서 시트(채움, radius 12)
- [x] iOS 플랫폼 추가 — `docs/05-IOS.md`

그림자는 `design/DESIGN.md`가 "실제로 떠 있는 것"에 허용한 값(opacity .08 / blur 12 / offsetY 4)
그대로다. 드래그하는 동안만 fade in 하므로 정지 상태의 카드에는 그림자가 없다 —
"카드에 border와 shadow 동시 금지" 규칙은 그대로 지켜진다.

---

## STEP 14 — 운동 기록 백업 · 복원 · 공유

앱을 지우거나 폰을 바꾸면 운동 기록이 사라진다. 실제로 2026-08-18에 서명 키 문제로 하루치를
잃었고(`06-ANDROID-SIGNING.md`), 그때 기기 자동 백업도 꺼져 있어 복구하지 못했다.
**사용자가 스스로 파일을 뽑아 둘 수 있어야 한다.**

포맷 명세는 [`07-BACKUP.md`](07-BACKUP.md)가 유일한 기준이다.

STEP 10이 깔아 둔 길(코덱 → 파일 선택 → 미리보기 → 공유 시트)을 기록까지 늘리는 일이다.
새 길을 내지 않는다. **DB 스키마는 바꾸지 않는다** — `schemaVersion`은 1 그대로다.

정한 것 세 가지:

| 갈림길 | 정한 것 | 이유 |
|---|---|---|
| 포맷 | JSON 전체 백업 | 두 기기 기록을 합칠 수 있고, 스키마가 바뀌어도 살아남고, 사람이 열어본다. `07` §1 |
| 복원 | 합치기(기본) + 덮어쓰기 | 재설치 직후(빈 DB)와 두 기기 합치기를 한 경로로 덮는다 |
| 진입점 | 기록 탭 앱바 → `/backup` | 백업 대상이 "운동 기록"이니 기록 탭에 둔다 |

### STEP 14-1 — 도메인

- [ ] `domain/entity/backup_package.dart` — `BackupPackage` / `BackupRoutineEntry` /
      `SessionDraft` / `SetLogDraft`. 루틴 교환과 같은 규칙: **id가 없고 이름으로 참조한다**
- [ ] `domain/entity/backup_package.dart` — `BackupParseResult` / `BackupImportReport` /
      `BackupSummary` / `BackupRestoreMode`(`merge` | `replace`)
- [ ] `domain/repository/backup_exchange.dart` — `decode` / `encode` / `fileNameFor` 포트
- [ ] `domain/repository/backup_repository.dart` — `exportBackup` / `importBackup` / `summarize`
- [ ] `domain/usecase/backup_usecases.dart` — `ParseBackupFile` `ExportBackup` `ImportBackup`
      `GetBackupSummary`

**`domain/`에 `package:flutter`·`package:drift`를 import하지 않는다.**

### STEP 14-2 — 코덱

- [ ] `RoutineCodec` 리팩터 — 루틴 **본문**(`routine` 객체)만 읽고 쓰는 경로를 노출한다.
      백업 파일의 `routines[i]`가 그 객체와 글자 하나까지 같아야 하므로, 스키마를 두 벌로
      적지 않고 같은 코드를 부른다. `RoutineExchange`에 `encodeRoutineBody` /
      `decodeRoutineBody(json, path:)` 추가
- [ ] `data/exchange/backup_codec.dart` — `07-BACKUP.md` §2~§6 구현.
      **`dart:convert` + domain 말고는 import하지 않는다**(검증 CLI가 이 클래스를 그대로 쓴다)
- [ ] 오류는 전부 모아 경로와 함께 보고(`07` §11). 루틴 쪽 경로는 `routine.` → `routines[i].`로 바꿔 붙인다
- [ ] `inProgress` 세션은 오류로 거부한다
- [ ] null 필드는 쓰지 않는다 — 세트가 수천 개라 파일 크기가 눈에 띄게 갈린다

### STEP 14-3 — 데이터

- [ ] `data/repository/backup_repository_impl.dart`
- [ ] `exportBackup` — 종목 전체 + 루틴 전체(기존 `_exportRoutine` 재사용) + `inProgress`가 아닌 세션 전체
- [ ] `importBackup(package, mode)` — **단일 트랜잭션**. 신원 규칙은 `07` §7.1
      (종목·루틴은 이름, 세션은 `startedAt`)
- [ ] 합치기 — 이름이 같은 루틴은 건너뛰고, 활성 루틴은 건드리지 않는다(`07` §7.2)
- [ ] 덮어쓰기 — 진행 중 세션이 있으면 거부, 자식 표부터 비우고, 백업의 `isActive`를 따른다(`07` §7.3)
- [ ] DAO 보강 — `sessionsByStartedAt` / `allSessions` / `allExercises` / 표 비우기
- [ ] `dart run build_runner build`

### STEP 14-4 — 플랫폼

- [ ] `RoutineFileIo` → `JsonFileIo` 리네임(`PickedRoutineFile` → `PickedJsonFile`).
      하는 일에 루틴 전용 로직이 하나도 없다. 백업이 "루틴 파일 IO"를 부르면 읽는 사람이 헷갈린다
- [ ] `maxBytes`를 호출자가 정하게 한다 — 루틴 4MB, 백업 16MB(`07` §9)
- [ ] `shareJsonFile`로 일반화

### STEP 14-5 — UI

- [ ] `presentation/backup/` — `BackupBloc` + intent/state/effect,
      `page/backup_page.dart`, `widget/backup_preview_sheet.dart`
- [ ] 라우트 `/backup`, 기록 탭 앱바에 진입 아이콘
- [ ] 요약 카드 — 기록 횟수 · 세트 수 · 루틴 수 · 첫 기록 날짜
- [ ] Primary는 **내보내기** 하나(`DESIGN.md`: 화면당 Primary 1개). 복원은 Secondary
- [ ] 복원은 **미리보기 → 모드 선택 → 확인** 3단계. 덮어쓰기는 `danger` 색 확인 다이얼로그에
      "기록 N개가 사라집니다"를 숫자로 적는다
- [ ] DB에 쓰는 Intent 핸들러에 `transformer: sequential()`
- [ ] 문자열은 전부 `app_strings.dart`

### STEP 14-6 — 공유로 받기

- [ ] `SharedRoutineReceiver`가 받은 JSON의 `format`을 보고 루틴이면 `/routines`,
      백업이면 `/backup`으로 보낸다. 지금은 전부 루틴으로 보내 백업 파일이 거부당한다
- [ ] 인텐트 필터는 이미 `application/json`이라 `AndroidManifest.xml`은 손대지 않는다

### STEP 14-7 — 검증 CLI · 테스트 · 문서

- [ ] `tools/validate_backup.dart` — `dart run tools/validate_backup.dart <파일.json>`
- [ ] `test/backup_test.dart` — 인메모리 SQLite 위에서 실제로 돈다(목 없음)
      - export → 새 DB에 덮어쓰기 복원 → 세션·세트·루틴·종목이 왕복 동일
      - 같은 백업을 두 번 합치기 → 세션 수 그대로(`startedAt` 중복 차단)
      - 합치기에서 이름이 같은 루틴을 새로 만들지 않는다
      - `inProgress` 세션은 내보내지 않고, 들어오면 거부한다
      - 진행 중 세션이 있으면 덮어쓰기를 거부한다
      - 종목 이름 대조로 복원 뒤에도 무게 추이가 이어진다
      - 루틴 파일을 백업으로 열면 `format` 오류, 경로가 붙은 오류 목록
- [ ] `test/backup_bloc_test.dart` — 플랫폼 다이얼로그만 가짜, 나머지는 실물
- [ ] `README.md`에 사용법 추가
- [ ] `CLAUDE.md` 문서 표에 `07-BACKUP.md` 추가

**완료 조건**: `flutter analyze` 무경고 · `flutter test` 통과(기존 103개 + 신규) ·
`flutter build apk --debug` 성공 · 실기기에서 내보내기 → 앱 삭제 → 재설치 → 복원 왕복.

---

## 이후 후보 (요청 시 착수)

우선순위 순.

- [ ] **스플래시 화면** — `flutter_native_splash` 사용
- [ ] **과거 기록 수정** — 삭제는 STEP 9에서 됐고, 세트별 무게·반복 수정은 아직.
      `UpdateSet`/`DeleteSet` UseCase는 이미 있다.
- [ ] **4주 로테이션 알림** — 원문 설계의 "4주마다 종목 교체" 규칙을 앱이 알려주기
- [ ] **그룹 리스트 패턴** — `design/DESIGN.md` 8장. 행을 카드로 묶고 내부 구분선을 없앤다.
      STEP 12에서 미룬 것 (루틴 DAY 목록 · 기록 세션 목록 · 종목 라이브러리)

---

## 새 세션 시작 시 체크리스트

1. `docs/03-STEPS.md` 진행 현황 표에서 다음 STEP 확인
2. `docs/00-ARCHITECTURE.md` 규약 확인
3. `git log --oneline -10` 으로 최근 작업 확인
4. 해당 STEP 착수 → 완료 시 체크박스 갱신 → 커밋
