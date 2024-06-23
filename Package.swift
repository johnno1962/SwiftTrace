// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/Package.swift#14 $
//

import PackageDescription

let package = Package(
    name: "SwiftTrace",
    platforms: [.macOS("10.12"), .iOS("10.0")],
    products: [
        // SwiftTrace needs to be .dynamic for
        // the trampolines to work on Intel.
        .library(name: "SwiftTrace", type: .dynamic, targets: ["SwiftTrace"]),
        .library(name: "SwiftTraceGuts", type: .dynamic, targets: ["SwiftTraceGuts"]),
        .library(name: "SwiftTraceD", type: .dynamic, targets: ["SwiftTraceD"]),
        .library(name: "SwiftTraceGutsD", type: .dynamic, targets: ["SwiftTraceGutsD"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "SwiftTrace", dependencies: ["SwiftTraceGuts"], path: "SwiftTrace/"),
        .target(name: "SwiftTraceGuts", dependencies: [], path: "SwiftTraceGuts/"),
        .target(name: "SwiftTraceD", dependencies: ["SwiftTraceGutsD"],
                path: "SwiftTraceD/", swiftSettings: [.define("DEBUG_ONLY")]),
        .target(name: "SwiftTraceGutsD", dependencies: [],
                path: "SwiftTraceGutsD/", cSettings: [.define("DEBUG_ONLY")]),
    ],
    cxxLanguageStandard: .cxx11
)
