// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "scandit-datacapture-frameworks-id",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ScanditFrameworksId",
            targets: ["ScanditFrameworksId"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Scandit/scandit-datacapture-frameworks-core.git", exact: "8.1.0"),
        .package(url: "https://github.com/Scandit/datacapture-spm.git", exact: "8.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ScanditFrameworksId",
            dependencies: [
                .product(name: "ScanditFrameworksCore", package: "scandit-datacapture-frameworks-core"),
                .product(name: "ScanditIdCapture", package: "datacapture-spm"),
                .product(name: "ScanditIDC", package: "datacapture-spm"),
            ]
        ),
    ]
)
