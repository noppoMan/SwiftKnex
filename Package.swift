import PackageDescription

let package = Package(
    name: "SwiftKnex",
    targets: [
        Target(name: "Mysql"),
        Target(name: "SwiftKnex", dependencies: ["Mysql"]),
        Target(name: "SwiftKnexMigration", dependencies: ["SwiftKnex", "Mysql"])
    ],
    dependencies: [
        .Package(url: "https://github.com/noppoMan/Prorsum.git", majorVersion: 0, minor: 1)
    ]
)
