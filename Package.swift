// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RipCat",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "RipCatCore", targets: ["RipCatCore"]),
        .executable(name: "ripcat", targets: ["ripcat-cli"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "RipCatCore",
            dependencies: [],
            path: "Sources/RipCatCore"
        ),
        .executableTarget(
            name: "ripcat-cli",
            dependencies: [
                "RipCatCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/ripcat-cli"
        ),
    ]
)
