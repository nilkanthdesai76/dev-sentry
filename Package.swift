// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DevSentry",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "DevSentry",
            targets: ["DevSentry"]
        ),
        .executable(
            name: "dev-sentry",
            targets: ["DevSentryCLI"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DevSentry",
            dependencies: [],
            path: "Sources/DevSentry"
        ),
        .executableTarget(
            name: "DevSentryCLI",
            dependencies: ["DevSentry"],
            path: "Sources/DevSentryCLI"
        ),
        .testTarget(
            name: "DevSentryTests",
            dependencies: ["DevSentry"],
            path: "Tests/DevSentryTests"
        )
    ]
)
