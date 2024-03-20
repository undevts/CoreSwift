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
            name: "CoreSystem",
            targets: ["CoreSystem"]),
        .library(
            name: "CoreIOKit",
            targets: ["CoreIOKit"]),
        .library(
            name: "CoreFilesystem",
            targets: ["CoreFilesystem"]),
        .library(
            name: "CoreEnvironment",
            targets: ["CoreEnvironment"]),
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
            name: "CoreSystem",
            dependencies: [
                "CoreSwift"
            ],
            swiftSettings: swiftSettings),
        .target(
            name: "CoreIOKit",
            dependencies: [
                "CoreSystem",
                "CoreCxxInternal"
            ],
            swiftSettings: swiftSettings),
        .target(
            name: "CoreFilesystem",
            dependencies: [
                "CoreIOKit",
            ],
            path: "Sources/CoreFilesystems",
            swiftSettings: swiftSettings),
        .target(
            name: "CoreEnvironment",
            dependencies: [
                "CoreFilesystem"
            ],
            swiftSettings: swiftSettings),
        .testTarget(
            name: "CoreSwiftTests",
            dependencies: ["CoreSwift"]),
        .testTarget(
            name: "CoreFilesystemTests",
            dependencies: ["CoreFilesystem", "CoreEnvironment"],
            path: "Tests/CoreFilesystemTest"),
    ],
    cxxLanguageStandard: .cxx20
)
