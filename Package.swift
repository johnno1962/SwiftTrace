// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftTrace",
    platforms: [.macOS("10.12"), .iOS("10.0")],
    products: [
        .library(name: "SwiftTrace", targets: ["SwiftTrace"]),
        .library(name: "SwiftTraceGuts", targets: ["SwiftTraceGuts"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "SwiftTrace", dependencies: ["SwiftTraceGuts"], path: "SwiftTrace/"),
        .target(name: "SwiftTraceGuts", dependencies: [], path: "SwiftTraceGuts/"),
    ]
)
