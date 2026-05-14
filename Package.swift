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
            url: "https://github.com/Gogolook-Inc/trustall-ios-sdk/releases/download/1.1.2/TrustallSDK.xcframework.zip",
            checksum: "7ff3c457ae4511aa9acacb243e9fe0ccdf14fa9f48158d6aaeecd190337abfd1"
        ),
    ]
)