plugins {
  // ...

  // Add the dependency for the Google services Gradle plugin
  id("com.google.gms.google-services") version "4.3.15" apply false

}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// This tells Android project: "Ignore version 1.11.0 and use version 1.9.3 instead."
subprojects {
    project.configurations.all {
        resolutionStrategy.eachDependency {
            // In Kotlin, we MUST use double quotes "" for strings
            if (requested.group == "androidx.activity" && requested.name.contains("activity")) {
                useVersion("1.9.3")
            }
        }
    }
}

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
