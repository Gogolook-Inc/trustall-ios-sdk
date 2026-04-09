# Offline DB

Manages the offline number database for caller identification without network connectivity.

Download the database in the main app, then load it in a Call Directory Extension
to enable offline caller identification.

## API

| Method | Description |
|--------|-------------|
| `callDirectoryIsEnabled() async throws -> Bool` | Checks whether the Offline Database Call Directory extension is enabled. |
| `downloadOfflineDatabaseIfOutdated() async throws` | Downloads or updates the offline database if the current version is outdated. |
| `beginRequest(with context: CXCallDirectoryExtensionContext)` | Handles the Call Directory extension's request to load offline database entries. |
| `deleteLocalData() async throws` | Deletes all locally stored offline database data. |
| `reloadDirectoryExtension() async throws` | Reloads the Call Directory extension to apply database changes. |

### Download/Update Database

#### Return Value (`callDirectoryIsEnabled`)

`true` if the extension is enabled in Settings.

```swift
let trustall = Trustall()

Task {
    do {
        let isEnabled = try await trustall.offlineDB.callDirectoryIsEnabled()
        print("Extension enabled: \(isEnabled)")
    } catch {
        print("Failed: \(error)")
    }
}
```

```swift
let trustall = Trustall()

Task {
    do {
        try await trustall.offlineDB.downloadOfflineDatabaseIfOutdated()
        print("Database is up to date")
    } catch {
        print("Download failed: \(error)")
    }
}
```

### Load Database in Call Directory Extension

#### Parameters (`beginRequest`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `context` | `CXCallDirectoryExtensionContext` | Yes | The extension context provided by CallKit. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

### Clear Database

```swift
let trustall = Trustall()

do {
    try await trustall.offlineDB.deleteLocalData()
    print("Local data deleted")
} catch {
    print("Delete failed: \(error)")
}
```

## Extension Integration

```swift
import CallKit
import TrustallSDK

class CallDirectoryHandler: CXCallDirectoryProvider {
    let trustall: Trustall

    override init() {
        do {
            try Trustall.configure()
        } catch {
            print("SDK initialization failed: \(error)")
        }
        self.trustall = Trustall()
    }

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        trustall.offlineDB.beginRequest(with: context)
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext,
                       withError error: Error) {
        print("Request failed: \(error)")
    }
}
```

## Capabilities and setup

This feature typically relies on **App Groups** and **Call Directory** (CallKit). Enable matching capabilities on the main app and every extension target; align bundle IDs with `Trustall-Info.plist`.

- [Configuring app groups](https://developer.apple.com/documentation/xcode/configuring-app-groups)
- [CallKit](https://developer.apple.com/documentation/callkit)

## Error Handling

Errors that can occur during offline database operations.

| Error | Description |
|-------|-------------|
| `callDirectoryExtensionDisabled` | The Call Directory extension is not enabled in Settings. |
| `offlineDatabaseNotFound` | No offline database file found locally. |
| `reloadFailed` | The Call Directory extension reload failed. |

### reloadFailed

Possible underlying CallKit error codes:

| Code | Name | Description |
|------|------|-------------|
| 0 | unknown | An unknown Call Directory error occurred. |
| 1 | noExtensionFound | No Call Directory extension found. |
| 2 | loadingInterrupted | The Call Directory extension loading was interrupted. |
| 3 | entriesOutOfOrder | The Call Directory entries are out of order. |
| 4 | duplicateEntries | There are duplicate entries in the Call Directory. |
| 5 | maximumEntriesExceeded | There are too many entries in the Call Directory. |
| 6 | extensionDisabled | The Call Directory extension is not enabled. Please enable it in Settings. |
| 7 | currentlyLoading | The Call Directory extension is currently loading. Please try again later. |
| 8 | unexpectedIncrementalRemoval | An unexpected incremental removal occurred. |

