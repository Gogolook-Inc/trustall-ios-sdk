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
            url: "https://github.com/Gogolook-Inc/trustall-ios-sdk/releases/download/0.7.1/TrustallSDK.xcframework.zip",
            checksum: "5c097957e0f3bd7e232042eee6befa42b23deb119775afd452d5e94da8411837"
        ),
    ]
)