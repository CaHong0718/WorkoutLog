# 루틴 교환 포맷 (`.json`)

> 앱 밖에서 짠 루틴을 앱으로 들여오고, 앱의 루틴을 밖으로 내보내기 위한 파일 형식.
> **이 문서가 포맷의 유일한 기준이다.** 코드(`lib/data/exchange/routine_codec.dart`)와 항상 일치시킨다.

---

## 1. 왜 JSON인가

HTML을 앱이 직접 파싱하지 않는다. HTML은 사람이 읽으라고 만든 문서라 구조가 매번 다르고,
파서를 아무리 잘 짜도 다음 문서에서 깨진다. 대신 **경계를 하나 둔다.**

```
사람이 쓴 HTML  ──(Claude가 변환)──▶  routine.json  ──(앱이 검증·가져오기)──▶  DB
   자유 형식                          엄격한 스키마
```

앱은 **엄격한 스키마 하나만** 안다. 자유 형식을 해석하는 일은 대화(Claude)가 맡는다.
새 형식의 문서가 와도 앱은 고치지 않는다.

---

## 2. 최상위 구조

```json
{
  "format": "workout-log.routine",
  "version": 1,
  "exportedAt": "2026-08-11T14:00:00.000",
  "routine": { ... }
}
```

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `format` | string | ✅ | 반드시 `"workout-log.routine"`. 다른 JSON을 실수로 여는 것을 막는다 |
| `version` | int | ✅ | 현재 `1`. 앱이 모르는 버전이면 거부한다 |
| `exportedAt` | string(ISO8601) | — | 내보낼 때만 채운다. 가져오기는 무시한다 |
| `routine` | object | ✅ | §3 |

---

## 3. `routine`

| 필드 | 타입 | 필수 | 기본값 | 제약 |
|---|---|---|---|---|
| `name` | string | ✅ | — | 1–120자 |
| `description` | string? | — | `null` | |
| `sessionMinutes` | int | — | `40` | 1–600. 복근 슬롯 제외한 1회 목표 시간 |
| `days` | array | ✅ | — | 1개 이상 |

---

## 4. `days[]` — 순번 DAY

| 필드 | 타입 | 필수 | 기본값 | 제약 |
|---|---|---|---|---|
| `code` | string | ✅ | — | 1–8자. `"A"`, `"B"` … 화면의 원형 배지 |
| `title` | string | ✅ | — | 1–120자. `"등 + 이두"` |
| `subtitle` | string? | — | `null` | `"당기기 데이"` |
| `description` | string? | — | `null` | 설계 의도. DAY 카드에 표시 |
| `primaryBodyPart` | enum | ✅ | — | §8 `BodyPart` |
| `blocks` | array | — | `[]` | |

배열 순서가 곧 순번이다. `order` 필드는 없다 — 파일에 쓰인 순서대로 A→B→C→D로 순환한다.

---

## 5. `blocks[]` — 블록

| 필드 | 타입 | 필수 | 기본값 | 제약 |
|---|---|---|---|---|
| `label` | string | ✅ | — | 1–20자. `"B1"`, `"복근"` |
| `name` | string? | — | `null` | `"메인 — 오늘의 약점"` |
| `type` | enum | — | `"straight"` | `straight` \| `superset` |
| `rounds` | int | — | `1` | 1–50. `superset`일 때 라운드 수 |
| `restSeconds` | int | ✅ | — | 0–3600. 세트(또는 라운드) 간 휴식 |
| `targetMinutes` | int? | — | `null` | 1–600. 이 블록의 목표 소요 시간 |
| `isCuttable` | bool | — | `true` | 시간이 모자랄 때 잘라도 되는지. 메인 블록은 `false` |
| `items` | array | — | `[]` | |

---

## 6. `items[]` — 블록 안의 종목 슬롯

| 필드 | 타입 | 필수 | 기본값 | 제약 |
|---|---|---|---|---|
| `exercise` | object \| string | ✅ | — | §7. 문자열이면 이름만 준 것으로 본다 |
| `sets` | int | ✅ | — | 1–50 |
| `repMode` | enum | — | `"range"` | `range` \| `amrap` \| `duration` |
| `repMin` | int? | `range`일 때 ✅ | — | 1–200 |
| `repMax` | int? | `range`일 때 ✅ | — | 1–200, `repMin` 이상 |
| | | | | 둘 중 하나만 써도 된다 — 나머지가 같은 값으로 채워져 `4 × 10`이 된다 |
| `durationSeconds` | int? | `duration`일 때 ✅ | — | 1–7200 |
| `restSecondsOverride` | int? | — | `null` | 0–3600. 블록 기본 휴식과 다를 때만 |
| `targetRir` | int? | — | `null` | 0–10 |
| `note` | string? | — | `null` | 수행 팁 |
| `alternatives` | string[] | — | `[]` | 대체 종목 **이름** 목록 |

**`repMode`별 규칙**

