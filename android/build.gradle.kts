// android/build.gradle.kts

// --- THE PATCH START ---
// This script automatically fixes the "Namespace" error for Isar 3
subprojects {
    afterEvaluate {
        val android = extensions.findByName("android")
        if (android != null) {
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                if (getNamespace.invoke(android) == null) {
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    setNamespace.invoke(android, group.toString())
                    println("AaharAI Patch: Fixed namespace for ${project.name}")
                }
            } catch (e: Exception) {
                // Ignore errors if method doesn't exist
            }
        }
    }
}
// --- THE PATCH END ---

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val project = this
    project.buildDir = File(newBuildDir.asFile, project.name)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}