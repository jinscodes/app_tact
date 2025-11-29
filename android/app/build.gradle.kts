import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = file("key.properties")

val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    } else {
        throw GradleException("key.properties file not found: $keystorePropertiesFile")
    }
}

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}


android {
    namespace = "com.jay.app_sticky_note"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.jay.app_tact"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }

    signingConfigs {
        create("release") {
            keyAlias = requireNotNull(keystoreProperties["keyAlias"]?.toString()) { "keyAlias is missing in key.properties" }
            keyPassword = requireNotNull(keystoreProperties["keyPassword"]?.toString()) { "keyPassword is missing in key.properties" }
            storePassword = requireNotNull(keystoreProperties["storePassword"]?.toString()) { "storePassword is missing in key.properties" }
            storeFile = file(requireNotNull(keystoreProperties["storeFile"]?.toString()) { "storeFile is missing in key.properties" })
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

}

flutter {
    source = "../.."
}

dependencies {
  implementation(platform("com.google.firebase:firebase-bom:34.1.0"))
  implementation("com.google.firebase:firebase-analytics")
}