| `repMode` | 필요한 필드 | 표시 | 주간 볼륨 |
|---|---|---|---|
| `range` | `repMin`, `repMax` | `4 × 8–10` | `sets`만큼 집계 |
| `amrap` | 없음 | `4 × AMRAP` | `sets`만큼 집계 |
| `duration` | `durationSeconds` | `5분` | **0** (복근 시간 슬롯은 볼륨에서 뺀다) |

`superset` 블록의 `items[].sets`는 블록의 `rounds`와 같게 쓴다. 다르면 가져오기가 경고하고
`rounds` 값으로 맞춘다.

---

## 7. `exercise` — 종목

객체로 쓰거나, 이름만 필요하면 문자열로 줄여 쓴다.

```json
"exercise": { "name": "랫 풀다운", "bodyPart": "back", "subTarget": "광배", "equipment": "케이블" }
"exercise": "랫 풀다운"
```

| 필드 | 타입 | 필수 | 제약 |
|---|---|---|---|
| `name` | string | ✅ | 1–120자. **종목의 식별자** |
| `bodyPart` | enum | ✅ | §8 |
| `subTarget` | string? | — | `"측면"`, `"상부"`, `"사두"` |
| `equipment` | string? | — | `"스미스머신"`, `"케이블"` |

**문자열 축약형은 같은 파일 안에 그 이름의 객체 정의가 한 번이라도 있을 때만 쓸 수 있다.**
파일만 보고 부위를 알 수 없으면 오류다 — 검증 CLI는 앱의 종목 라이브러리를 볼 수 없으므로,
파일이 스스로 완결돼야 폰에 넣기 전에 볼륨 집계까지 미리 확인할 수 있다.
같은 이름이 부위를 달리해 두 번 정의되면 **먼저 나온 쪽으로 통일**하고 경고를 남긴다.

### 7.1 종목 대조 규칙 (중요)

가져올 때 **이름이 정확히 같으면 라이브러리의 기존 종목을 재사용한다.** 새로 만들지 않는다.

- 이유: 종목이 갈리면 "종목별 무게 추이" 그래프와 과거 기록의 연결이 끊긴다.
- 이름이 같고 `bodyPart`가 다르면 **기존 라이브러리 값을 유지한다.** 파일이 라이브러리를 덮어쓰지 않는다.
  (다르게 다루고 싶으면 이름을 다르게 쓴다: `"랫 풀다운 (와이드)"`)
- 라이브러리에 없으면 새로 만들고 `isCustom = true`로 표시한다. 이때 `bodyPart`가 없으면 오류다.

### 7.2 `alternatives`

이름으로 참조한다. 해석 순서는 **① 같은 파일 안에 정의된 종목 → ② 기존 라이브러리**.
둘 다에서 못 찾으면 그 이름 하나만 조용히 버리고 나머지는 살린다(가져오기 자체는 실패하지 않는다).
버려진 이름은 가져오기 결과 요약에 경고로 보고한다.

---

## 8. Enum 값

코드 값(영문)을 쓴다. 한국어 라벨은 앱이 붙인다.

| `BodyPart` | 라벨 |   | `BlockType` |   | `RepMode` |
|---|---|---|---|---|---|
| `back` | 등 |   | `straight` |   | `range` |
| `chest` | 가슴 |   | `superset` |   | `amrap` |
| `shoulder` | 어깨 |   |  |   | `duration` |
| `legs` | 하체 |   |  |   |  |
| `arms` | 팔 |   |  |   |  |
| `abs` | 복근 |   |  |   |  |

모르는 값이 오면 **조용히 기본값으로 떨어뜨리지 않고 오류로 보고한다.** 오타를 삼키면
`legs`를 `leg`로 잘못 쓴 루틴이 전부 복근으로 집계되는 사고가 난다.

---

## 9. 검증 규칙

가져오기는 **전부 검증한 뒤 한 번에 삽입한다.** 오류가 하나라도 있으면 DB를 건드리지 않는다
(단일 트랜잭션). 오류 메시지는 위치를 경로로 찍는다.

```
routine.days[1].blocks[0].items[2].repMax: repMin(12)보다 작습니다 (8)
routine.days[2].primaryBodyPart: 알 수 없는 값 "leg"
```

경고(warning)는 가져오기를 막지 않는다. 위 §6의 `sets`/`rounds` 불일치, §7.2의 미해결 대체 종목이 해당한다.

---

## 10. 전체 예시

