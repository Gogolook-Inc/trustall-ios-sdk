# SMS Filter

Provides SMS filtering capabilities to detect and categorize spam messages.

## API

| Method | Description |
|--------|-------------|
| `handle(_ capabilitiesQueryRequest: ILMessageFilterCapabilitiesQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterCapabilitiesQueryResponse) -> Void)` | Handles the Message Filter extension **capabilities** query. |
| `handle(_ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterQueryResponse) -> Void)` | Handles the **message filter** query for classifying an incoming SMS (not the capabilities query API). |
| `enable() async throws` | Enables SMS filtering by downloading and applying the latest filter rules. |
| `disable() async throws` | Disables SMS filtering by removing locally stored filter rules. |
| `lastFetchDate() throws -> Date?` | Returns the date when filter rules were last downloaded. |

### Message Filter capabilities query

#### Parameters (`handle`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `capabilitiesQueryRequest` | `ILMessageFilterCapabilitiesQueryRequest` | Yes | The capabilities query request. |
| `context` | `ILMessageFilterExtensionContext` | Yes | The Message Filter extension context. |
| `completion` | `@escaping (ILMessageFilterCapabilitiesQueryResponse) -> Void` | Yes | A closure to call with the capabilities response. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

### Classify incoming SMS (Message Filter extension)

#### Parameters (`handle`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `queryRequest` | `ILMessageFilterQueryRequest` | Yes | The `ILMessageFilterQueryRequest` for this SMS. |
| `context` | `ILMessageFilterExtensionContext` | Yes | The Message Filter extension context. |
| `completion` | `@escaping (ILMessageFilterQueryResponse) -> Void` | Yes | Completion handler; invoke with `ILMessageFilterQueryResponse` when classification is done. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

### Enable/Disable SMS Filtering

```swift
let trustall = Trustall()

Task {
    do {
        try await trustall.smsFilter.enable()
        print("SMS filtering enabled")
    } catch {
        print("Enable failed: \(error)")
    }
}
```

```swift
let trustall = Trustall()

Task {
    do {
        try await trustall.smsFilter.disable()
        print("SMS filtering disabled")
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

if let lastFetchDate = try trustall.smsFilter.lastFetchDate() {
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
        trustall.smsFilter.handle(queryRequest, context: context, completion: completion)
    }
}

extension MessageFilterExtension: ILMessageFilterCapabilitiesQueryHandling {
    func handle(_ capabilitiesQueryRequest: ILMessageFilterCapabilitiesQueryRequest,
                context: ILMessageFilterExtensionContext,
                completion: @escaping (ILMessageFilterCapabilitiesQueryResponse) -> Void) {
        trustall.smsFilter.handle(capabilitiesQueryRequest, context: context, completion: completion)
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

