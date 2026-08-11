# Workout Log

`무분할-40분-루틴.html` 설계서를 그대로 굴릴 수 있게 만든 Flutter 운동 기록 앱.
루틴을 보고, 세트·무게·반복·휴식을 기록하고, 주간 볼륨을 확인한다.

앱 이름은 Workout Log이고, `무분할 40분`은 그 안에 기본으로 깔리는 **루틴 하나의 이름**이다.
루틴은 여러 개를 두고 갈아 끼울 수 있으며, 파일로 주고받을 수도 있다.

## 이 앱이 지키는 것

원문 설계서의 핵심 규칙을 앱 구조로 강제한다.

| 규칙 | 앱에서의 구현 |
|---|---|
| **하체는 매 세션 고정 슬롯** | 시드 루틴의 모든 DAY에 하체 3세트가 들어가 있고, 통계에서 주 12세트가 검증된다 |
| **순번은 요일이 아니라 A→B→C→D** | 마지막 완료 세션 기준으로 다음 DAY를 계산한다. 결석해도 균형이 깨지지 않는다 |
| **컷은 뒤에서부터, B1은 자르지 않는다** | 각 DAY의 B1은 `isCuttable = false`. 세션 화면에서 컷 버튼이 나오지 않는다 |
| **이중 프로그레션** | 모든 세트가 목표 반복 상단에 도달하면 세션 종료 시 +2.5% 증량을 제안한다 |
| **기구가 없으면 30초 안에 갈아탄다** | 종목마다 대체 종목이 지정돼 있고, 세션 중 교체해도 루틴 원본은 그대로다 |
| **기록은 메인 종목만이라도** | 세트별 입력은 지난 기록으로 미리 채워져 한 번 탭이면 끝난다 |

### 루틴은 갈아 끼운다

분할이 바뀌면 루틴을 새로 만들면 된다. 쓰던 루틴과 그 기록은 그대로 남는다.

- **루틴 목록** — 홈이나 루틴 탭의 제목을 누르면 열린다. 활성화 · 복제 · 내보내기 · 삭제
- **사용 중인 루틴은 항상 하나** — 홈의 오늘 카드와 운동 화면이 그 루틴을 따른다
- **비활성 루틴도 편집된다** — 쓰던 루틴을 유지한 채 다음 분할을 미리 짜둘 수 있다
- 마지막 남은 루틴, 진행 중인 운동이 있는 루틴은 삭제되지 않는다

### 루틴 가져오기 / 내보내기

루틴은 `.json` 한 장으로 오간다. 형식은 [`docs/04-ROUTINE-EXCHANGE.md`](docs/04-ROUTINE-EXCHANGE.md).

**가져오기**

1. 루틴 파일을 폰으로 옮긴다.
2. **루틴 목록 → 가져오기**에서 고르거나, 다른 앱에서 `.json`을 **공유 → Workout Log**.
3. 미리보기(루틴명 · DAY · 총 세트 · 부위 볼륨 · 경고)를 확인하고 추가한다.

읽는 데 실패하면 문제 위치를 전부 한 번에 보여준다:
`routine.days[1].blocks[0].items[2].repMax: repMin(12)보다 작습니다 (8)`.
검증에 실패하면 DB는 건드리지 않는다.

종목은 **이름이 같으면 기존 것을 재사용**한다. 그래야 무게 추이 그래프와 과거 기록이 이어진다.

**내보내기**

루틴 카드의 공유 버튼 → `루틴이름_yyyyMMdd.json`이 공유 시트로 나간다.
설계만 담기고 id와 운동 기록은 들어가지 않는다.

**루틴 문서를 파일로 바꾸기**

HTML이든 표든 메모든, 루틴 문서를 Claude에게 주고 "루틴 파일로 뽑아줘"라고 하면
`.claude/skills/routine-file`이 [`routines/`](routines/)에 `.json`을 만들어 준다.
형식 기준은 [`docs/04-ROUTINE-EXCHANGE.md`](docs/04-ROUTINE-EXCHANGE.md) 하나다.

작성 예시는 [`routines/무분할-40분.json`](routines/무분할-40분.json) — 시드 루틴을 그대로
내보낸 파일이라 슈퍼세트·시간 슬롯·대체 종목이 전부 들어 있다. 이 루틴의 복구 지점이기도 하다.

**폰에 넣기 전 검증**

```bash
dart run tools/validate_routine.dart <파일.json>
```