```json
{
  "format": "workout-log.routine",
  "version": 1,
  "routine": {
    "name": "상하체 2분할 50분",
    "description": "상체/하체를 번갈아 도는 2분할. 하체 날에도 코어를 반드시 넣는다.",
    "sessionMinutes": 50,
    "days": [
      {
        "code": "A",
        "title": "상체",
        "subtitle": "밀기 + 당기기",
        "primaryBodyPart": "chest",
        "blocks": [
          {
            "label": "B1",
            "name": "메인",
            "type": "straight",
            "restSeconds": 150,
            "targetMinutes": 15,
            "isCuttable": false,
            "items": [
              {
                "exercise": {
                  "name": "인클라인 벤치프레스 (스미스머신)",
                  "bodyPart": "chest",
                  "subTarget": "상부",
                  "equipment": "스미스머신"
                },
                "sets": 4,
                "repMode": "range",
                "repMin": 6,
                "repMax": 8,
                "targetRir": 2,
                "note": "견갑 고정하고 명치로 내린다",
                "alternatives": ["덤벨 인클라인 프레스"]
              }
            ]
          },
          {
            "label": "B2",
            "name": "슈퍼세트 — 어깨/등",
            "type": "superset",
            "rounds": 3,
            "restSeconds": 90,
            "targetMinutes": 12,
            "items": [
              {
                "exercise": { "name": "사이드 레터럴 라이즈", "bodyPart": "shoulder", "subTarget": "측면", "equipment": "덤벨" },
                "sets": 3,
                "repMode": "range",
                "repMin": 12,
                "repMax": 15
              },
              {
                "exercise": { "name": "시티드 로우", "bodyPart": "back", "equipment": "케이블" },
                "sets": 3,
                "repMode": "range",
                "repMin": 10,
                "repMax": 12
              }
            ]
          },
          {
            "label": "복근",
            "type": "straight",
            "restSeconds": 0,
            "targetMinutes": 5,
            "items": [
              {
                "exercise": { "name": "행잉 레그 레이즈", "bodyPart": "abs" },
                "sets": 1,
                "repMode": "duration",
                "durationSeconds": 300
              }
            ]
          }
        ]
      },
      {
        "code": "B",
        "title": "하체",
        "primaryBodyPart": "legs",
        "blocks": [
          {
            "label": "B1",
            "restSeconds": 180,
            "targetMinutes": 18,
            "isCuttable": false,
            "items": [
              {
                "exercise": { "name": "레그 프레스", "bodyPart": "legs", "subTarget": "사두" },
                "sets": 4,
                "repMode": "range",
                "repMin": 8,
                "repMax": 12,
                "targetRir": 2
              },
              {
                "exercise": { "name": "풀업", "bodyPart": "back" },
                "sets": 3,
                "repMode": "amrap"
              }
            ]
          }
        ]
      }
    ]
  }
}
```

---

## 11. HTML → JSON 변환 절차

> Claude로 작업한다면 `.claude/skills/routine-file` 스킬이 이 절차를 그대로 수행한다.
> "루틴 파일로 뽑아줘"라고 하면 된다.

사용자가 루틴 HTML(또는 그냥 글로 쓴 표)을 주면:

1. **Claude가 이 문서의 스키마대로 `.json`을 작성한다.** 앱은 HTML을 모른다.
   저장 위치는 `routines/<루틴이름>.json`. 형식이 헷갈리면
   `routines/무분할-40분.json`(시드 루틴 내보내기)을 보고 맞춘다.
2. 검증 CLI로 확인한다. 앱에 넣기 전에 오타를 잡는 단계다.
   ```bash
   dart run tools/validate_routine.dart <파일.json>
   ```
   통과하면 DAY 수 · 총 세트 · 부위별 주간 볼륨 요약을 찍는다. 이 숫자가 의도와 맞는지 본다.
3. 파일을 폰으로 옮긴다(드라이브·카톡·USB 무엇이든).
4. 앱 → **루틴 목록 → 가져오기** 에서 파일을 고른다.
   또는 다른 앱에서 `.json`을 **공유 → Workout Log** 로 바로 보낸다.

   > 공유 시트에 Workout Log가 안 보이면 그 앱이 파일을 `application/json`이 아닌
   > `text/plain` 같은 타입으로 넘기는 것이다. 앱 안의 **가져오기**는 타입을 가리지 않으므로
   > 그쪽으로 넣으면 된다. 공유 시트에 `*/*`로 등록하지 않는 이유는, 그러면 사진·링크를
   > 공유할 때마다 Workout Log가 목록에 끼어들기 때문이다.

변환할 때 자주 놓치는 것:

- `restSeconds`는 블록마다 **반드시** 쓴다. 기본값이 없다.
- 메인 블록은 `isCuttable: false`.
- 복근처럼 시간으로 하는 슬롯은 `repMode: "duration"` + `durationSeconds`. 이러면 주간 볼륨에서 빠진다.
- 슈퍼세트는 블록 `rounds`와 각 `items[].sets`를 같은 수로 맞춘다.
- 종목 이름은 **기존 라이브러리와 정확히 같게** 쓰면 과거 기록과 이어진다(§7.1).

---

## 12. 내보내기

앱의 루틴은 언제든 같은 포맷으로 나온다. 내보낸 파일은 그대로 다시 가져올 수 있다
(`test/routine_exchange_test.dart`가 시드 루틴으로 왕복을 검증한다).

내보낸 파일에는 **id도, 운동 기록도 들어가지 않는다.** 루틴의 설계만 옮긴다.
파일명은 `루틴이름_yyyyMMdd.json` 형태로 만든다.
