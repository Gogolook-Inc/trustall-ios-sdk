# TrustallSDK

TrustallSDK is a powerful iOS SDK. The main entry point for TrustallSDK features.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [SDK Initialization](#sdk-initialization)
- [Data Structures](#data-structures)
- [Error Handling](#error-handling)

---

## Requirements

| Item | Minimum Version |
|------|-----------------|
| iOS | 16.0+ |
| Xcode | 26.0+ |

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
    .package(url: "https://github.com/Gogolook-Inc/trustall-ios-sdk", .upToNextMajor(from: "2.0.1"))
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
| `NUMBER_BLOCK_EXTENSION_BUNDLE_ID` | String | Conditionally required | Number Block Call Directory extension; **required if you use number blocking** |
| `NUMBER_IDENTIFICATION_EXTENSION_BUNDLE_ID` | String | Conditionally required | Call Directory number identification; **required when that feature is enabled** |
| `LOG_LEVEL` | Int | Optional | SDK-internal log verbosity: `0`=off (default), `1`=error, `2`=warning, `3`=info |

`LOG_LEVEL` is a threshold, not an exact filter: each level also includes every level
listed before it. `2` (warning) shows both warnings and errors; `3` (info) shows
everything.

- `error`: an SDK operation did not complete — the caller receives a thrown error.
- `warning`: the SDK hit a condition worth a second look, whether or not the request
  the caller made still went through (e.g. a request was rejected and had to be
  retried, unexpectedly-shaped data came back from the server, or the configured
  license ID changed since the last launch).
- `info`: normal, expected SDK activity (e.g. a cached credential expired and was
  refreshed automatically). Useful while actively debugging an integration; too noisy
  to leave on otherwise.

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

### setDeviceID

`Trustall.setDeviceID(_ deviceID: String) throws`

Sets the ID the SDK uses to identify this device, replacing the one it generated itself.

Call this after `configure()`. The ID is stored in the App Group container, so the main app
and its extensions all use it. It is stored exactly as given.

Changing the ID signs the SDK out: the next request authenticates again with the new ID.
Passing the ID that is already set changes nothing, so it is safe to call on every launch.


#### Parameters (`setDeviceID`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `deviceID` | `String` | Yes | The ID to use. Must contain at least one non-whitespace character. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

```swift
try Trustall.configure()
try Trustall.setDeviceID(myAppUserDeviceID)
```

**Throws:** ``Error/emptyDeviceID`` if `deviceID` is empty or only whitespace. Nothing is changed in that case.

### Initialization errors

`Trustall.Options.Error` only defines `missingPlistURL` (nil URL passed into `Options.init`). In practice, `Data(contentsOf:)` can throw **file system errors**, and `PropertyListDecoder` can throw **`DecodingError`** when the plist is **not a valid property list**, a **required** key is **missing**, or a **value’s type does not match** the expected decoding shape. **Conditionally required** keys (such as the Call Directory extension bundle IDs) **may be omitted** from the plist when you do not use those features—omitting them does not by itself cause a “missing key” decode failure. `Trustall.configure()` surfaces these errors as `Error`. Use a broad `catch`; do not assume you will only see `Trustall.Options.Error`.

`Trustall.Error` is thrown by the setup methods above:

| Error | Description |
|-------|-------------|
| `emptyDeviceID` | `setDeviceID(_:)` was called with an empty or whitespace-only ID. |

---

## Data Structures

### NumberInfo.BusinessCategory

Identifies the type of business or entity associated with a number.

#### Fields

| Property | Type | Description |
|----------|------|-------------|
| `automobile` | `NumberInfo.BusinessCategory` |  |
| `bank` | `NumberInfo.BusinessCategory` |  |
| `beauty` | `NumberInfo.BusinessCategory` |  |
| `professional` | `NumberInfo.BusinessCategory` |  |
| `logistic` | `NumberInfo.BusinessCategory` |  |
| `education` | `NumberInfo.BusinessCategory` |  |
| `entertainment` | `NumberInfo.BusinessCategory` |  |
| `food` | `NumberInfo.BusinessCategory` |  |
| `government` | `NumberInfo.BusinessCategory` |  |
| `life` | `NumberInfo.BusinessCategory` |  |
| `health` | `NumberInfo.BusinessCategory` |  |
| `media` | `NumberInfo.BusinessCategory` |  |
| `organization` | `NumberInfo.BusinessCategory` |  |
| `others` | `NumberInfo.BusinessCategory` |  |
| `publicPerson` | `NumberInfo.BusinessCategory` |  |
| `personal` | `NumberInfo.BusinessCategory` |  |
| `pet` | `NumberInfo.BusinessCategory` |  |
| `politics` | `NumberInfo.BusinessCategory` |  |
| `shopping` | `NumberInfo.BusinessCategory` |  |
| `activity` | `NumberInfo.BusinessCategory` |  |
| `traffic` | `NumberInfo.BusinessCategory` |  |
| `travel` | `NumberInfo.BusinessCategory` |  |
| `rawValue` | `String` | The raw string value of the business category. |

#### Values

| Value | Description |
|-------|-------------|
| `.automobile` |  |
| `.bank` |  |
| `.beauty` |  |
| `.professional` |  |
| `.logistic` |  |
| `.education` |  |
| `.entertainment` |  |
| `.food` |  |
| `.government` |  |
| `.life` |  |
| `.health` |  |
| `.media` |  |
| `.organization` |  |
| `.others` |  |
| `.publicPerson` |  |
| `.personal` |  |
| `.pet` |  |
| `.politics` |  |
| `.shopping` |  |
| `.activity` |  |
| `.traffic` |  |
| `.travel` |  |

### NumberInfo.SpamCategory

Identifies the type of spam associated with a number.

#### Fields

| Property | Type | Description |
|----------|------|-------------|
| `top` | `NumberInfo.SpamCategory` |  |
| `telMarketing` | `NumberInfo.SpamCategory` |  |
| `callCenter` | `NumberInfo.SpamCategory` |  |
| `fraud` | `NumberInfo.SpamCategory` |  |
| `phishing` | `NumberInfo.SpamCategory` |  |
| `adult` | `NumberInfo.SpamCategory` |  |
| `illegal` | `NumberInfo.SpamCategory` |  |
| `harassment` | `NumberInfo.SpamCategory` |  |
| `oneRing` | `NumberInfo.SpamCategory` |  |
| `hfb` | `NumberInfo.SpamCategory` |  |
| `rawValue` | `String` | The raw string value of the spam category. |

#### Values

| Value | Description |
|-------|-------------|
| `.top` |  |
| `.telMarketing` |  |
| `.callCenter` |  |
| `.fraud` |  |
| `.phishing` |  |
| `.adult` |  |
| `.illegal` |  |
| `.harassment` |  |
| `.oneRing` |  |
| `.hfb` |  |

### NumberInfo.SpamLevel

Spam severity level.

#### Fields

| Property | Type | Description |
|----------|------|-------------|
| `unlikely` | `NumberInfo.SpamLevel` | Unlikely to be spam. |
| `suspicious` | `NumberInfo.SpamLevel` | Suspicious spam. |
| `confirmed` | `NumberInfo.SpamLevel` | Confirmed spam. |
| `rawValue` | `Int` | The raw integer value of the spam severity. |

#### Values

| Value | Description |
|-------|-------------|
| `.unlikely` | Unlikely to be spam. |
| `.suspicious` | Suspicious spam. |
| `.confirmed` | Confirmed spam. |

### NumberSearch.SearchFailure

A lookup with no successful result and at least one failed provider. `failures` is nonempty and ordered by attempt; normal notFound and cancellation are excluded.

#### Fields

| Property | Type | Description |
|----------|------|-------------|
| `failures` | `[NumberSearch.ProviderFailure]` |  |

### NumberSearch.ProviderFailure

A provider's original failure. The index refers to the lookup's configuration snapshot.

#### Fields

| Property | Type | Description |
|----------|------|-------------|
| `providerIndex` | `Int` |  |
| `providerName` | `String` | For human diagnostics, not a stable machine identifier. |
| `underlyingError` | `any Error` |  |

### TrustallNumberSearchProvider

Trustall's own number search source, backed by its network service.

### RemoteConfidenceLevelProvider

Trustall's own URL scan source, backed by its network service.

### URLScan.ScanFailure

A scan with no answer and at least one failed source. Failures are nonempty and ordered by attempt; normal `.unknown`, cache-read failures and cancellation are excluded.

#### Fields

| Property | Type | Description |
|----------|------|-------------|
| `failures` | `[URLScan.ProviderFailure]` |  |

### URLScan.ProviderFailure

A source's original error and its zero-based index in this scan's configuration snapshot.

#### Fields

| Property | Type | Description |
|----------|------|-------------|
| `providerIndex` | `Int` |  |
| `underlyingError` | `any Error` |  |

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

