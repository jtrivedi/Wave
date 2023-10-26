// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Wave",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "Wave",
            targets: ["Wave"])
    ],
    dependencies: [
        .package(url: "https://github.com/b3ll/Decomposed.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Wave",
            dependencies: ["Decomposed"]),
        .testTarget(
            name: "WaveTests",
            dependencies: ["Wave"])
    ]
)
