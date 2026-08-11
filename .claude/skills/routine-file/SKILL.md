---
name: routine-file
description: Convert a workout routine written in any free form — HTML, a markdown table, a screenshot, a plain-text plan — into a Workout Log `.json` the app can import, or fix/extend an existing routine file. Use whenever the user asks to turn a routine into a file, "루틴 파일로 뽑아줘", "이 HTML 앱에 넣게 해줘", "루틴 추가하고 싶어", or hands over any routine document. Also covers validating and troubleshooting a routine file that the app refused to import.
---

# 루틴을 앱이 읽는 파일로 변환

사용자가 자유 형식으로 쓴 운동 루틴을 `.json` 한 장으로 바꾼다.
앱은 HTML을 모른다 — 자유 형식을 읽는 일은 **네가** 하고, 앱은 엄격한 스키마 하나만 안다.

```
사람이 쓴 문서  ──(이 스킬)──▶  routines/*.json  ──(앱이 검증·가져오기)──▶  DB
   자유 형식                      엄격한 스키마
```

## 절차

### 1. 스키마를 읽는다 — 건너뛰지 않는다

[`docs/04-ROUTINE-EXCHANGE.md`](../../../docs/04-ROUTINE-EXCHANGE.md)가 포맷의 **유일한 기준**이다.
필드표·enum 값·검증 규칙이 전부 거기 있다. 기억에 의존해서 쓰면 CLI에서 걸린다.

### 2. 기존 종목 이름을 확인한다

**이름이 정확히 같아야 라이브러리의 기존 종목이 재사용된다.** 한 글자만 달라도 새 종목이
생기고, 그 순간 그 종목의 무게 추이 그래프와 과거 기록이 갈라진다.
(`시티드 케이블 로우`를 `시티드 로우`로 쓰는 실수가 실제로 났다.)

- **실제 예시 + 이름 확인**: [`routines/무분할-40분.json`](../../../routines/무분할-40분.json)
  — 시드 루틴을 그대로 내보낸 파일. 슈퍼세트·시간 슬롯·대체 종목·`isCuttable`이 전부
  들어 있어 이것만 보고도 형식을 흉내 낼 수 있다.
- **시드 종목 전체 목록** (위 파일에 안 쓰인 것까지):
  Grep으로 `lib/data/database/seed/routine_seed.dart`에서
  패턴 `_ExerciseSpec\(\s*'([^']+)'` · `multiline: true` · `-o`.
- 사용자가 앱에서 직접 추가한 **커스텀 종목은 저장소에서 볼 수 없다.**
  원문에 없던 종목이 나오면 그대로 새로 만들되, 기존 것과 같은 종목 같으면 물어본다.

### 3. `.json`을 쓴다

`routines/<루틴이름>.json`에 저장한다. 사용자가 위치를 지정하면 거기에.

원문에 없는 값은 **추측해서 채우되 무엇을 채웠는지 보고한다.** 특히:

| 필드 | 원문에 없을 때 |
|---|---|
| `restSeconds` | **필수다.** 없으면 강도로 정한다 — 메인 복합운동 150~180, 보조 90~120, 고립 60~90, 슈퍼세트 라운드 간 90 |
| `targetMinutes` | 세트 수 × (수행 + 휴식)으로 어림. 합이 `sessionMinutes`에 얼추 맞는지 본다 |
| `primaryBodyPart` | 그날 볼륨이 가장 많은 부위 |
| `isCuttable` | 그날 메인 블록만 `false`, 나머지는 생략(기본 `true`) |
| `targetRir` | 원문에 RIR/RPE 언급이 없으면 생략 |

### 4. 검증한다 — 이 단계를 빼지 않는다

```bash
dart run tools/validate_routine.dart routines/<파일>.json
```

앱과 **같은 코덱**으로 검사한다. 여기서 통과하면 폰에서도 들어간다.
통과하면 DAY 수 · 총 세트 · 부위별 주간 볼륨이 찍힌다. **이 숫자를 원문과 대조한다** —
형식이 맞아도 세트 수를 잘못 옮겼으면 여기서 드러난다.

### 5. 사용자에게 넘긴다

파일 경로와 함께 요약(루틴명 · DAY · 총 세트 · 부위별 볼륨)을 보여주고,
추측으로 채운 값이 있으면 명시한다. 그다음 넣는 법:

> 파일을 폰으로 옮긴 뒤 **루틴 목록 → 가져오기**에서 고르거나,
> 드라이브·카톡에서 `.json`을 **공유 → Workout Log**.
> 앱이 미리보기를 먼저 보여주니 거기서 한 번 더 확인하면 된다.

## 변환할 때 자주 틀리는 것

- `restSeconds`는 블록마다 **반드시** 쓴다. 기본값이 없다.
- 슈퍼세트는 블록 `type: "superset"` + `rounds`, 그리고 **각 `items[].sets`를 `rounds`와 같은 수로** 맞춘다.
  어긋나면 가져오기가 경고를 내고 `rounds`로 맞춰버린다.
- 복근처럼 시간으로 하는 슬롯은 `repMode: "duration"` + `durationSeconds`.
  이러면 **주간 볼륨에서 빠진다** — 시간 슬롯을 `range`로 쓰면 볼륨이 부풀어 오른다.
- enum은 영문 코드값이다: `back` `chest` `shoulder` `legs` `arms` `abs` /
  `straight` `superset` / `range` `amrap` `duration`.
  오타는 조용히 넘어가지 않고 오류로 잡힌다(`leg` → 오류).
- `alternatives`는 종목 **이름** 배열이다. id가 아니다.
- 종목을 문자열로 축약(`"exercise": "티바로우"`)하려면 같은 파일 안에 그 이름의
  객체 정의가 한 번은 있어야 한다.
- `code`는 `A`·`B`처럼 짧게(8자 이하). 요일 이름이 아니라 **순번**이다.

## 파일이 거부당했다고 할 때

CLI를 그 파일에 그대로 돌린다. 오류는 위치가 경로로 찍힌다:

```
routine.days[1].blocks[0].items[2].repMax: repMin(12)보다 작습니다 (8)
routine.days[2].primaryBodyPart: 알 수 없는 값 "leg"
```

코덱은 첫 오류에서 멈추지 않고 **전부 모아서** 보고하므로, 한 번에 다 고칠 수 있다.
검증에 실패한 파일은 DB를 건드리지 않으니 앱 상태를 걱정할 필요는 없다.

## 하지 않을 것

- **앱에 HTML 파서를 넣지 않는다.** 이 경계를 두는 이유가 그것이다. 원문 형식이 매번 달라도
  앱은 고치지 않는다.
- `docs/04-ROUTINE-EXCHANGE.md`와 `lib/data/exchange/routine_codec.dart`를 어긋나게 두지 않는다.
  포맷을 바꿔야 하면 문서 · 코덱 · `test/routine_exchange_test.dart`를 함께 고친다.
- `routines/무분할-40분.json`을 손으로 고치지 않는다. 시드에서 생성되며
  `test/routine_export_file_test.dart`가 일치를 강제한다. 시드를 고쳤다면:
  ```bash
  UPDATE_ROUTINE_EXPORT=1 flutter test test/routine_export_file_test.dart
  ```
