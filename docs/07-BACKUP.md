# 기록 백업 포맷 (`.json`)

> 앱을 지우거나 폰을 바꿔도 운동 기록이 따라오게 하는 파일 형식.
> **이 문서가 포맷의 유일한 기준이다.** 코드(`lib/data/exchange/backup_codec.dart`)와 항상 일치시킨다.
>
> 루틴만 주고받는 파일은 [`04-ROUTINE-EXCHANGE.md`](04-ROUTINE-EXCHANGE.md)다. 백업은 그 위에 얹혀 있다 —
> 백업 파일 안의 루틴 하나는 루틴 교환 파일의 `routine` 객체와 **글자 하나까지 같다.**

---

## 1. 왜 SQLite 파일이 아닌가

`workout_log.sqlite`를 통째로 복사하는 쪽이 짧다. 그런데 세 가지가 걸린다.

| | SQLite 파일 | JSON |
|---|---|---|
| 복원 | 앱을 끄고 파일을 갈아끼운 뒤 재시작 | 열려 있는 DB에 트랜잭션으로 넣는다 |
| 두 기기 기록 합치기 | 불가능. 한쪽을 버려야 한다 | `startedAt`으로 중복만 걸러 합친다 |
| 스키마가 바뀌면 | 옛 파일이 마이그레이션을 타야 한다 | 이름 기반이라 열 추가·삭제와 무관 |
| 사람이 열어보기 | 불가능 | 열린다. 손으로 고칠 수도 있다 |

그리고 이미 STEP 10에서 코덱·파일 선택·공유 시트가 다 깔려 있다. 백업은 그 길을 늘리는 일이지
새로 내는 길이 아니다.

---

## 2. 최상위 구조

```json
{
  "format": "workout-log.backup",
  "version": 1,
  "exportedAt": "2026-08-21T09:00:00.000",
  "summary": { "routines": 2, "exercises": 31, "sessions": 84, "sets": 1203 },
  "exercises": [ ... ],
  "routines":  [ ... ],
  "sessions":  [ ... ]
}
```

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `format` | string | ✅ | 반드시 `"workout-log.backup"`. 루틴 파일을 백업으로 여는 사고를 막는다 |
| `version` | int | ✅ | 현재 `1`. 모르는 버전이면 거부한다 |
| `exportedAt` | string(ISO8601) | — | 내보낼 때만 채운다. **복원은 무시한다** |
| `summary` | object | — | 사람이 파일을 열어봤을 때 규모를 알라고 넣는다. **복원은 무시한다** — 세는 것은 늘 실제 배열이다 |
| `exercises` | array | — | §3 |
| `routines` | array | — | §4 |
| `sessions` | array | — | §5 |

셋 다 비어 있어도 파일은 유효하다. 기록만 있는 백업, 루틴만 있는 백업이 모두 말이 된다.

---

## 3. `exercises[]` — 종목 마스터

```json
{ "name": "랫 풀다운", "bodyPart": "back", "subTarget": "광배", "equipment": "케이블", "isCustom": true }
```

| 필드 | 타입 | 필수 | 기본값 | 제약 |
|---|---|---|---|---|
| `name` | string | ✅ | — | 1–120자. **신원(identity)** |
| `bodyPart` | enum | ✅ | — | `04` §8 `BodyPart` |
| `subTarget` | string? | — | `null` | |
| `equipment` | string? | — | `null` | |
| `isCustom` | bool | — | `false` | 사용자가 직접 추가한 종목인지 |

루틴이 참조하지 않는 종목까지 담는다. 4주 로테이션으로 루틴에서 뺐지만 과거 기록에는 남아 있는
종목이 여기 없으면, 복원 뒤 무게 추이 그래프의 후보 목록에서 사라진다.

**이름이 신원이다.** 한 글자만 달라도 다른 종목이 되고 추이 그래프가 갈라진다(`04` §7.1과 같은 규칙).

---

## 4. `routines[]` — 루틴

[`04-ROUTINE-EXCHANGE.md`](04-ROUTINE-EXCHANGE.md) §3~§7의 `routine` 객체 **그대로**, `isActive` 하나만 더 붙는다.

```json
{
  "name": "무분할 40분",
  "description": "...",
  "sessionMinutes": 40,
  "isActive": true,
  "days": [ ... ]
}
```

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|---|---|---|---|---|
| `isActive` | bool | — | `false` | 백업 시점에 쓰던 루틴. **덮어쓰기 복원만 이 값을 따른다**(§7) |

나머지 필드는 전부 `04` 문서가 정의한다. 이 문서에 다시 적지 않는다 —
두 벌로 적으면 반드시 어긋난다. 코드도 같은 이유로 `RoutineCodec`의 루틴 본문 코덱을 그대로 호출한다.

