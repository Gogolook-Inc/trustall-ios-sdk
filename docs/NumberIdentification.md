# Number Identification

Manages number identification by storing queried number information locally for display during incoming calls.

## API

| Method | Description |
|--------|-------------|
| `identifiedNumbers() async throws -> [String]` | Returns the list of currently identified phone numbers. |
| `callDirectoryIsEnabled() async throws -> Bool` | Checks whether the Number Identification Call Directory extension is enabled. |
| `addNumber(numberInfo: NumberInfo) async throws` | Adds a number to the number identification list. |
| `removeNumber(_ e164: CXCallDirectoryPhoneNumber) async throws` | Removes a number from the number identification list. |
| `beginRequest(with context: CXCallDirectoryExtensionContext)` | Handles the Call Directory extension's request to load the identification list. |

### List identified phone numbers

#### Return Value (`identifiedNumbers`)

An array of identified phone number strings.

```swift
let trustall = Trustall()

Task {
    do {
        let numbers = try await trustall.numberIdentification.identifiedNumbers()
        print("Identified numbers: \(numbers)")
    } catch {
        print("Failed: \(error)")
    }
}
```

### Number Identification Call Directory extension status

### Add number to identification list

#### Parameters (`addNumber`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `numberInfo` | `NumberInfo` | Yes | The number information to add (for example from ``NumberSearch/searchNumber(e164:)``). |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

```swift
let trustall = Trustall()

Task {
    do {
        let info = try await trustall.numberSearch.searchNumber(e164: "+886912345678")
        try await trustall.numberIdentification.addNumber(numberInfo: info)
        print("Number added for identification")
    } catch {
        print("Failed: \(error)")
    }
}
```

### Remove number from identification list

```swift
let trustall = Trustall()

Task {
    do {
        try await trustall.numberIdentification.removeNumber(886912345678)
        print("Number removed from identification list")
    } catch {
        print("Failed: \(error)")
    }
}
```

### Load Identification List in Call Directory Extension

#### Parameters (`beginRequest`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `context` | `CXCallDirectoryExtensionContext` | Yes | The extension context provided by CallKit. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

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
        trustall.numberIdentification.beginRequest(with: context)
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

Errors that can occur during number identification operations.

| Error | Description |
|-------|-------------|
| `invalidNumber` | The provided phone number format is invalid. |

