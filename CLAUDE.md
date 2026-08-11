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
- 커밋·푸시는 사용자가 요청할 때만 한다.

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
| [`docs/00-ARCHITECTURE.md`](docs/00-ARCHITECTURE.md) | 코드를 쓰기 전. 계층 규약·폴더 구조·MVI 계약·명명 규칙 |
| [`docs/01-DOMAIN-MODEL.md`](docs/01-DOMAIN-MODEL.md) | 엔티티·Repository·Drift 매핑을 다룰 때 |
| [`docs/02-ROUTINE-SEED.md`](docs/02-ROUTINE-SEED.md) | 시드 루틴·주간 볼륨 목표·디자인 토큰을 다룰 때 |

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

Dart 패키지명은 아직 `health_app`이다(`pubspec.yaml`의 `name`, `package:health_app/...` import).
앱 동작에는 영향이 없지만 이름이 어긋나 있다는 점만 알아둔다.

`무분할 40분`은 앱 이름이 아니라 **시드 루틴의 이름**이다. DB에 들어 있고 사용자가 바꿀 수 있다.

## 아이콘

`tools/generate_icon.py`가 `assets/icon/`의 원본 PNG를 그린다. 소스는 이 스크립트뿐이니
아이콘을 바꾸려면 스크립트를 고치고 아래를 순서대로 돌린다.

```bash
python tools/generate_icon.py     # Pillow 필요
dart run flutter_launcher_icons   # android/app/src/main/res/ 아래를 재생성
```

`android/.../res/mipmap-*`·`drawable-*`의 파일은 생성물이다. 직접 편집하지 않는다.
