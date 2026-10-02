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
            url: "https://github.com/Gogolook-Inc/trustall-ios-sdk/releases/download/2.0.0/TrustallSDK.xcframework.zip",
            checksum: "116ecc5e8907bf66b9db5e599e299d49d656212159396893bc54eb9557a3a22e"
        ),
    ]
)