import com.swisslog.gradle.config.*

plugins {
    id("polyglot3") version "[3, 4)"
}

configure<PolyglotExtension> {
    projects = listOf<PolyglotProject>(DockerImage(":core11", publishName = "dotnet11"))
    organization = "DevOps"
    repository = "dotnet11-rpm"
}
