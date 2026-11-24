import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseSigningPropertiesFile = rootProject.file("key.properties")
val releaseSigningProperties = Properties().apply {
    if (releaseSigningPropertiesFile.isFile) {
        releaseSigningPropertiesFile.inputStream().use { load(it) }
    }
}

fun releaseSigningValue(name: String): String? =
    releaseSigningProperties.getProperty(name)?.takeIf { it.isNotBlank() }
        ?: System.getenv(name)?.takeIf { it.isNotBlank() }

val requiredReleaseSigningKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
val releaseSigningValues = requiredReleaseSigningKeys.associateWith { releaseSigningValue(it) }
val missingReleaseSigningKeys = requiredReleaseSigningKeys.filter {
    releaseSigningValues[it].isNullOrBlank()
}
val releaseStoreFile = releaseSigningValues["storeFile"]?.let { rootProject.file(it) }
val releaseSigningProblem = when {
    missingReleaseSigningKeys.isNotEmpty() ->
        "Missing required release signing key(s): ${missingReleaseSigningKeys.joinToString()}."
    releaseStoreFile == null || !releaseStoreFile.isFile ->
        "The release signing storeFile does not exist or is not a file: ${releaseStoreFile?.path ?: "<unset>"}."
    else -> null
}
val releaseSigningConfigured = releaseSigningProblem == null

android {
    namespace = "com.dukaanai.mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.dukaanai.mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseSigningConfigured) {
            create("release") {
                storeFile = releaseStoreFile
                storePassword = releaseSigningValues["storePassword"]
                keyAlias = releaseSigningValues["keyAlias"]
                keyPassword = releaseSigningValues["keyPassword"]
            }
        }
    }

    buildTypes {
        release {
            if (releaseSigningConfigured) {
                signingConfig = signingConfigs.getByName("release")
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

val validateReleaseSigning by tasks.registering {
    group = "verification"
    description = "Fails release builds when production signing is not configured."

    doLast {
        if (!releaseSigningConfigured) {
            throw GradleException(
                """
                Release signing is not configured; release builds cannot be debug-signed.
                $releaseSigningProblem
                Configure storeFile, storePassword, keyAlias, and keyPassword in
                ${releaseSigningPropertiesFile.path} or as environment variables with those names.
                Relative storeFile paths are resolved from ${rootProject.projectDir}.
                """.trimIndent()
            )
        }
    }
}

tasks.matching { it.name == "preReleaseBuild" || it.name == "validateSigningRelease" }.configureEach {
    dependsOn(validateReleaseSigning)
}

