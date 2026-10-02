# Offline DB

Manages the offline number database for caller identification without network connectivity.

Download the database in the main app, then load it in a Call Directory Extension
to enable offline caller identification.

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `custom` | `CustomOfflineDB` | The offline database surface for a source you supply yourself. |
| `isTopSpamBlockingEnabled` | `Bool` | Indicates whether top spam numbers are configured to be blocked when loading the offline database. |

## API

| Method | Description |
|--------|-------------|
| `callDirectoryIsEnabled() async throws -> Bool` | Checks whether the Offline Database Call Directory extension is enabled. |
| `downloadOfflineDatabaseIfOutdated() async throws` | Downloads or updates the offline database if the current version is outdated. |
| `setTopSpamBlockingEnabled(_ enabled: Bool) async throws` | Updates whether top spam numbers from the offline database should be blocked, then reloads the Call Directory extension. |
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

#### Parameters (`setTopSpamBlockingEnabled`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `enabled` | `Bool` | Yes | `true` to block top spam numbers, `false` to stop blocking them. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

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

## CallerInfo

A caller-identification entry supplied to ``CustomOfflineDB`` by a ``CompleteOfflineDBProviding`` source.

Entries must be supplied in strictly increasing ``number`` order. Duplicate numbers are not
accepted because CallKit requires each complete entry set to be ordered and unique.


### Fields

| Property | Type | Description |
|----------|------|-------------|
| `number` | `Int64` | The phone number as a positive integer, including its country calling code. |
| `name` | `String` | The name CallKit displays for the phone number. |
| `autoBlock` | `Bool` | Whether this phone number is eligible for automatic blocking. |

## CompleteOfflineDBProviding

A source that streams a complete caller-identification entry set to ``CustomOfflineDB``.

A provider is created inside the Call Directory Extension process and passed directly to
``CustomOfflineDB/beginRequest(with:provider:)``. It replaces Trustall's built-in offline database
for that request; the two sources are never merged and there is no fallback source.

The callback is intentionally non-escaping. Produce one entry, await the callback, and only
then produce the next entry. This provides backpressure without building the complete database
in memory.

```swift
struct MyOfflineDBProvider: CompleteOfflineDBProviding {
    func provideCompleteIdentificationEntries(
        onNextValue: (CallerInfo) async throws -> Void
    ) async throws {
        // Your own data source, read in strictly increasing number order.
        // Throwing anywhere aborts the request; CallKit keeps the last data that loaded.
        let store = try MyCallerStore.open()
        for record in store.recordsSortedByNumber() {
            // Await each entry before producing the next one.
            try await onNextValue(
                CallerInfo(number: record.number, name: record.name, autoBlock: record.isSpam)
            )
        }
    }
}
```


### Requirements

Implement these to conform to `CompleteOfflineDBProviding`.

| Method | Description |
|--------|-------------|
| `provideCompleteIdentificationEntries(onNextValue: (CallerInfo) async throws -> Void) async throws` | Streams the complete entry set in strictly increasing phone-number order. |

#### `provideCompleteIdentificationEntries`

Streams the complete entry set in strictly increasing phone-number order.

Call `onNextValue` serially, exactly once for each entry. Every number must be positive
and unique. Do not retain the callback or invoke it concurrently.

Names are passed to CallKit verbatim, including an empty string. Every entry is added for
caller identification. An entry whose `autoBlock` is `true` is also added for blocking while
``CustomOfflineDB/isAutomaticBlockingEnabled`` is enabled. Automatic blocking is enabled by
default.

An empty stream is valid and replaces the extension's previous data with an empty set.
Throwing aborts the complete request; CallKit keeps the last successfully loaded data.

## CustomOfflineDB

Loads the Call Directory extension from a caller information source you supply, instead of from Trustall's built-in offline database.

Reach this type through `Trustall().offlineDB.custom`. The two sources are alternatives, not
layers: a request served from here never reads the built-in database, and the enable check,
blocking preference and reload on this type never require that database to exist.

```swift
let trustall = Trustall()

// In the main app.
try await trustall.offlineDB.custom.setAutomaticBlockingEnabled(false)

// In the Call Directory Extension.
trustall.offlineDB.custom.beginRequest(with: context, provider: MyOfflineDBProvider())
```


### Fields

