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
            url: "https://github.com/Gogolook-Inc/trustall-ios-sdk/releases/download/2.0.1/TrustallSDK.xcframework.zip",
            checksum: "0bfd94e30b587e4401dde6ae1b69c4e42bcbeed09324444cece09a0af207a326"
        ),
    ]
)