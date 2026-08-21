# iOS 빌드

> 이 저장소는 Windows에서 개발되고 있어 **여기서는 iOS를 빌드할 수 없다.**
> 이 문서는 맥에서 클론했을 때 바로 빌드가 되도록 미리 해둔 설정과,
> 맥에서만 할 수 있어 남겨둔 일을 구분해 적어둔 것이다.

## 요약

| | |
|---|---|
| Bundle ID | `com.shyang.workoutLog` (안드로이드 `com.shyang.workout_log` — iOS는 `_`를 못 쓴다) |
| 표시 이름 | `Workout Log` |
| 최소 버전 | iOS 13.0 — 플러그인 4종이 모두 요구하는 값이다. 내리면 빌드가 깨진다 |
| 의존성 방식 | Swift Package Manager (Flutter 3.44 stable 기본값). CocoaPods `Podfile`은 없다 |
| App Group | `group.com.shyang.workoutLog` |

## 맥에서 처음 받았을 때

```bash
flutter pub get
dart run build_runner build
flutter build ios --debug --no-codesign   # 서명 없이 컴파일만 확인
```

실기기에 올리려면 Xcode에서 팀만 정해주면 된다.

```bash
open ios/Runner.xcworkspace
# Runner 타깃 → Signing & Capabilities → Team 선택 (Automatically manage signing)
flutter run
```

`flutter build ipa`로 앱스토어에 올릴 때는 팀·프로비저닝이 잡혀 있어야 한다.

## 미리 해둔 것

- `ios/` 전체 (`flutter create --platforms=ios --org com.shyang`)
- **알림** — `AppDelegate.swift`에 `UNUserNotificationCenter.current().delegate` 지정.
  이게 없으면 앱이 떠 있는 동안 휴식 완료 알림이 조용히 사라진다.
  `RestNotifier`는 `DarwinInitializationSettings`로 iOS 권한 요청을 **초기화 시점에서 떼어냈고**,
  안드로이드와 같이 운동 시작 시 `ensurePermissions()`에서 묻는다.
- **아이콘** — `flutter_launcher_icons`의 `ios: true`. iOS는 아이콘에 알파를 허용하지 않아
  `remove_alpha_ios` + `background_color_ios: #12151A`로 안드로이드 어댑티브 배경과 맞췄다.
  아이콘을 바꾸려면 `tools/generate_icon.py` → `dart run flutter_launcher_icons` 순서 그대로다.
- **공유 받기 배선의 절반** — `Info.plist`의 `AppGroupId`, `CFBundleURLTypes`
  (`ShareMedia-$(PRODUCT_BUNDLE_IDENTIFIER)`), `ios/Flutter/*.xcconfig`의 `CUSTOM_GROUP_ID`.
- **App Store 업로드용** — `ITSAppUsesNonExemptEncryption = false`.
  자체 암호화가 없으므로 업로드마다 수출규정 질문을 받지 않는다.

## 맥에서만 할 수 있는 일

### 1. 루틴 파일 공유 받기 (Share Extension)

**이걸 안 해도 앱은 빌드되고 동작한다.** 다른 앱에서 `.json`을 *공유*해 넣는 경로만 빠진다.
앱 안에서 `루틴 목록 → 가져오기`로 파일을 고르는 경로는 `flutter_file_dialog`가 처리하므로
설정 없이 동작한다.

`receive_sharing_intent`는 iOS에서 별도 익스텐션 타깃을 요구하고, 타깃 추가는 Xcode에서만 된다.
필요한 파일은 `ios/ShareExtension/`에 미리 써뒀다. 순서:

1. Xcode → File → New → Target → **Share Extension**, 이름 `ShareExtension`.
   "Activate scheme?"은 취소해도 된다.
2. Xcode가 만든 `Info.plist` · `ShareViewController.swift`를 `ios/ShareExtension/`의 것으로 교체.
   같이 생긴 `MainInterface.storyboard`는 지운다 (자동 리다이렉트라 UI가 없다).
3. **Runner와 ShareExtension 양쪽** Signing & Capabilities에 `App Groups` 추가 →
   `group.com.shyang.workoutLog`. ShareExtension 쪽 entitlements는
   `ios/ShareExtension/ShareExtension.entitlements`에 그대로 있다.