| Property | Type | Description |
|----------|------|-------------|
| `isAutomaticBlockingEnabled` | `Bool` | Indicates whether entries marked for automatic blocking are blocked. |

### Methods

| Method | Description |
|--------|-------------|
| `callDirectoryIsEnabled() async throws -> Bool` | Checks whether the Offline Database Call Directory extension is enabled. |
| `setAutomaticBlockingEnabled(_ enabled: Bool) async throws` | Updates whether entries marked for automatic blocking are blocked, then reloads the Call Directory extension. |
| `reloadDirectoryExtension() async throws` | Reloads the Call Directory extension so it asks your provider for entries again. |
| `beginRequest(with context: CXCallDirectoryExtensionContext, provider: any CompleteOfflineDBProviding)` | Handles a Call Directory Extension request using one custom entry provider. |

#### `callDirectoryIsEnabled`

Checks whether the Offline Database Call Directory extension is enabled.

This is the same extension the built-in database uses; enabling it in Settings is a user
action either way.


#### Return Value (`callDirectoryIsEnabled`)

`true` if the extension is enabled in Settings.

```swift
let trustall = Trustall()

Task {
    do {
        let isEnabled = try await trustall.offlineDB.custom.callDirectoryIsEnabled()
        print("Extension enabled: \(isEnabled)")
    } catch {
        print("Failed: \(error)")
    }
}
```

#### `setAutomaticBlockingEnabled`

Updates whether entries marked for automatic blocking are blocked, then reloads the Call Directory extension.

Turning this setting on requires the Call Directory extension to be enabled. Turning it off
does not require the extension to be enabled; if the extension is disabled, the preference
is still saved and applied later when the extension is re-enabled.

Trustall's built-in offline database is never consulted here, so this works whether or not
that database has been downloaded.

- Important: The stored setting is enabled by default on a fresh installation.

- Note: This writes the same persisted preference as
  ``OfflineDB/setTopSpamBlockingEnabled(_:)``. It does not touch the built-in database's own
  reload command, which a custom source never reads.


#### Parameters (`setAutomaticBlockingEnabled`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `enabled` | `Bool` | Yes | `true` to apply automatic blocking, `false` to load identification only. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

```swift
let trustall = Trustall()

Task {
    do {
        try await trustall.offlineDB.custom.setAutomaticBlockingEnabled(false)
    } catch {
        print("Failed: \(error)")
    }
}
```

#### `reloadDirectoryExtension`

Reloads the Call Directory extension so it asks your provider for entries again.

Call this after the data behind your provider changes. Trustall's built-in offline database
is never consulted, so this works whether or not that database has been downloaded.


```swift
let trustall = Trustall()

Task {
    do {
        try await trustall.offlineDB.custom.reloadDirectoryExtension()
    } catch {
        print("Reload failed: \(error)")
    }
}
```

#### `beginRequest`

Handles a Call Directory Extension request using one custom entry provider.

This replaces Trustall's built-in offline database for this request. It does not read,
merge, or fall back to the built-in database. Configure Trustall and create the provider
inside the Call Directory Extension process, then call exactly one `beginRequest` per
context — either this one or ``OfflineDB/beginRequest(with:)``, never both.

The provider is consumed once using a complete reload. Its entries are passed to CallKit as
they arrive, so the SDK does not retain the complete database in memory. Every entry is added
for caller identification. Entries with `autoBlock` set to `true` are also added for blocking
while ``isAutomaticBlockingEnabled`` is enabled. Automatic blocking is enabled by default.

- Parameters:
  - context: The extension context provided by CallKit.
  - provider: The single source of the complete, sorted caller information set.


```swift
final class CallDirectoryHandler: CXCallDirectoryProvider {
    private let trustall: Trustall
    private let provider: MyOfflineDBProvider

    override init() {
        do {
            try Trustall.configure()
        } catch {
            print("SDK initialization failed: \(error)")
        }
        self.trustall = Trustall()
        self.provider = MyOfflineDBProvider()
    }

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        trustall.offlineDB.custom.beginRequest(with: context, provider: provider)
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
| `invalidCallerInfoNumber` | A custom provider supplied a non-positive phone number. |
| `duplicateCallerInfoNumber` | A custom provider supplied the same phone number more than once. |
| `callerInfoEntriesOutOfOrder` | A custom provider supplied a phone number smaller than the preceding number. |
| `providerFailed` | A custom provider failed while producing its caller information. |
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

