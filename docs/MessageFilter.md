# Message Filter

Provides Message Filter capabilities to detect and categorize spam messages.

## API

| Method | Description |
|--------|-------------|
| `handle(_ capabilitiesQueryRequest: ILMessageFilterCapabilitiesQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterCapabilitiesQueryResponse) -> Void)` | Handles the Message Filter extension **capabilities** query. |
| `handle(_ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterQueryResponse) -> Void)` | Handles the **message filter** query for classifying an incoming message.(not the capabilities query API) |
| `enable() async throws` | Enables Message Filter support by downloading and applying the latest filter rules. |
| `disable() async throws` | Disables Message Filter support by removing locally stored filter rules. |
| `lastFetchDate() throws -> Date?` | Returns the date when filter rules were last downloaded. |

### Message Filter capabilities query

#### Parameters (`handle`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `capabilitiesQueryRequest` | `ILMessageFilterCapabilitiesQueryRequest` | Yes | The capabilities query request. |
| `context` | `ILMessageFilterExtensionContext` | Yes | The Message Filter extension context. |
| `completion` | `@escaping (ILMessageFilterCapabilitiesQueryResponse) -> Void` | Yes | A closure to call with the capabilities response. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

### Classify incoming messages (MessageFilter extension)

#### Parameters (`handle`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `queryRequest` | `ILMessageFilterQueryRequest` | Yes | The `ILMessageFilterQueryRequest` for this incoming message. |
| `context` | `ILMessageFilterExtensionContext` | Yes | The Message Filter extension context. |
| `completion` | `@escaping (ILMessageFilterQueryResponse) -> Void` | Yes | Completion handler; invoke with `ILMessageFilterQueryResponse` when classification is done. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

### Enable/Disable MessageFilter

```swift
let trustall = Trustall()

Task {
    do {
        try await trustall.messageFilter.enable()
        print("Message Filter enabled")
    } catch {
        print("Enable failed: \(error)")
    }
}
```

```swift
let trustall = Trustall()

Task {
    do {
        try await trustall.messageFilter.disable()
        print("Message Filter disabled")
    } catch {
        print("Disable failed: \(error)")
    }
}
```

### Get Last Update Time

#### Return Value (`lastFetchDate`)

The last fetch date, or `nil` if rules have not been fetched yet.

```swift
let trustall = Trustall()

if let lastFetchDate = try trustall.messageFilter.lastFetchDate() {
    print("Filter rules last updated: \(lastFetchDate)")
} else {
    print("Filter rules not yet fetched")
}
```

## Extension Integration

```swift
import IdentityLookup
import TrustallSDK

final class MessageFilterExtension: ILMessageFilterExtension {
    let trustall: Trustall

    override init() {
        do {
            try Trustall.configure()
        } catch {
            print("SDK initialization failed: \(error)")
        }
        self.trustall = Trustall()
        super.init()
    }
}

extension MessageFilterExtension: ILMessageFilterQueryHandling {
    func handle(_ queryRequest: ILMessageFilterQueryRequest,
                context: ILMessageFilterExtensionContext,
                completion: @escaping (ILMessageFilterQueryResponse) -> Void) {
        trustall.messageFilter.handle(queryRequest, context: context, completion: completion)
    }
}

extension MessageFilterExtension: ILMessageFilterCapabilitiesQueryHandling {
    func handle(_ capabilitiesQueryRequest: ILMessageFilterCapabilitiesQueryRequest,
                context: ILMessageFilterExtensionContext,
                completion: @escaping (ILMessageFilterCapabilitiesQueryResponse) -> Void) {
        trustall.messageFilter.handle(capabilitiesQueryRequest, context: context, completion: completion)
    }
}
```

## Capabilities and setup

This feature uses **App Groups** and a **Message Filter** extension. Enable the Message Filter capability and initialize the SDK in the filter extension process.

- [SMS and call reporting](https://developer.apple.com/documentation/sms_and_call_reporting)

## Usage limits

| Item | Limit |
|------|-------|
| Rule Update Frequency | Automatically updates every 7 days |
| Offline Support | Supported (uses downloaded rules) |

