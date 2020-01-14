// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "XXNibBridge",
    platforms: [.iOS(.v8)],
    products: [
        .library(
            name: "XXNibBridge",
            type: .dynamic,
            targets: ["XXNibBridge"]
        )
    ],
    targets: [
        .target(
            name: "XXNibBridge",
            path: "XXNibBridge"
        )
    ]
)
