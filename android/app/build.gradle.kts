import java.util.Properties

// Signing identity, read from android/key.properties.
//
// Android treats a signature change as a different app: it uninstalls the old
// one before installing, and app-private data — the whole workout history —
// goes with it. The per-machine debug key makes that happen every time the APK
// comes from a different computer, so the key lives in a file instead.
val signingProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val hasStableKey = signingProperties.getProperty("storeFile") != null

if (!hasStableKey) {
    logger.warn(
        "android/key.properties가 없어 debug 키로 서명합니다. " +
            "다른 컴퓨터에서 만든 설치본 위에 깔면 앱이 지워지고 운동 기록도 함께 사라집니다.",
    )
}

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.shyang.workout_log"
    // receive_sharing_intent requires API 37; Flutter's default is still 36.
    // Compiling against a newer SDK does not change runtime behaviour —
    // targetSdk and minSdk stay where Flutter puts them.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications for zonedSchedule().
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.shyang.workout_log"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasStableKey) {
            create("workoutLog") {
                storeFile = file(signingProperties.getProperty("storeFile"))
                storePassword = signingProperties.getProperty("storePassword")
                keyAlias = signingProperties.getProperty("keyAlias")
                keyPassword = signingProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        // debug too, not just release: `flutter run` installs the debug build,
        // so that is the one that has been wiping the database.
        val stable = if (hasStableKey) {
            signingConfigs.getByName("workoutLog")
        } else {
            signingConfigs.getByName("debug")
        }
        debug {
            signingConfig = stable
        }
        release {
            signingConfig = stable
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
