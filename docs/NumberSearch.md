# Number Search

Performs phone number lookups, trying each configured ``NumberSearchProviding`` source in order.

Call ``searchNumber(e164:)`` to obtain a ``NumberInfo`` with name, business category, and spam details for the given number.
By default only Trustall's own service (``TrustallNumberSearchProvider``) is used; call ``setProviders(_:)`` to add or replace sources.

## API

| Method | Description |
|--------|-------------|
| `setProviders(_ providers: [any NumberSearchProviding]) throws` | Sets the sources to try, in order, when searching for a number. |
| `searchNumber(e164: String) async throws -> NumberInfo` | Searches for information about a phone number. |

### Usage Example

#### Parameters (`setProviders`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `providers` | `[any NumberSearchProviding]` | Yes | The sources to try, in order. Must not be empty. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

```swift
try Trustall.configure(options)

// Prefer our own source; fall back to Trustall if it has no answer.
try Trustall.NumberSearch.setProviders([MyProvider(), .trustall])

// Never use Trustall's own service.
try Trustall.NumberSearch.setProviders([MyProvider()])
```

### Usage Example

#### Return Value (`searchNumber`)

A ``NumberInfo`` with the number's name, business category, and spam information. If every source normally reports no data, the fields other than `e164` are empty (see ``NumberInfo/isNotFound``).

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
| `businessCategory` | `NumberInfo.BusinessCategory` | Category of business or entity associated with the number. See ``BusinessCategory``. |
| `spam` | `NumberInfo.SpamCategory` | Category of spam associated with the number. See ``SpamCategory``. |
| `spamLevel` | `NumberInfo.SpamLevel` | Spam severity. See ``SpamLevel``. |
| `isNotFound` | `Bool` | `true` when every field except `e164` is at its empty/default value. |

## NumberSearchProviding

A source for phone number lookups — Trustall's own service, or one you supply.

Configure sources with ``NumberSearch/setProviders(_:)``. ``NumberSearch/searchNumber(e164:)``
tries each configured source in order and stops at the first one that has data.

```swift
// Try our own source first; fall back to Trustall if it has no answer.
try Trustall.NumberSearch.setProviders([MyProvider(), .trustall])

// Never use Trustall's own service.
try Trustall.NumberSearch.setProviders([MyProvider()])
```

To supply your own source, implement ``searchNumber(_:)``. Each way it can end tells
``NumberSearch/searchNumber(e164:)`` something different:

```swift
struct MyProvider: NumberSearchProviding {
    private let directory = MyDirectory()  // Your own data source.

    func searchNumber(_ e164: String) async throws -> NumberInfo {
        // Could not complete the lookup this time (for example a network failure):
        // throw, and the next configured source is tried.
        let record = try await directory.lookUp(e164)

        guard let record else {
            // No data for this number: return every field except `e164` empty,
            // and the next configured source is tried.
            return NumberInfo(
                e164: e164,
                name: "",
                businessCategory: .init(rawValue: ""),
                spam: .init(rawValue: ""),
                spamLevel: .unlikely
            )
        }

        // Found: any other value stops the search and is returned to the caller as-is.
        return NumberInfo(
            e164: e164,
            name: record.name,
            businessCategory: .bank,
            spam: record.isFraud ? .fraud : .init(rawValue: ""),
            spamLevel: record.isFraud ? .confirmed : .unlikely
        )
    }
}
```


### Values

| Value | Description |
|-------|-------------|
| `.trustall` | Trustall's own number search source. |

### Requirements

Implement these to conform to `NumberSearchProviding`.

| Method | Description |
|--------|-------------|
| `searchNumber(_ e164: String) async throws -> NumberInfo` | Looks up a phone number, in E.164 format (e.g. `+886912345678`). |

#### `searchNumber`

Looks up a phone number, in E.164 format (e.g. `+886912345678`).

- Returns a value for which ``NumberInfo/isNotFound`` is `true` to report that this source
  has no data for the number — ``NumberSearch/searchNumber(e164:)`` tries the next
  configured source.
- Returns any other value to stop the search — the remaining sources are not tried.
- Throws to report that this source could not complete the lookup this time (for example a
  network failure or timeout) — ``NumberSearch/searchNumber(e164:)`` tries the next source.
  If none succeeds, these errors are retained in ``NumberSearch/SearchFailure``.
- Throws `CancellationError` to stop immediately without fallback or logging.

The returned value is passed back as-is, `e164` included — set it to the number you were
asked to look up.

## Capabilities and setup

Requires **network** access and valid **license** values from `Trustall-Info.plist`. If you share state via the App Group container, enable **App Groups** on all involved targets.

- [Configuring app groups](https://developer.apple.com/documentation/xcode/configuring-app-groups)

## Usage limits

| Item | Limit |
|------|-------|
| Number Format | E.164 format recommended (e.g., `+886912345678`) |
| Authentication | Valid License ID required |

## Error Handling

Errors thrown while configuring a number search.

| Error | Description |
|-------|-------------|
| `emptyProviders` | `setProviders(_:)` was called with an empty array. |

### emptyProviders

An empty list would silently fall through to having no sources configured at all,
which is indistinguishable from a mistake, so it is rejected instead.

