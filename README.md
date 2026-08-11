# 무분할 40분 — 운동 기록 앱

`무분할-40분-루틴.html` 설계서를 그대로 굴릴 수 있게 만든 Flutter 운동 기록 앱.
루틴을 보고, 세트·무게·반복·휴식을 기록하고, 주간 볼륨을 확인한다.

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

## 데이터

최초 실행 시 `무분할 40분` 루틴과 종목 마스터 29개가 자동으로 삽입된다
(`lib/data/database/seed/routine_seed.dart`). 시드를 고칠 때는
`docs/02-ROUTINE-SEED.md`도 함께 갱신하고 `test/routine_seed_test.dart`를 돌린다.

루틴은 앱 안에서 자유롭게 편집할 수 있다. 편집은 앞으로의 세션에만 영향을 주며,
과거 기록은 종목명·부위를 스냅샷으로 들고 있어 변형되지 않는다.
