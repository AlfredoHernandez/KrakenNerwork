// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "KrakenNetwork",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(name: "KrakenNetwork", targets: ["KrakenNetwork"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "KrakenNetwork", dependencies: []),
        .testTarget(name: "KrakenNetworkTests", dependencies: ["KrakenNetwork"]),
    ]
)
