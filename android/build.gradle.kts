import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import org.gradle.api.tasks.compile.JavaCompile
import org.gradle.jvm.toolchain.JavaLanguageVersion

// Ensure Google Services plugin is available for the app module.
// The classpath makes the plugin resolvable when applied in the app module.
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Keep Android Gradle Plugin entry compatible with your project.
        classpath("com.android.tools.build:gradle:8.1.2")
        // Google Services plugin required for google-services.json support.
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // Apply Java 11 settings to all sub-projects (replace older Java 8 usage)
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "11"
        targetCompatibility = "11"
        // If you want to suppress obsolete source/target warnings, consider
        // adding compilerArgs here, but setting compatibility to 11 should remove them.
    }

    tasks.withType<KotlinCompile>().configureEach {
        kotlinOptions {
            // compile Kotlin targeting JVM 11
            jvmTarget = "11"
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}