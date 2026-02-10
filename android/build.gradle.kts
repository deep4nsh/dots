// 1. Repository configuration FIRST
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 2. Build Directory
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// 3. Force Configuration on Subprojects
subprojects {
    // We use afterEvaluate to ensure we override any settings applied by the plugins or their build scripts
    afterEvaluate {
        // Only apply to Android projects
        if (project.plugins.hasPlugin("com.android.application") || 
            project.plugins.hasPlugin("com.android.library") || 
            project.plugins.hasPlugin("com.android.base")) {
            
            // Force JavaCompile tasks (overrides android.compileOptions)
            tasks.withType<JavaCompile>().configureEach {
                sourceCompatibility = JavaVersion.VERSION_17.toString()
                targetCompatibility = JavaVersion.VERSION_17.toString()
            }
            
            // Force Kotlin compile tasks
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                }
            }
        }
    }
}

// 4. Flutter Dependencies (Triggers evaluation)
subprojects {
    project.evaluationDependsOn(":app")
}

// 5. Clean Task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
