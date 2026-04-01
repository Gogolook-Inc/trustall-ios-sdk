# Number Block

Manages personal call blocking by allowing users to block and unblock specific phone numbers.

## API

| Method | Description |
|--------|-------------|
| `blockNumbers() async throws -> [String]` | Returns the list of currently blocked phone numbers. |
| `callDirectoryIsEnabled() async throws -> Bool` | Checks whether the Number Block Call Directory extension is enabled. |
| `blockNumber(_ number: String) async throws` | Blocks a phone number. |
| `unblockNumber(_ number: String) async throws` | Unblocks a previously blocked phone number. |
| `beginRequest(with context: CXCallDirectoryExtensionContext)` | Handles the Call Directory extension's request to load the blocking list. |

### List blocked phone numbers

#### Return Value (`blockNumbers`)

An array of blocked phone number strings.

```swift
let trustall = Trustall()

Task {
    do {
        let numbers = try await trustall.numberBlock.blockNumbers()
        print("Blocked numbers: \(numbers)")
    } catch {
        print("Failed: \(error)")
    }
}
```

### Number Block Call Directory extension status

### Block a Number

#### Parameters (`blockNumber`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `number` | `String` | Yes | The phone number to block. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

```swift
let trustall = Trustall()

Task {
    do {
        try await trustall.numberBlock.blockNumber("+886912345678")
        print("Number blocked successfully")
    } catch {
        print("Block failed: \(error)")
    }
}
```

### Unblock a Number

#### Parameters (`unblockNumber`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `number` | `String` | Yes | The phone number to unblock. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

```swift
let trustall = Trustall()

Task {
    do {
        try await trustall.numberBlock.unblockNumber("+886912345678")
        print("Number unblocked successfully")
    } catch {
        print("Unblock failed: \(error)")
    }
}
```

### Load Personal Blocking List in Call Directory Extension

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
        trustall.numberBlock.beginRequest(with: context)
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

## Usage limits

| Item | Limit |
|------|-------|
| Maximum Blocked Numbers | 500 |
| Number Format | Supports E.164 format or numeric format |

## Error Handling

Errors that can occur during number blocking operations.

| Error | Description |
|-------|-------------|
| `invalidNumber` | The provided phone number format is invalid. |
| `callDirectoryExtensionDisabled` | The Call Directory extension is not enabled in Settings. |

