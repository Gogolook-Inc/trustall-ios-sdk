# TrustallSDK

TrustallSDK iOS SDK

- [Usage](#Usage)
- [Installation](#Installation)
- [Required](#Required)

## Usage
``` swift
import TrustallSDK
```

## Installation
### Swift Package Manager
#### Xcode Project
1. File > Swift Packages > Add Package Dependency
2. Add https://github.com/Gogolook-Inc/trustall-ios-sdk
#### Package.swift
```swift
// ...
// Add TrustallSDK as a dependency
dependencies: [
    .package(url: "https://github.com/Gogolook-Inc/trustall-ios-sdk", .upToNextMajor(from: "0.6.6"))
]
// ...
// Add TrustallSDK to your target
.product(name: "TrustallSDK", package: "TrustallSDK")
```
### CocoaPods
``` ruby
pod "TrustallSDK", :git => "https://github.com/Gogolook-Inc/trustall-ios-sdk", :tag => "0.6.6"
```

## Required
- iOS 16+
- Xcode 16.2+