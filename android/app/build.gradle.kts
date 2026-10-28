import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseSigningProperties = Properties()
val releaseSigningPropertiesFile = rootProject.file("key.properties")
if (releaseSigningPropertiesFile.exists()) {
    releaseSigningPropertiesFile.inputStream().use(releaseSigningProperties::load)
}
val releaseSigningConfigured = releaseSigningPropertiesFile.exists()

android {
    namespace = "cn.quniv.audio_cut"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "cn.quniv.audio_cut"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 36
        ndk {
            abiFilters.clear()
            abiFilters.add("arm64-v8a")
        }
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Compress native libraries in the standalone website APK to reduce downloads.
    // This does not configure APKs generated from an App Bundle.
    packagingOptions {
        jniLibs {
            useLegacyPackaging = true
        }
    }

    if (releaseSigningConfigured) {
        signingConfigs {
            create("release") {
                val keystorePath = releaseSigningProperties.getProperty("storeFile")
                    ?: throw GradleException("Missing storeFile in android/key.properties")
                storeFile = rootProject.file(keystorePath)
                storePassword = releaseSigningProperties.getProperty("storePassword")
                    ?: throw GradleException("Missing storePassword in android/key.properties")
                keyAlias = releaseSigningProperties.getProperty("keyAlias")
                    ?: throw GradleException("Missing keyAlias in android/key.properties")
                keyPassword = releaseSigningProperties.getProperty("keyPassword")
                    ?: throw GradleException("Missing keyPassword in android/key.properties")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (releaseSigningConfigured) {
                signingConfigs.getByName("release")
            } else {
                null
            }
        }
    }
}

tasks.configureEach {
    if (name == "bundleRelease" || name == "assembleRelease") {
        doFirst {
            if (!releaseSigningConfigured) {
                throw GradleException(
                    "Release signing is not configured. Run tooling/android/create-upload-key.sh and keep its generated files private."
                )
            }
            val keystorePath = releaseSigningProperties.getProperty("storeFile")
                ?: throw GradleException("Missing storeFile in android/key.properties")
            if (!rootProject.file(keystorePath).isFile) {
                throw GradleException("Upload keystore not found: android/" + keystorePath)
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
