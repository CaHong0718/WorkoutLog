# 루틴 파일

앱이 가져오기/내보내기로 주고받는 `.json`을 모아두는 곳.
형식은 [`../docs/04-ROUTINE-EXCHANGE.md`](../docs/04-ROUTINE-EXCHANGE.md).

## 여기 있는 것

| 파일 | 설명 |
|---|---|
| `무분할-40분.json` | 앱에 기본으로 깔리는 시드 루틴을 그대로 내보낸 것. **손으로 고치지 않는다** — 시드에서 생성되고 `test/routine_export_file_test.dart`가 일치를 강제한다 |

`무분할-40분.json`은 두 가지로 쓴다.

1. **작성 예시** — 슈퍼세트, 시간 기반 복근 슬롯, 대체 종목, `isCuttable`이 전부 들어 있어
   새 루틴을 쓸 때 이것만 보고 형식을 맞출 수 있다.
2. **복구 지점** — 폰에서 루틴을 편집하다 되돌리고 싶으면 이 파일을 다시 가져오면 된다.

시드를 고쳤다면 함께 다시 생성한다.

```bash
UPDATE_ROUTINE_EXPORT=1 flutter test test/routine_export_file_test.dart
```

## 새 루틴 만들기

HTML이든 표든 메모든, 루틴 문서를 Claude에게 주고 **"루틴 파일로 뽑아줘"** 라고 하면
`.claude/skills/routine-file`이 이 폴더에 `.json`을 만들어 준다.

폰에 넣기 전에 검증한다.

```bash
dart run tools/validate_routine.dart routines/<파일>.json
```

DAY 수 · 총 세트 · 부위별 주간 볼륨을 찍는다. 이 숫자가 의도와 맞는지 확인하고 넣는다.

## 앱에 넣기

1. 파일을 폰으로 옮긴다(드라이브 · 카톡 · USB 무엇이든).
2. **루틴 목록 → 가져오기**에서 고르거나, 다른 앱에서 `.json`을 **공유 → Workout Log**.
3. 미리보기를 확인하고 추가한다.

가져오기는 기존 루틴을 건드리지 않는다. 새 루틴으로 추가되고, `추가하고 바로 사용`을
켜야 사용 중인 루틴이 바뀐다.
