allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

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

// Workaround for arcore_flutter_plugin relying on old Kotlin version
subprojects {
    project.configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "org.jetbrains.kotlin" && requested.name == "kotlin-gradle-plugin") {
                useVersion("1.7.10")
            }
        }
    }

    // Workaround for arcore_flutter_plugin missing namespace (required by AGP 8+)
    project.plugins.withId("com.android.library") {
        if (project.name == "arcore_flutter_plugin") {
            configure<com.android.build.gradle.LibraryExtension> {
                namespace = "com.difrancescogianmarco.arcore_flutter_plugin"
                compileSdk = 34
            }
        }
    }
}

// Workaround for arcore_flutter_plugin relying on old Kotlin version
subprojects {
    project.configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "org.jetbrains.kotlin" && requested.name == "kotlin-gradle-plugin") {
                useVersion("1.7.10")
            }
        }
    }

    // Workaround for arcore_flutter_plugin missing namespace (required by AGP 8+)
    project.plugins.withId("com.android.library") {
        if (project.name == "arcore_flutter_plugin") {
            configure<com.android.build.gradle.LibraryExtension> {
                namespace = "com.difrancescogianmarco.arcore_flutter_plugin"
                compileSdk = 34
            }
        }
    }
}
