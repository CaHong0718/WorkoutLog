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
| 5 | 운동 세션 화면 (기록 + 휴식 타이머) | ⬜ |
| 6 | 루틴 편집 화면 | ⬜ |
| 7 | 히스토리 / 통계 화면 | ⬜ |
| 8 | Android 빌드 검증 · 마무리 | ⬜ |

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

- [ ] `SessionBloc` — Intent: `Load`, `CompleteSet`, `EditSet`, `SkipSet`, `SkipBlock`, `SwitchExercise`, `StartRest`, `SkipRest`, `AddRestTime`, `Tick`, `FinishSession`, `AbortSession`
- [ ] 블록 단위 진행 UI (현재 블록 강조, 완료 블록 접기)
- [ ] 슈퍼세트 라운드 진행 (A→B→휴식 사이클)
- [ ] 세트 입력: 무게(0.5kg 스텝) · 반복 · RIR
- [ ] 지난 기록 프리필 (`GetLastLogsForExercise`)
- [ ] 세트 완료 → 휴식 타이머 자동 시작 (블록 `restSeconds` 기준)
- [ ] 타이머: 원형 진행 표시, +15s / 건너뛰기, 종료 시 햅틱
- [ ] 총 세션 경과 시간 (상단 고정), 40분 기준 진행 바
- [ ] 대체 종목 스위치 (롱프레스)
- [ ] 세션 완료 시 요약 + 증량 제안 (이중 프로그레션 규칙)
- [ ] 앱 종료 후 재진입 시 진행 중 세션 복원

**완료 조건**: 세션 하나를 처음부터 끝까지 기록하고 DB에 저장된다.

---

## STEP 6 — 루틴 편집

- [ ] `RoutineEditBloc`
- [ ] DAY 목록 · 추가 · 삭제 · 순서 변경
- [ ] 블록 추가/삭제/순서 변경, 타입(straight/superset) 전환, 휴식·목표시간 편집
- [ ] 종목 추가/삭제/순서 변경 (드래그)
- [ ] 세트 수 · 반복 구간 · RepMode · RIR · 메모 편집
- [ ] 종목 마스터 관리 (검색 · 커스텀 추가 · 부위 지정)
- [ ] 대체 종목 지정
- [ ] 편집 결과가 과거 기록에 영향 없음을 확인 (SetLog 스냅샷)

**완료 조건**: DAY A에 종목 추가 → 세션 시작 시 반영, 과거 기록은 원본 유지.

---

## STEP 7 — 히스토리 / 통계

- [ ] `HistoryBloc`, `StatsBloc`
- [ ] 월 달력 — 운동한 날 마킹(부위 색 점)
- [ ] 날짜 탭 → 세션 상세 (블록별 세트 목록, 총 볼륨, 소요 시간)
- [ ] 종목별 무게 추이 그래프 (`fl_chart`, 추정 1RM 라인)
- [ ] 주간 부위별 볼륨 차트 + 목표(70세트) 대비
- [ ] 연속 운동 주 수 / 총 세션 수 요약

**완료 조건**: 기록한 세션이 달력·상세·그래프에 모두 나타난다.

---

## STEP 8 — Android 빌드 검증 · 마무리

- [ ] `flutter analyze` 무경고
- [ ] `flutter test` 통과 (시드 볼륨 검증 포함)
- [ ] `flutter build apk --debug` 성공
- [ ] 에뮬레이터/실기기 실행 확인
- [ ] 앱 이름 · 아이콘 · 패키지명 확정
- [ ] `README.md` 작성 (빌드/실행 방법)

---

## 새 세션 시작 시 체크리스트

1. `docs/03-STEPS.md` 진행 현황 표에서 다음 STEP 확인
2. `docs/00-ARCHITECTURE.md` 규약 확인
3. `git log --oneline -10` 으로 최근 작업 확인
4. 해당 STEP 착수 → 완료 시 체크박스 갱신 → 커밋