`isActive`가 여럿이면 첫 번째만 살리고 경고한다.

---

## 5. `sessions[]` — 운동 기록

```json
{
  "routine": "무분할 40분",
  "dayCode": "A",
  "dayTitle": "어깨 + 가슴",
  "date": "2026-08-18",
  "startedAt": "2026-08-18T19:02:11.000",
  "endedAt": "2026-08-18T19:44:35.000",
  "status": "completed",
  "memo": "왼쪽 어깨 뻐근",
  "sets": [ ... ]
}
```

| 필드 | 타입 | 필수 | 기본값 | 제약 |
|---|---|---|---|---|
| `routine` | string? | — | `null` | 루틴 **이름**. 복원할 때 이름으로 다시 잇는다 |
| `dayCode` | string | ✅ | — | 1–8자. 스냅샷 |
| `dayTitle` | string | ✅ | — | 스냅샷 |
| `date` | string(`yyyy-MM-dd`) | ✅ | — | 달력 키. 그 지역의 자정으로 읽는다 |
| `startedAt` | string(ISO8601) | ✅ | — | **세션의 신원**(§7) |
| `endedAt` | string? | — | `null` | `startedAt` 이후여야 한다 |
| `status` | enum | — | `completed` | `completed` \| `aborted` |
| `memo` | string? | — | `null` | |
| `sets` | array | — | `[]` | §6 |

**`inProgress`는 내보내지 않고, 들어와도 거부한다.** 진행 중 세션은 기록이 아니라 그 기기의
현재 상태다. 복원해봐야 홈에 유령 "이어서 하기" 배너가 뜬다.

**`date`를 날짜만 쓰는 이유.** DB에는 자정 `DateTime`으로 들어 있는데, 시각까지 적으면 다른
시간대에서 복원할 때 하루가 밀린다. 달력이 어긋나는 것보다 시각을 버리는 쪽이 낫다.

**id는 하나도 내보내지 않는다.** `routineId`·`dayId`·`routineItemId`·`exerciseId`는 기기마다 다른
번호다. 대신 이름과 스냅샷으로 다시 잇는다 — 못 이어도 기록은 그대로 읽힌다. 그러라고
`SetLog`가 종목명·부위·블록 라벨을 스냅샷으로 들고 있는 것이다.

---

## 6. `sets[]` — 세트

```json
{
  "exercise": "사이드 레터럴 라이즈",
  "bodyPart": "shoulder",
  "blockLabel": "B1",
  "itemOrder": 0,
  "setIndex": 1,
  "weight": 10,
  "reps": 12,
  "rir": 2,
  "restSeconds": 75,
  "completedAt": "2026-08-18T19:05:00.000"
}
```

| 필드 | 타입 | 필수 | 기본값 | 제약 |
|---|---|---|---|---|
| `exercise` | string | ✅ | — | 종목 **이름** 스냅샷 |
| `bodyPart` | enum | ✅ | — | 부위 스냅샷. 주간 볼륨은 이 값으로 집계된다 |
| `blockLabel` | string | ✅ | — | 1–20자. `"B1"` |
| `itemOrder` | int | ✅ | — | 0 이상. 세션 안에서 종목의 순서 |
| `setIndex` | int | ✅ | — | 1 이상. 종목 안에서 세트 번호 |
| `weight` | number? | — | `null` | 0–1000(kg). `null`·`0` 모두 맨몸 |
| `reps` | int? | — | `null` | 0–1000 |
| `durationSeconds` | int? | — | `null` | 0–7200 |
| `rir` | int? | — | `null` | 0–10 |
| `restSeconds` | int? | — | `null` | 0–3600. 실제로 잰 휴식 |
| `isCompleted` | bool | — | `true` | `false`면 건너뛴 세트 |
| `completedAt` | string(ISO8601) | ✅ | — | |

null인 필드는 파일에 쓰지 않는다. 세트가 수천 개라 이 규칙 하나로 파일이 눈에 띄게 짧아진다.

---

## 7. 복원 규칙

두 가지 모드가 있고, 앱은 **합치기를 기본으로** 제시한다.

| 모드 | 하는 일 |
|---|---|
| **합치기** | 기존 데이터를 지우지 않는다. 이름이 같은 종목·루틴은 재사용하고, 이미 있는 세션은 건너뛴다 |
| **덮어쓰기** | 모든 표를 비우고 백업 내용만 넣는다. 되돌릴 수 없다 |

### 7.1 신원 규칙

| 무엇 | 신원 |
|---|---|
| 종목 | `name` 정확 일치 |
| 루틴 | `name` 정확 일치 |
| 세션 | `startedAt` 정확 일치 (밀리초까지) |

