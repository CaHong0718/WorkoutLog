# 아키텍처 규약

> 이 문서는 코드를 작성하기 전에 반드시 읽는다. 세션이 clear되어도 이 문서만 읽으면 규약을 복원할 수 있어야 한다.

## 1. 전체 구조

Clean Architecture 3계층 + MVI 프레젠테이션 패턴.

```
┌─────────────────────────────────────────────┐
│ Presentation   Page / Widget / Bloc         │  ← Flutter 의존 O
│                Intent → Bloc → State → View │
├─────────────────────────────────────────────┤
│ Domain         Entity / Repository(추상)     │  ← 순수 Dart, 의존 X
│                UseCase                       │
├─────────────────────────────────────────────┤
│ Data           RepositoryImpl / DataSource   │  ← Drift 의존 O
│                Model(Drift row) ↔ Entity     │
└─────────────────────────────────────────────┘
```

의존 방향은 **항상 안쪽(Domain)으로만** 향한다.
- Domain은 Data/Presentation을 절대 import하지 않는다. `package:flutter/*`도 import하지 않는다.
- Presentation은 Domain만 import한다. Data 계층을 직접 참조하지 않는다.
- Data는 Domain의 Repository 인터페이스를 구현한다.

## 2. 폴더 구조

```
lib/
├── main.dart                     앱 진입점 (DI 초기화 → runApp)
├── app.dart                      MaterialApp.router 설정
│
├── core/                         전 기능 공용
│   ├── di/                       get_it + injectable 설정
│   │   └── injection.dart
│   ├── error/
│   │   └── failure.dart          Failure sealed class
│   ├── result/
│   │   └── result.dart           Result<T> sealed class (Success/FailureResult)
│   ├── mvi/                      MVI 베이스 계약
│   │   ├── mvi_intent.dart
│   │   ├── mvi_state.dart
│   │   ├── mvi_effect.dart
│   │   └── mvi_bloc.dart
│   ├── database/                 Drift (공용 인프라)
│   │   ├── app_database.dart
│   │   ├── tables/
│   │   ├── daos/
│   │   └── seed/                 무분할 40분 루틴 시드 데이터
│   ├── theme/
│   │   ├── app_colors.dart       루틴 HTML 디자인 토큰 이식
│   │   ├── app_typography.dart
│   │   └── app_theme.dart
│   ├── router/
│   │   └── app_router.dart       go_router
│   ├── constants/
│   ├── extensions/
│   └── widgets/                  공용 위젯 (BodyPartChip, SectionCard 등)
│
└── features/
    ├── routine/                  루틴 조회 · 편집
    │   ├── domain/
    │   │   ├── entity/
    │   │   ├── repository/
    │   │   └── usecase/
    │   ├── data/
    │   │   ├── datasource/
    │   │   ├── mapper/
    │   │   └── repository/
    │   └── presentation/
    │       ├── bloc/
    │       ├── page/
    │       └── widget/
    ├── workout/                  운동 세션 기록 + 휴식 타이머
    │   └── (동일 구조)
    └── history/                  기록 히스토리 + 통계
        └── (동일 구조)
```

## 3. MVI 계약

```
        ┌──────── Intent ────────┐
        │                        ▼
     [View]                   [Bloc] ──▶ UseCase ──▶ Repository ──▶ Drift
        ▲                        │
        └──── State / Effect ────┘
```

### 3.1 구성 요소

| 요소 | 역할 | 규칙 |
|---|---|---|
| `Intent` | 사용자 의도 | sealed class. 명령형 이름 (`LoadTodayRoutine`, `CompleteSet`) |
| `State`  | 화면의 **전체** 상태 | immutable. `copyWith` 필수. 항상 단일 객체 |
| `Effect` | 1회성 부수효과 | 스낵바, 네비게이션, 진동 등. State에 넣지 않는다 |
| `Bloc`   | Intent → State 변환 | `MviBloc<Intent, State, Effect>` 상속 |

### 3.2 State 규칙

