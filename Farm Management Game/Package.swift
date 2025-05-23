// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FarmManagementGame",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FarmManagementGame",
            targets: ["FarmManagementGame"]
        )
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .target(
            name: "FarmManagementGame",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "FarmManagementGameTests",
            dependencies: ["FarmManagementGame"],
            path: "Tests"
        )
    ]
) 