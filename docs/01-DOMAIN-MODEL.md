# 도메인 모델

## 1. 개념 계층

```
Routine (프로그램)          "무분할 40분"
 └── RoutineDay (×4)        DAY A / B / C / D  — 요일이 아니라 순번
      └── RoutineBlock      B1 / B2 / B3 / B4 / 복근
           └── RoutineItem  블록 안의 개별 종목 슬롯
                └── Exercise (참조)  종목 마스터

WorkoutSession (하루 운동 1회)
 └── SetLog                 실제 수행한 세트 1개
```

**핵심 설계 판단**

- `RoutineDay`는 요일에 묶이지 않는다. 순번(`order`)만 갖고 A→B→C→D→A… 로 순환한다.
  (원문 운영 규칙: "요일에 종목을 묶는 순간 결석 한 번에 균형이 깨진다")
- `SetLog`는 `RoutineItem`을 참조하지만 **종목명·부위를 스냅샷으로 복사해 저장**한다.
  루틴을 나중에 편집해도 과거 기록이 변형되지 않아야 하기 때문.
- 슈퍼세트는 `RoutineBlock.type == superset`으로 표현하고, 블록 안 `RoutineItem` 여러 개가 한 라운드를 이룬다.

---

## 2. Enum

### BodyPart (부위)

| 값 | 한국어 | 색상 토큰 |
|---|---|---|
| `back` | 등 | `--back` |
| `chest` | 가슴 | `--chest` |
| `shoulder` | 어깨 | `--shoulder` |
| `legs` | 하체 | `--legs` |
| `arms` | 팔 | `--arms` |
| `abs` | 복근 | `--abs` |

### BlockType

| 값 | 의미 |
|---|---|
| `straight` | 일반 블록. 종목 1개를 세트 수만큼 반복 |
| `superset` | 슈퍼세트. 블록 안 종목들을 한 라운드로 묶어 `rounds`회 반복 |

### SessionStatus

| 값 | 의미 |
|---|---|
| `inProgress` | 진행 중 (앱 재시작 시 이어서 진행 가능) |
| `completed` | 정상 완료 |
| `aborted` | 중단 |

### RepMode (세트 목표 방식)

| 값 | 의미 | 예 |
|---|---|---|
| `range` | 반복 구간 | 8–10 |
| `amrap` | 가능한 만큼 | 풀업 4 × AMRAP |
| `duration` | 시간 기반 | 복근 5분 |

---

## 3. Entity 명세

### Exercise — 종목 마스터

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | `int` | PK |
| `name` | `String` | "인클라인 벤치프레스 (스미스머신)" |
| `bodyPart` | `BodyPart` | 주 부위 |
| `subTarget` | `String?` | "측면", "상부", "사두" 등 세부 타깃 |
| `equipment` | `String?` | "스미스머신", "케이블", "덤벨" |
| `isCustom` | `bool` | 사용자가 직접 추가했는지 |
| `createdAt` | `DateTime` | |

### Routine — 프로그램

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | `int` | PK |
| `name` | `String` | "무분할 40분" |
| `description` | `String?` | |
| `sessionMinutes` | `int` | 40 |
| `isActive` | `bool` | 현재 사용 중인 루틴 (동시에 1개만 true) |
| `createdAt` / `updatedAt` | `DateTime` | |

### RoutineDay — DAY A/B/C/D

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | `int` | PK |
| `routineId` | `int` | FK |
| `order` | `int` | 0-based 순번. 순환 기준 |
| `code` | `String` | "A" |
| `title` | `String` | "등 + 이두" |
| `subtitle` | `String?` | "당기기 데이" |
| `description` | `String?` | 설계 의도 설명 |
| `primaryBodyPart` | `BodyPart` | 그날의 메인 부위 (색상/태그용) |
| `blocks` | `List<RoutineBlock>` | |

### RoutineBlock — 블록

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | `int` | PK |
| `dayId` | `int` | FK |
| `order` | `int` | 0-based |
| `label` | `String` | "B1", "B2", "B3", "B4", "복근" |
| `name` | `String?` | "메인 — 오늘의 약점", "이두 마감" |
| `type` | `BlockType` | |
| `rounds` | `int` | superset일 때 라운드 수. straight면 1 |
| `restSeconds` | `int` | 세트/라운드 간 휴식 |
| `targetMinutes` | `int?` | 목표 소요 시간 (13, 9, 11, 7 …) |
| `isCuttable` | `bool` | 시간 부족 시 잘라도 되는 블록인지. B1은 `false` |
| `items` | `List<RoutineItem>` | |

### RoutineItem — 블록 내 종목 슬롯

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | `int` | PK |
| `blockId` | `int` | FK |
| `order` | `int` | 0-based |
| `exerciseId` | `int` | FK → Exercise |
| `sets` | `int` | 세트 수 (superset이면 라운드 수와 동일하게 둠) |
| `repMode` | `RepMode` | |
| `repMin` / `repMax` | `int?` | `range`일 때 |
| `durationSeconds` | `int?` | `duration`일 때 (복근 300) |
| `restSecondsOverride` | `int?` | 블록 기본 휴식과 다를 때만 |
| `targetRir` | `int?` | 목표 RIR |
| `note` | `String?` | 수행 팁 (HTML의 `hint`) |
| `alternativeExerciseIds` | `List<int>` | 기구 없을 때 대체 종목 |