세션에 `startedAt`을 쓰는 이유: 같은 밀리초에 두 번 운동을 시작할 수는 없다. DB가 날짜를
ISO 문자열로 저장하므로(`build.yaml`의 `store_date_time_values_as_text`) 정밀도가 왕복해도 살아남는다.

### 7.2 합치기 순서

한 트랜잭션 안에서 이 순서로만 돈다.

1. **종목** — 이름으로 대조, 없으면 만든다.
2. **루틴** — 이름이 같은 루틴이 이미 있으면 **건너뛴다.** 백업이 지금 쓰는 루틴의 편집을
   덮지 않는다. 없으면 `importRoutine`과 같은 경로로 넣는다.
3. **세션** — `startedAt`이 이미 있으면 건너뛴다. 없으면 세션과 세트를 넣는다.
   - `routineId`: 이름으로 찾은 루틴. 못 찾으면 `0`(어떤 루틴도 가리키지 않음). FK가 아니라 괜찮다.
   - `dayId`: 그 루틴 안에서 `dayCode`가 같은 DAY. 없으면 `null`.
   - `exerciseId`: 이름으로 찾은 종목. 없으면 `bodyPart` 스냅샷으로 만들어 붙인다.
4. **활성 루틴은 건드리지 않는다.** 쓰던 루틴 그대로다.

### 7.3 덮어쓰기 순서

1. **진행 중 세션이 있으면 거부한다.** 랙 앞에서 발밑을 빼지 않는다.
2. `set_logs → workout_sessions → routine_items → routine_blocks → routine_days → routines → exercises`
   순으로 비운다(자식부터).
3. 7.2와 같은 삽입을 빈 상태에서 수행한다.
4. `isActive`가 `true`인 루틴을 활성화한다. 없으면 첫 루틴.

**시드는 다시 깔리지 않는다.** `seedIfEmpty`는 `beforeOpen`에서만 돌고, 복원은 이미 열린 DB에서
일어난다. 비운 직후 백업이 들어가므로 빈 상태로 남는 순간이 없다.

### 7.4 전부 하나의 트랜잭션

중간에 실패하면 아무것도 바뀌지 않는다. 절반만 복원된 DB는 백업이 없는 것보다 나쁘다.

---

## 8. 파일 이름

```
운동기록_20260821.json
```

`RoutineExchange.fileNameFor`와 같은 규칙(경로에 못 쓰는 글자 제거 + `_yyyyMMdd`).

---

## 9. 크기 상한

루틴 파일은 4MB, 백업은 **16MB**까지 읽는다. 세트 하나가 대략 150바이트라
16MB면 10만 세트 — 하루 25세트로 10년 넘는 분량이다. 그보다 큰 파일은 잘못 고른 것이다.

---

## 10. 검증 CLI

폰에 넣기 전에 여기서 먼저 확인한다.

```bash
dart run tools/validate_backup.dart 운동기록_20260821.json
```

앱과 **같은 코덱**으로 읽고 루틴·종목·세션·세트 수와 기록 기간을 찍는다.
`BackupCodec`이 `dart:convert`와 domain 말고는 아무것도 import하지 않기 때문에 가능하다
(`RoutineCodec`과 같은 규칙 — 이 제약을 깨면 CLI가 죽는다).

---

## 11. 오류 보고

`RoutineFormatFailure`를 그대로 쓴다. 첫 오류에서 멈추지 않고 **전부 모아** 경로와 함께 보고한다.

```
sessions[3].sets[11].setIndex: 1 이상이어야 합니다 (0)
sessions[7].startedAt: ISO8601 날짜여야 합니다 ("어제")
routines[0].days[1].blocks[0].items[2].repMax: repMin(12)보다 작습니다 (8)
```

루틴 쪽 경로도 `RoutineCodec`이 직접 만든다 — 백업 코덱이 `routines[i]`를 경로로 넘겨주기 때문에
문자열을 고쳐 붙이는 단계가 없다.

경고는 복원을 막지 않고 미리보기에 뜬다.

| 경고 | 언제 |
|---|---|
| 활성 루틴이 여럿 | `isActive`가 두 개 이상. 첫 번째만 살린다 |
| 루틴을 찾지 못함 | `sessions[].routine`이 파일에도 DB에도 없는 이름 |
| DAY를 찾지 못함 | `dayCode`가 그 루틴에 없다. 기록은 스냅샷으로 남는다 |
| 종목을 새로 만듦 | 세트의 종목이 마스터에 없어 스냅샷으로 만들었다 |
| 이미 있는 세션을 건너뜀 | 합치기에서 `startedAt`이 겹쳤다 |
