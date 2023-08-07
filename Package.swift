// swift-tools-version: 5.6

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .define("CORE_SWIFT_LINK_FOUNDATION"),
]

let package = Package(
    name: "CoreSwift",
    products: [
        .library(
            name: "CoreCxx",
            targets: ["CoreCxx"]),
        .library(
            name: "CoreSwift",
            targets: ["CoreSwift"]),
        .library(
            name: "CoreIOKit",
            targets: ["CoreIOKit"]),
        .library(
            name: "CoreFilesystem",
            targets: ["CoreFilesystem"]),
    ],
    dependencies: [
        // CoreSwift designed has no any dependencies.
    ],
    targets: [
        .target(
            name: "CoreCxx"),
        .target(
            name: "CoreCxxInternal",
            dependencies: ["CoreCxx"]),
        .target(
            name: "CoreSwift",
            dependencies: ["CoreCxxInternal"],
            swiftSettings: swiftSettings),
        .target(
            name: "CoreIOKit",
            dependencies: [
                "CoreSwift",
                "CoreCxxInternal"
            ],
            swiftSettings: swiftSettings),
        .target(
            name: "CoreFilesystem",
            dependencies: [
                "CoreIOKit",
                "CoreSwift",
                "CoreCxxInternal"
            ],
            swiftSettings: swiftSettings),
        .testTarget(
            name: "CoreSwiftTests",
            dependencies: ["CoreSwift"]),
        .testTarget(
            name: "CoreFilesystemTests",
            dependencies: ["CoreFilesystem"]),
    ]
)
