// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SQLiteStorage",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "SQLiteStorage", targets: ["SQLiteStorage"]),
        .library(name: "RxSQLiteStorage", targets: ["RxSQLiteStorage"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.2.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "SQLiteStorage", dependencies: []),
        .target(name: "RxSQLiteStorage", dependencies: ["SQLiteStorage", "RxSwift"]),
        .testTarget(name: "SQLiteStorageTests", dependencies: ["SQLiteStorage", "RxSQLiteStorage"]),
    ],
    swiftLanguageVersions: [.v5]
)
