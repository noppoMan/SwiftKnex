// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftKnex",
    dependencies: [
        .package(url: "https://github.com/noppoMan/Prorsum.git", .exact("0.1.16"))
    ],
    targets: [
        .target(name: "Mysql", dependencies: ["Prorsum"]),
        .target(name: "SwiftKnex", dependencies: ["Mysql"]),
        .target(name: "SwiftKnexMigration", dependencies: ["SwiftKnex", "Mysql"])
    ]
)
