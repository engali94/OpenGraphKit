// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenGraphKit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "OpenGraphKit",
            targets: ["OpenGraphKit"]
        ),
    ],
    targets: [
        .target(
            name: "OpenGraphKit"),
        .testTarget(
            name: "OpenGraphKitTests",
            dependencies: ["OpenGraphKit"]),
    ]
)

package.dependencies.append(
  .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
)
