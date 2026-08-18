# 안드로이드 서명 키

> **왜 이 문서가 있나**: 2026-08-18, 빌드 한 번에 그날 운동 기록이 통째로 사라졌다.
> 원인은 코드가 아니라 서명 키였다. 같은 일이 다시 일어나지 않게 하는 방법이 여기 있다.

## 무슨 일이 있었나

`flutter run`이 깐 APK의 서명이 이미 깔려 있던 앱과 달랐다. 안드로이드는 이걸
**다른 앱**으로 보고 설치를 거부한다(`INSTALL_FAILED_UPDATE_INCOMPATIBLE`).
Flutter는 그러면 기존 앱을 **지우고** 새로 깐다.

앱을 지우면 `/data/user/0/com.shyang.workout_log`가 통째로 사라진다.
그 안에 `app_flutter/workout_log.sqlite`가 있다. 운동 기록 전부다.

증상 확인법 — 두 값이 같으면 업데이트가 아니라 새 설치다:

```bash
adb shell dumpsys package com.shyang.workout_log | grep -E "firstInstallTime|lastUpdateTime"
```

## 왜 서명이 달라졌나

`build.gradle.kts`가 release까지 **debug 키**로 서명하고 있었다.
debug 키(`~/.android/debug.keystore`)는 **컴퓨터마다 다르고**, 만료되면 새로 만들어진다.
이 저장소는 여러 컴퓨터에서 쓴다. A 컴퓨터에서 깐 앱 위에 B 컴퓨터에서 빌드해 깔면
그 순간 기록이 날아간다.

## 지금 구조

| 파일 | 역할 | git |
|---|---|---|
| `android/app/workout-log.jks` | 고정 서명 키. 유효기간 100년 | **올라가지 않음** |
| `android/key.properties` | 위 키의 경로·별칭·비밀번호 | **올라가지 않음** |
| `android/app/build.gradle.kts` | 두 파일을 읽어 debug·release 양쪽에 적용 | 올라감 |

`key.properties`가 **없으면** debug 키로 서명하고 Gradle 경고를 찍는다.
빌드는 되지만 위 사고가 다시 난다.

**debug 빌드에도 같은 키를 쓰는 게 핵심이다.** `flutter run`이 까는 건 debug 빌드고,
데이터를 지워 온 것도 그쪽이다.

## 다른 컴퓨터에서 빌드하려면

두 파일을 손으로 옮긴다. git에 없으니 clone만으로는 안 생긴다.

```
android/app/workout-log.jks
android/key.properties
```

USB·클라우드 드라이브·비밀번호 관리자 어디든 좋다. **저장소에는 넣지 않는다.**
넣으려면 저장소가 앞으로도 계속 비공개라는 확신이 있어야 하고,
Play 스토어에 올릴 계획이 생기면 그때 키를 갈아야 한다.

## 키를 잃어버리면

기존 설치본을 업데이트할 방법이 없다. 새 키로 만들면 그때 한 번 더 지워지고
기록도 함께 사라진다. **키 파일을 잃어버리는 것 = 그 시점의 운동 기록을 잃는 것**이다.

## 확인 명령

```bash
# APK가 어떤 키로 서명됐는지
"$LOCALAPPDATA/Android/Sdk/build-tools/36.1.0/apksigner.bat" verify --print-certs \
  build/app/outputs/flutter-apk/app-debug.apk

# 키 자체의 지문
"$JAVA_HOME/bin/keytool" -list -keystore android/app/workout-log.jks -alias workout-log
```

둘의 SHA-256이 같아야 한다. 현재 키: `66c43d4c2fd855e4…5644fe2d`

## 남아 있는 위험

- **기기 자동 백업이 꺼져 있다**(`adb shell bmgr enabled` → disabled).
  서명이 안정돼도 기기를 바꾸거나 앱을 직접 지우면 기록은 사라진다.
- 앱 안에 **운동 기록 내보내기 기능이 없다**. 루틴은 `.json`으로 뽑을 수 있지만
  세션·세트 기록은 못 뽑는다. 백업 수단이 사실상 없다는 뜻이다.
