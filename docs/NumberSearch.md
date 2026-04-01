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

### Phone number (`e164`)

The queried number in E.164 format.

### Display name (`name`)

The name associated with the number from the service (company, person, etc.).

### Business category

Identifies the type of business or entity associated with a number. Machine-readable category code; map to a display label in your UI as needed.

| Value | Display Name |
|-------|--------------|
| `automobile` | Automobile |
| `bank` | Financial |
| `beauty` | Personal Care |
| `professional` | Consultants |
| `logistic` | Delivery |
| `education` | Education |
| `entertainment` | Entertainment |
| `food` | Food |
| `government` | Government |
| `life` | Handy Services |
| `health` | Health and Medical |
| `media` | Media |
| `organization` | Company / Organization |
| `others` | Other |
| `publicperson` | Performer or Public Figure |
| `personal` | Personal |
| `pet` | Pets |
| `politics` | Political |
| `shopping` | Shopping |
| `activity` | Exhibitions |
| `traffic` | Transportation |
| `travel` | Travel |

The service may return values not listed here or legacy codes; treat the response as authoritative.

### Spam category

Identifies the type of spam associated with a number. Raw category string (typically one of the values below).

| Value | Description |
|-------|-------------|
| `TOP` | Popular number |
| `TELMARKETING` | Sales / Ads |
| `CALLCENTER` | Customer Service |
| `FRAUD` | Unwelcome |
| `PHISHING` | Phishing |
| `ADULT` | Adult Contents |
| `ILLEGAL` | Illegal Threat |
| `HARASSMENT` | Harassment |
| `ONERING` | One-ring call |
| `HFB` | Frequently Blocked |

The service may return values not listed here; treat the response as authoritative.

### Spam severity

Integer severity level.

| Value | Semantics |
|-------|-----------|
| 0 | Unlikely spam |
| 1 | Suspicious spam |
| 2 | Confirmed spam |

### Fields

| Property | Type | Description |
|----------|------|-------------|
| `e164` | `String` | The phone number in E.164 format. |
| `name` | `String` | The name associated with the number (company name, personal name, etc.). |
| `businessCategory` | `String` | Raw business category code. See the type discussion above for common values and display labels. |
| `spam` | `String` | Raw spam category string. See the type discussion above for common values. |
| `spamLevel` | `Int` | Spam severity: **0** unlikely, **1** suspicious, **2** confirmed; see the type discussion above. |

## Capabilities and setup

Requires **network** access and valid **license** values from `Trustall-Info.plist`. If you share state via the App Group container, enable **App Groups** on all involved targets.

- [Configuring app groups](https://developer.apple.com/documentation/xcode/configuring-app-groups)

## Usage limits

| Item | Limit |
|------|-------|
| Number Format | E.164 format recommended (e.g., `+886912345678`) |
| Authentication | Valid License ID required |

