pluginManagement {
    repositories {
        maven {
            url = uri("https://nexus.swisslog.net/repository/css-group")
        }
    }
}

rootProject.name = "SLHC Dotnet Core 11"
include(":core11")