- 로딩/에러는 별도 State 클래스가 아니라 **단일 State의 필드**로 표현한다.
  ```dart
  class HomeState {
    final bool isLoading;
    final Failure? failure;
    final RoutineDay? todayDay;
    // ...
  }
  ```
  → 화면 전환 시 기존 데이터를 잃지 않고, 부분 로딩 표현이 가능하다.
- State는 `Equatable`을 구현한다. (불필요한 rebuild 방지)

### 3.3 Effect 규칙

- `Bloc`은 `emitEffect(...)`로 발행하고, View는 `BlocEffectListener`로 구독한다.
- 네비게이션·스낵바·햅틱은 **반드시** Effect로 처리한다. State에 `shouldNavigate` 같은 플래그를 두지 않는다.

### 3.4 View 규칙

- Widget은 `context.read<XBloc>().add(SomeIntent())` 로만 Bloc과 통신한다.
- Widget 안에서 UseCase나 Repository를 직접 호출하지 않는다.
- `BlocBuilder`의 `buildWhen`으로 rebuild 범위를 좁힌다.

## 4. 에러 처리

UseCase와 Repository는 예외를 던지지 않고 `Result<T>`를 반환한다.

```dart
sealed class Result<T> { const Result(); }
final class Ok<T> extends Result<T> { final T value; }
final class Err<T> extends Result<T> { final Failure failure; }
```

Data 계층에서 발생한 `DriftRemoteException` 등은 RepositoryImpl에서 잡아 `Failure`로 변환한다.

## 5. UseCase 규약

- 한 UseCase = 하나의 `call()` 메서드.
- 파라미터가 2개 이상이면 `XxxParams` 클래스를 만든다.
- 반환 타입은 `Future<Result<T>>` 또는 실시간 구독이면 `Stream<T>`.

```dart
@injectable
class GetTodayRoutineDay {
  final RoutineRepository _repository;
  GetTodayRoutineDay(this._repository);

  Future<Result<RoutineDay>> call() => _repository.getTodayDay();
}
```

## 6. 의존성 주입

- `get_it` + `injectable` (코드 생성).
- 등록 어노테이션: Repository 구현체는 `@LazySingleton(as: XRepository)`, UseCase/Bloc은 `@injectable`.
- Bloc은 `getIt<XBloc>()`으로 주입하며 `BlocProvider`에서 생성한다.

## 7. 코드 생성

```bash
dart run build_runner build --delete-conflicting-outputs
```

생성 대상: `injectable`(DI), `drift`(DB), `freezed`(선택).
생성 파일(`*.g.dart`, `*.freezed.dart`, `*.config.dart`)은 커밋한다.

## 8. 명명 규칙

| 대상 | 규칙 | 예 |
|---|---|---|
| 파일 | snake_case | `routine_day.dart` |
| Entity | 접미사 없음 | `RoutineDay` |
| Drift 테이블 | 복수형 | `RoutineDays` |
| Drift 생성 row | 자동 (`RoutineDayRow`) | `@DataClassName('RoutineDayRow')` |
| Mapper | `XMapper` 확장 함수 | `RoutineDayRow.toEntity()` |
| Repository 인터페이스 | `XRepository` | `RoutineRepository` |
| Repository 구현 | `XRepositoryImpl` | `RoutineRepositoryImpl` |
| Bloc | `XBloc` | `HomeBloc` |
| Intent | 동사구 | `StartSession`, `LogSet` |

## 9. 언어 정책

- 코드·식별자·주석: **영어**
- 사용자에게 보이는 문자열(라벨·안내문): **한국어**, `core/constants/app_strings.dart`에 모은다.

## 10. 커밋 규칙

Conventional Commits + 한국어 본문.

```
feat(routine): 루틴 편집 화면 구현

- 블록/종목 추가·삭제·순서변경 지원
- 슈퍼세트 묶기 UI 추가
```

타입: `feat` `fix` `refactor` `chore` `docs` `test` `style`
스코프: `core` `routine` `workout` `history` `db` `theme`
