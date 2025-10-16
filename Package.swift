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
        .package(path: "../scandit-datacapture-frameworks-core"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ScanditFrameworksId",
            dependencies: [
                .product(name: "ScanditFrameworksCore", package: "scandit-datacapture-frameworks-core"),
                "ScanditIdCapture",
                "ScanditIDC"
            ]
        ),
        .binaryTarget(
            name: "ScanditIdCapture",
            path: "Frameworks/ScanditIdCapture.xcframework"
        ),
        .binaryTarget(
            name: "ScanditIDC",
            path: "Frameworks/ScanditIDC.xcframework"
        ),
    ]
)