### WorkoutSession — 하루 운동 1회

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | `int` | PK |
| `routineId` | `int` | FK |
| `dayId` | `int?` | FK. 루틴 삭제 시 null 허용 |
| `dayCode` | `String` | "A" (스냅샷) |
| `dayTitle` | `String` | "등 + 이두" (스냅샷) |
| `date` | `DateTime` | 날짜(시간 절삭). 조회 키 |
| `startedAt` | `DateTime` | |
| `endedAt` | `DateTime?` | |
| `status` | `SessionStatus` | |
| `memo` | `String?` | |
| `setLogs` | `List<SetLog>` | |

파생값 `totalDuration` = `endedAt - startedAt`, `totalSets` = 완료된 SetLog 수.

### SetLog — 수행한 세트 1개

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | `int` | PK |
| `sessionId` | `int` | FK |
| `routineItemId` | `int?` | FK. 루틴 편집돼도 기록 유지 위해 nullable |
| `exerciseId` | `int` | FK |
| `exerciseName` | `String` | **스냅샷** |
| `bodyPart` | `BodyPart` | **스냅샷** (주간 볼륨 집계용) |
| `blockLabel` | `String` | "B1" (스냅샷) |
| `itemOrder` | `int` | 세션 내 종목 순서 |
| `setIndex` | `int` | 1-based 세트 번호 |
| `weight` | `double?` | kg. 맨몸이면 null |
| `reps` | `int?` | |
| `durationSeconds` | `int?` | 시간 기반 종목 |
| `rir` | `int?` | |
| `restSeconds` | `int?` | **실제로 쉰 시간** (타이머 측정값) |
| `isCompleted` | `bool` | 건너뛴 세트 구분 |
| `completedAt` | `DateTime` | |

---

## 4. 순번(DAY 로테이션) 계산 규칙

```
다음 DAY = 마지막으로 completed 된 세션의 dayOrder + 1  (mod dayCount)
completed 세션이 하나도 없으면 → order == 0 (DAY A)
```

요일은 계산에 관여하지 않는다. 사용자가 홈 화면에서 다른 DAY를 직접 선택하는 것도 허용한다.

---

## 5. Repository 인터페이스

### RoutineRepository

```dart
Future<Result<Routine>>            getActiveRoutine();
Stream<Routine>                    watchActiveRoutine();
Future<Result<List<RoutineDay>>>   getDays(int routineId);
Future<Result<RoutineDay>>         getDayDetail(int dayId);
Future<Result<RoutineDay>>         getNextDay();          // 순번 계산
Future<Result<int>>                upsertDay(RoutineDay day);
Future<Result<void>>               deleteDay(int dayId);
Future<Result<int>>                upsertBlock(RoutineBlock block);
Future<Result<void>>               deleteBlock(int blockId);
Future<Result<void>>               reorderBlocks(int dayId, List<int> orderedIds);
Future<Result<int>>                upsertItem(RoutineItem item);
Future<Result<void>>               deleteItem(int itemId);
Future<Result<void>>               reorderItems(int blockId, List<int> orderedIds);
```

### ExerciseRepository

```dart
Future<Result<List<Exercise>>>  getAll();
Stream<List<Exercise>>          watchAll();
Future<Result<List<Exercise>>>  searchByBodyPart(BodyPart part);
Future<Result<int>>             upsert(Exercise exercise);
Future<Result<void>>            delete(int id);
```

### WorkoutRepository

```dart
Future<Result<WorkoutSession?>>  getInProgressSession();
Future<Result<WorkoutSession>>   startSession(int dayId);
Future<Result<int>>              logSet(SetLog log);
Future<Result<void>>             updateSet(SetLog log);
Future<Result<void>>             deleteSet(int setLogId);
Stream<WorkoutSession>           watchSession(int sessionId);
Future<Result<void>>             completeSession(int sessionId, {String? memo});
Future<Result<void>>             abortSession(int sessionId);
Future<Result<List<SetLog>>>     getLastLogsForExercise(int exerciseId, {int limit = 1});
```

### HistoryRepository

```dart
Future<Result<List<WorkoutSession>>>       getSessions(DateTimeRange range);
Future<Result<WorkoutSession>>             getSessionDetail(int sessionId);
Future<Result<Map<BodyPart, int>>>         getWeeklyVolume(DateTime weekStart);
Future<Result<List<ExerciseProgressPoint>>> getExerciseProgress(int exerciseId);
Future<Result<Set<DateTime>>>              getWorkoutDates(DateTime from, DateTime to);
```

`ExerciseProgressPoint { DateTime date; double topWeight; int reps; double estimated1RM; }`
- `estimated1RM` = Epley 공식 `weight × (1 + reps / 30)`

---

## 6. Drift 테이블 매핑

| Entity | 테이블 | 비고 |
|---|---|---|
| `Exercise` | `exercises` | |
| `Routine` | `routines` | |
| `RoutineDay` | `routine_days` | `routineId` FK, cascade delete |
| `RoutineBlock` | `routine_blocks` | `dayId` FK, cascade delete |
| `RoutineItem` | `routine_items` | `blockId` FK, cascade delete. `alternativeExerciseIds`는 CSV TEXT로 저장 |
| `WorkoutSession` | `workout_sessions` | |
| `SetLog` | `set_logs` | `sessionId` FK, cascade delete |

인덱스: `set_logs(sessionId)`, `set_logs(exerciseId, completedAt)`, `workout_sessions(date)`
