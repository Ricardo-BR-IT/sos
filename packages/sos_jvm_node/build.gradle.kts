plugins {
    kotlin("jvm") version "1.9.0"
}

group = "com.sos"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
    implementation("org.jmdns:jmdns:3.5.8")
}

kotlin {
    jvmToolchain(17)
}
