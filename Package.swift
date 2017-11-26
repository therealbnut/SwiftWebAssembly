// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftWebAssembly",
    products: [
        .library(
            name: "SwiftWebAssembly",
            targets: ["SwiftWebAssembly"]),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftWebAssembly",
            dependencies: [
                "JavaScriptCoreHelpers",
            ]),
        .target(
            name: "JavaScriptCoreHelpers",
            dependencies: []),
        .target(
            name: "JavaScriptCoreTestHelpers",
            dependencies: []),
        .testTarget(
            name: "SwiftWebAssemblyTests",
            dependencies: [
                "SwiftWebAssembly",
                 "JavaScriptCoreHelpers",
                 "JavaScriptCoreTestHelpers",
            ]),
    ]
)
