# Number Search

Performs phone number lookups using Trustall's number search service over the network.

Call ``searchNumber(e164:)`` to obtain a ``NumberInfo`` with name, business category, and spam details for the given number.

## API

| Method | Description |
|--------|-------------|
| `searchNumber(e164: String) async throws -> NumberInfo` | Searches for information about a phone number. |

### Usage Example

#### Return Value (`searchNumber`)

A ``NumberInfo`` with the number's name, business category, and spam information.

```swift
let trustall = Trustall()

Task {
    do {
        let info = try await trustall.numberSearch.searchNumber(e164: "+886912345678")
        print("Name: \(info.name)")
        print("Business Category: \(info.businessCategory)")
        print("Spam: \(info.spam)")
        print("Spam Level: \(info.spamLevel)")
    } catch {
        print("Search failed: \(error)")
    }
}
```

## NumberInfo

Information about a phone number returned by a number search.

### Fields

| Property | Type | Description |
|----------|------|-------------|
| `e164` | `String` | The phone number in E.164 format. |
| `name` | `String` | The name associated with the number (company name, personal name, etc.). |
| `businessCategory` | `String` | The business category of the number (e.g., restaurant, bank). |
| `spam` | `String` | The spam label description. |
| `spamLevel` | `Int` | The spam severity level. Higher values indicate greater spam likelihood. |

## Capabilities and setup

Requires **network** access and valid **license** values from `Trustall-Info.plist`. If you share state via the App Group container, enable **App Groups** on all involved targets.

- [Configuring app groups](https://developer.apple.com/documentation/xcode/configuring-app-groups)

## Usage limits

| Item | Limit |
|------|-------|
| Number Format | E.164 format recommended (e.g., `+886912345678`) |
| Authentication | Valid License ID required |