4. **양쪽** Build Settings에 User-Defined `CUSTOM_GROUP_ID` = `group.com.shyang.workoutLog`.
   Runner는 `ios/Flutter/*.xcconfig`가 이미 넣어주므로 ShareExtension만 추가하면 된다.
5. ShareExtension 타깃 → General → Frameworks and Libraries → `receive-sharing-intent` 추가.
6. Runner 타깃 → Build Phases에서 `Embed Foundation Extension`을 `Thin Binary` **위로** 옮긴다.
   (안 옮기면 `No such module 'receive_sharing_intent'`)
7. 두 타깃의 Deployment Target을 **13.0으로 동일하게** 맞춘다.

익스텐션은 `.json` 파일 하나만 받는다(`NSExtensionActivationSupportsFileWithMaxCount = 1`).
사진·URL·텍스트는 일부러 claim하지 않는다 — 안드로이드에서 `*/*` 대신 `application/json`만
잡은 것과 같은 이유로, 온갖 공유 시트에 Workout Log가 끼어들지 않게 하기 위해서다.

### 2. 휴식 알림을 Focus 모드까지 뚫고 싶을 때

지금은 `InterruptionLevel.active`다. 집중 모드가 켜져 있으면 알림이 미뤄질 수 있다.
`timeSensitive`로 올리려면 Apple Developer 계정에서
**Time Sensitive Notifications** capability를 켜고 프로비저닝 프로파일을 다시 받아야 한다.
그 전에 코드만 바꾸면 서명이 실패한다. `lib/core/notification/rest_notifier.dart`의
`DarwinNotificationDetails`가 바꿀 자리다.

## 안드로이드와 달라지는 지점

| | Android | iOS |
|---|---|---|
| 알림 권한 | `POST_NOTIFICATIONS`(운동 시작 시 요청) + `USE_EXACT_ALARM`(설치 시 부여, 프롬프트 없음) | alert·sound를 운동 시작 시 요청 (badge는 안 쓴다) |
| 예약 방식 | `AlarmManager` exact → inexact 폴백 | `UNCalendarNotificationTrigger`. 폴백 개념이 없다 |
| 알림을 실제로 띄우는 주체 | `AndroidManifest.xml`에 직접 선언한 `ScheduledNotificationReceiver`. **빠뜨리면 예약은 되는데 조용하다** (`docs/03-STEPS.md` STEP 9) | `UNUserNotificationCenter`. 받는 쪽을 선언할 필요가 없어 이 함정이 없다 — `AppDelegate.swift`의 delegate 지정이 전부다 |
| 파일 공유 받기 | `AndroidManifest.xml`의 intent-filter | Share Extension (위 참조) |
| 파일 고르기 | SAF | `UIDocumentPickerViewController` — 둘 다 `flutter_file_dialog` |
| DB 경로 | `path_provider` | 같음. `path_provider_foundation`은 순수 Dart(FFI)라 등록이 필요 없다 |

DB 파일명 `workout_log.sqlite`는 플랫폼과 무관하게 같다. 다만 **iOS와 안드로이드는 서로 다른 앱**
이므로 기록이 넘어가지 않는다. 옮기려면 루틴 내보내기/가져오기처럼 별도 경로가 필요하다
(`docs/03-STEPS.md`의 "데이터 백업/복원" 후보).

## 손대면 깨지는 것

| 대상 | 이유 |
|---|---|
| `IPHONEOS_DEPLOYMENT_TARGET = 13.0` | `flutter_local_notifications` · `flutter_file_dialog` · `receive_sharing_intent` · `share_plus`가 모두 13.0을 요구한다 |
| `ios/Runner/SceneDelegate.swift` | Flutter 3.44의 UIScene 생명주기. 지우면 공유로 들어온 URL이 앱에 전달되지 않는다 |
| `Info.plist`의 `CFBundleURLTypes` | 익스텐션이 앱으로 돌아오는 유일한 통로. 스킴 접두사는 플러그인이 고정한 값이다 |
| Bundle ID `com.shyang.workoutLog` | 안드로이드 `applicationId`와 같은 이유 — 바꾸면 기존 설치본의 기록이 끊긴다 |
