// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/Package.swift#11 $
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
    ],
    dependencies: [],
    targets: [
        .target(name: "SwiftTrace", dependencies: ["SwiftTraceGuts"], path: "SwiftTrace/"),
        // Unfortunately not possible to use C++11 and have the target exportable
        .target(name: "SwiftTraceGuts", dependencies: [], path: "SwiftTraceGuts/"/*,
                cSettings: [.unsafeFlags(["-std=gnu++11"])]*/),
    ]
)
//-std\=gnu++11
