# TrustallSDK

TrustallSDK is a powerful iOS SDK. The main entry point for TrustallSDK features.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [SDK Initialization](#sdk-initialization)
- [Error Handling](#error-handling)

---

## Requirements

| Item | Minimum Version |
|------|-----------------|
| iOS | 16.0+ |
| Xcode | 16.2+ |

---

## Installation

### Swift Package Manager

#### Xcode Project Integration

1. In Xcode, select **File > Add Package Dependency**
2. Enter the package URL: `https://github.com/Gogolook-Inc/trustall-ios-sdk`

#### Package.swift Integration

```swift
// Add TrustallSDK to dependencies
dependencies: [
    .package(url: "https://github.com/Gogolook-Inc/trustall-ios-sdk", .upToNextMajor(from: "1.0.0"))
]

// Add to target dependencies
.product(name: "TrustallSDK", package: "TrustallSDK")
```

---

## SDK Initialization

### 1. Create Configuration File

Add `Trustall-Info.plist` to every target that calls `Trustall.configure()` (main app and each extension). The parameterless `Trustall.configure()` loads **`Trustall-Info.plist` from the main bundle** (see `Bundle.main.url(forResource:withExtension:)`).

To use a **different file name or path**, construct `Trustall.Options(plistURL:)` and call `Trustall.configure(_:)`.

#### Plist configuration keys

Use a plist whose keys match the table below (see also `Trustall.configure()` and
the **Sample plist** section in the package README).

| Parameter | Type | Requirement | Description |
|-----------|------|-------------|-------------|
| `APP_GROUP_ID` | String | Always | App Group ID shared by the main app and extensions |
| `LICENSE_ID` | String | Always | License from Gogolook |
| `OFFLINE_DB_EXTENSION_BUNDLE_ID` | String | Conditionally required | Offline DB Call Directory extension; **required if you use offline DB** |
| `NUMBER_BLOCK_EXTENSION_BUNDLE_ID` | String | Conditionally required | Number Block Call Directory extension; **required if you use personal blocking** |
| `NUMBER_IDENTIFICATION_EXTENSION_BUNDLE_ID` | String | Conditionally required | Call Directory number identification; **required when that feature is enabled** |

### Sample plist

The table above is authoritative. Below is an **illustrative** plist with **placeholder** values only—replace them with your real App Group, license, and bundle IDs. Omit optional Call Directory keys for features you do not use. See [Plist configuration keys](#plist-configuration-keys).

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>APP_GROUP_ID</key>
        <string>group.com.example.myapp</string>
        <key>LICENSE_ID</key>
        <string>00000000-0000-4000-8000-000000000001</string>
        <!-- Optional: include only for features you enable -->
        <key>OFFLINE_DB_EXTENSION_BUNDLE_ID</key>
        <string>com.example.myapp.OfflineDB</string>
        <key>NUMBER_BLOCK_EXTENSION_BUNDLE_ID</key>
        <string>com.example.myapp.NumberBlock</string>
        <key>NUMBER_IDENTIFICATION_EXTENSION_BUNDLE_ID</key>
        <string>com.example.myapp.NumberIdentification</string>
    </dict>
</plist>
```

### Configure before calling SDK APIs

> **Warning:** Call `try Trustall.configure()` (or `Trustall.configure(_:)`) **before** any API that depends on **loaded SDK configuration**, **App Group–backed storage**, or **network** access. Do this in the **main app** and **each extension** (Call Directory, Message Filter, Safari Web Extension, etc.) at the earliest entry point (e.g. `App` `init` or the extension’s `init`).
>
> If configuration was never loaded successfully, the SDK may terminate the process with `fatalError`. Messages are implementation-defined but often relate to **configuration not loaded**, **App Group**, **license**, or **extension bundle ID** setup. **Do not** keep calling SDK APIs after a failed configure; log the error and avoid further SDK use in that process.

### 2. Initialize the SDK

Call `configure()` when your app launches:

```swift
import TrustallSDK

@main
struct YourApp: App {
    init() {
        do {
            try Trustall.configure()
        } catch {
            print("SDK initialization failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

#### Using Custom Configuration File Path

```swift
import TrustallSDK

let plistURL = Bundle.main.url(forResource: "CustomConfig", withExtension: "plist")
let options = try Trustall.Options(plistURL: plistURL)
try Trustall.configure(options)
```

> **Important:** The SDK must be initialized in **both** the main app and any extensions that use TrustallSDK. Each process loads its own bundle and needs its own `configure`.

### Initialization errors

`Trustall.Options.Error` only defines `missingPlistURL` (nil URL passed into `Options.init`). In practice, `Data(contentsOf:)` can throw **file system errors**, and `PropertyListDecoder` can throw **`DecodingError`** when the plist is **not a valid property list**, a **required** key is **missing**, or a **value’s type does not match** the expected decoding shape. **Conditionally required** keys (such as the Call Directory extension bundle IDs) **may be omitted** from the plist when you do not use those features—omitting them does not by itself cause a “missing key” decode failure. `Trustall.configure()` surfaces these errors as `Error`. Use a broad `catch`; do not assume you will only see `Trustall.Options.Error`.

---

## Error Handling

### General Error Handling Pattern

```swift
do {
    try Trustall.configure()
} catch {
    print("Error: \(error)")
}
```

Features that expose a public `*.Error` enum document cases under **Error Handling** in the matching `docs/*.md` file (for example `OfflineDB.md`, `NumberBlock.md`, `NumberIdentification.md`). Other modules usually surface standard `Error` values (e.g. network or decoding failures) via `throws`; use `catch` and refer to each feature’s API sections and prose in `docs/`.

---

## Support

For any questions or assistance, please contact the Gogolook technical support team.

