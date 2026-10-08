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
            url: "https://github.com/Gogolook-Inc/trustall-ios-sdk/releases/download/2.0.2/TrustallSDK.xcframework.zip",
            checksum: "a183fc36d83fa3b734fe942f1c78866de0f75c1216028f21cbe42744f2c16ea5"
        ),
    ]
)