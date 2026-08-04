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
            resources: [
                .copy("PrivacyInfo.xcprivacy"),
            ],
        ),
        .binaryTarget(
            name: "TrustallSDK",
            url: "https://github.com/Gogolook-Inc/trustall-ios-sdk/releases/download/1.1.9/TrustallSDK.xcframework.zip",
            checksum: "f5b4f878d3b011e922ec44545291c2b948b5cc2b5c4449108fef8bb6affd08bf"
        ),
    ]
)