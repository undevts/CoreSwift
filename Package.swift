// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "CoreSwift",
    products: [
        .library(
            name: "CoreCxx",
            targets: ["CoreCxx"]),
        .library(
            name: "CoreSwift",
            targets: ["CoreSwift"]),
    ],
    dependencies: [
        // CoreSwift designed has no any dependencies.
    ],
    targets: [
        .target(
            name: "CoreCxx"),
        .target(
            name: "CoreSwift"),
        .testTarget(
            name: "CoreSwiftTests",
            dependencies: ["CoreSwift"]),
    ]
)
