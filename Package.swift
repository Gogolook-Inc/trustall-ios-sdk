// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TrustallSDK",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(name: "TrustallSDK", targets: ["TrustallSDK_Aggregation"]),
    ],
    targets: [
        .target(
            name: "TrustallSDK_Aggregation",
            dependencies: [
                .target(name: "TrustallSDK"),
            ],
        ),
        .binaryTarget(
            name: "TrustallSDK",
            url: "https://github.com/Gogolook-Inc/trustall-ios-sdk/releases/download/1.0.0/TrustallSDK.xcframework.zip",
            checksum: "0bb9e2d09f2a5e6f30e1d86ac80d1b6bbafb1c1c548fd043d3b5200f3f02ee13"
        ),
    ]
)