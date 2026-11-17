import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.compose)
}

// The Play Store upload key. It stays out of the project files: keystore/keystore.properties
// names the key file next to it and holds its passwords.
val uploadKey = rootProject.file("keystore/keystore.properties").takeIf { it.exists() }?.let { file ->
    Properties().apply { file.inputStream().use(::load) }
}

android {
    namespace = "dev.nefrin.wordsmap"
    compileSdk {
        version = release(37)
    }

    defaultConfig {
        // The id of the app on the Play Store. The code keeps its own package name (namespace).
        applicationId = "com.merlinict.wordmap"
        minSdk = 24
        targetSdk = 37
        // Raise versionCode by one for every upload to the Play Store.
        versionCode = 28
        versionName = "2.2.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    signingConfigs {
        if (uploadKey != null) {
            create("upload") {
                storeFile = rootProject.file("keystore/${uploadKey.getProperty("storeFile")}")
                storePassword = uploadKey.getProperty("storePassword")
                keyAlias = uploadKey.getProperty("keyAlias")
                keyPassword = uploadKey.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("upload")
            // Whole-app optimization. Limiting it to a few packages (the project template's
            // default) left the release build crashing on start with an IllegalAccessError.
            optimization {
                enable = true
            }
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    buildFeatures {
        compose = true
    }
    bundle {
        // The app has its own language setting, so every translation has to be installed,
        // not only the ones matching the phone's languages.
        language {
            enableSplit = false
        }
    }
}

dependencies {
    // The screens, data and content; this module only adds the activity and the splash screen.
    implementation(project(":shared"))
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.core.splashscreen)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.play.app.update)
    implementation(libs.androidx.fragment)
}