앱과 같은 코덱으로 검사하고 DAY 수 · 총 세트 · 부위별 주간 볼륨을 찍는다.
이 숫자가 의도와 맞는지 보고 넣으면 된다.

### 휴식 타이머는 화면을 꺼도 동작한다

카운트다운은 남은 초를 세는 대신 **종료 시각**을 기준으로 매번 다시 계산하고, 알림은 Dart 타이머가
아니라 시스템 알람으로 예약한다. 그래서 폰을 주머니에 넣고 화면을 꺼둬도 휴식이 끝나는 순간
소리·진동으로 알려주고, 앱으로 돌아오면 남은 시간이 어긋나 있지 않다.

## 기술 스택

| 영역 | 선택 |
|---|---|
| 프레임워크 | Flutter 3.44 / Dart 3.12 |
| 아키텍처 | Clean Architecture (layer-first) + MVI |
| 상태관리 | flutter_bloc — Intent → Bloc → State (+ 1회성 Effect) |
| 로컬 DB | Drift (SQLite) |
| DI | get_it + injectable |
| 라우팅 | go_router |
| 차트 | fl_chart |
| 파일 입출력 | flutter_file_dialog (선택) · share_plus (공유) · receive_sharing_intent (수신) |

계층 구조와 규약은 [`docs/00-ARCHITECTURE.md`](docs/00-ARCHITECTURE.md) 참고.

## 실행

```bash
flutter pub get
dart run build_runner build     # drift + injectable 코드 생성 (--delete-conflicting-outputs 플래그 없음)
flutter run -d <android-device-id>
```

디바이스 목록은 `flutter devices`.

### 빌드

```bash
flutter build apk --debug
flutter build apk --release
```

현재 Android만 대상으로 한다.

## 검증

```bash
flutter analyze     # 경고 0개 유지
flutter test
```

테스트는 인메모리 SQLite 위에서 Bloc → UseCase → Repository → Drift 전 구간을 실제로 돌린다. 목(mock)을 쓰지 않는다.

핵심 검증 항목:
- 시드 루틴의 주간 볼륨이 설계값과 일치 (어깨 19 · 가슴 17 · 등 16 · 하체 12 · 팔 6 = **70세트**)
- 슈퍼세트가 라운드로 교대되고 휴식이 라운드 끝에서만 발생
- 앱을 껐다 켜도 세션 진행 위치가 복원
- 루틴을 편집해도 과거 기록의 종목명·부위 스냅샷이 보존

## 문서

| 문서 | 내용 |
|---|---|
| [`docs/00-ARCHITECTURE.md`](docs/00-ARCHITECTURE.md) | 계층 규약, 폴더 구조, MVI 계약, 명명·커밋 규칙 |
| [`docs/01-DOMAIN-MODEL.md`](docs/01-DOMAIN-MODEL.md) | 엔티티 명세, Repository 인터페이스, Drift 매핑 |
| [`docs/02-ROUTINE-SEED.md`](docs/02-ROUTINE-SEED.md) | 무분할 40분 루틴 전문 — DAY A~D, 주간 볼륨, 운영 규칙, 디자인 토큰 |
| [`docs/03-STEPS.md`](docs/03-STEPS.md) | 단계별 진행 현황. **작업을 이어받을 때 여기부터 읽는다** |
| [`docs/04-ROUTINE-EXCHANGE.md`](docs/04-ROUTINE-EXCHANGE.md) | 루틴 `.json` 교환 포맷 명세와 HTML → JSON 변환 절차 |
| [`routines/README.md`](routines/README.md) | 루틴 파일 보관함. 작성 예시와 앱에 넣는 법 |

## 데이터

최초 실행 시 `무분할 40분` 루틴과 종목 마스터 29개가 자동으로 삽입된다
(`lib/data/database/seed/routine_seed.dart`). 시드를 고칠 때는
`docs/02-ROUTINE-SEED.md`도 함께 갱신하고 `test/routine_seed_test.dart`를 돌린다.

루틴은 앱 안에서 자유롭게 편집할 수 있다. 편집은 앞으로의 세션에만 영향을 주며,
과거 기록은 종목명·부위를 스냅샷으로 들고 있어 변형되지 않는다.

루틴을 여러 개 두어도 DB 스키마는 그대로다(`schemaVersion` 1). 운동 기록은 루틴을 지워도
남는다 — 세션이 종목명·부위·DAY 코드를 스냅샷으로 갖고 있기 때문이다.
