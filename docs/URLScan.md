# URL Scan

Checks URL safety levels to detect malicious websites, trying each configured ``ConfidenceLevelProviding`` source in order.

By default only Trustall's own service (``RemoteConfidenceLevelProvider``) is used; call
``setProviders(_:)`` to add or replace sources.

## API

| Method | Description |
|--------|-------------|
| `setProviders(_ providers: [any ConfidenceLevelProviding]) throws` | Sets the sources to try, in order, when checking a URL. |
| `checkConfidenceLevel(urlString: String) async throws -> ConfidenceLevel` | Checks the safety confidence level of a URL. |

### Check URL Safety Level

#### Parameters (`checkConfidenceLevel`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `urlString` | `String` | Yes | The URL string to scan. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

#### Return Value (`checkConfidenceLevel`)

A ``ConfidenceLevel`` indicating the safety level of the URL. If none of the configured sources had an answer and none failed, ``ConfidenceLevel/unknown`` is returned.

```swift
let trustall = Trustall()

Task {
    do {
        let level = try await trustall.urlScan.checkConfidenceLevel(urlString: "https://example.com")

        switch level {
        case .safe:
            print("Safe website")
        case .suspicious:
            print("Suspicious website, proceed with caution")
        case .malicious:
            print("Malicious website, do not visit")
        case .unknown:
            print("Cannot determine")
        default:
            print("Other: \(level.rawValue)")
        }

        if level.isDangerous {
            print("Warning: This website may be risky!")
        }
    } catch {
        print("Scan failed: \(error)")
    }
}
```

### Usage Example

#### Parameters (`setProviders`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `providers` | `[any ConfidenceLevelProviding]` | Yes | The sources to try, in order. Must not be empty. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

```swift
try Trustall.configure(options)

// Prefer our own source; fall back to Trustall if it has no answer.
try Trustall.URLScan.setProviders([MyProvider(), .trustall])

// Never use Trustall's own service.
try Trustall.URLScan.setProviders([MyProvider()])
```

## ConfidenceLevel

Represents the safety confidence level of a URL scan result.

| Level | rawValue | Description | isDangerous |
|-------|----------|-------------|-------------|
| `.safe` | `"safe"` | The URL is considered safe. | false |
| `.suspicious` | `"suspicious"` | The URL is suspicious and should be approached with caution. | true |
| `.unknown` | `"unknown"` | The safety level could not be determined. | false |
| `.malicious` | `"malicious"` | The URL is confirmed as malicious. | true |

## ConfidenceLevelProviding

A source for URL safety checks — Trustall's own service, or one you supply.

Configure sources with ``URLScan/setProviders(_:)``. ``URLScan/checkConfidenceLevel(urlString:)``
tries each configured source in order and stops at the first one that has an answer.

The SDK caches the final answer itself; a source does not need to do any caching of its own.

The same sources serve both ``URLScan`` and ``WebGuard``; WebGuard has no source list of its
own.

```swift
// Try our own source first; fall back to Trustall if it has no answer.
try Trustall.URLScan.setProviders([MyProvider(), .trustall])

// Never use Trustall's own service.
try Trustall.URLScan.setProviders([MyProvider()])
```

To supply your own source, implement ``scan(_:)``. Each way it can end tells
``URLScan/checkConfidenceLevel(urlString:)`` something different:

```swift
struct MyProvider: ConfidenceLevelProviding {
    private let blocklist = MyBlocklist()  // Your own data source.

    func scan(_ urlString: String) async throws -> ConfidenceLevel {
        // Could not complete the check this time (for example a network failure):
        // throw, and the next configured source is tried.
        guard let verdict = try await blocklist.verdict(for: urlString) else {
            // No answer for this URL: return `.unknown`, and the next configured source is tried.
            return .unknown
        }

        // Any other value stops the check and is returned to the caller.
        return verdict.isBlocked ? .malicious : .safe
    }
}
```


### Values

| Value | Description |
|-------|-------------|
| `.trustall` | Trustall's own URL scan source. |

### Requirements

Implement these to conform to `ConfidenceLevelProviding`.

| Method | Description |
|--------|-------------|
| `scan(_ urlString: String) async throws -> ConfidenceLevel` | Checks a URL. |

#### `scan`

Checks a URL.

- Returns ``ConfidenceLevel/unknown`` to report that this source has no answer for the
  URL — ``URLScan/checkConfidenceLevel(urlString:)`` tries the next configured source.
  Only when *every* configured source answers `.unknown` is the uncached result reported
  as unknown to the caller.
- Returns any other value to stop the check — the remaining sources are not tried.
- Throws to report that this source could not complete the check this time (for example a
  network failure or timeout) — ``URLScan/checkConfidenceLevel(urlString:)`` tries the
  next source. If none answers, ordinary errors are retained in ``URLScan/ScanFailure``.
  Explicit `CancellationError` stops the scan immediately and is propagated without logging.

## Capabilities and setup

This feature uses **network** requests and may cache results. Document endpoints, transport security, and data categories in your privacy labels and policy as needed.

- [URLSession](https://developer.apple.com/documentation/foundation/urlsession)

## Usage limits

| Item | Limit |
|------|-------|
| Result Cache | Same URL scan results cached for 1 day |
| Network Requirement | Network connection required for first scan |

## Error Handling

Errors thrown while configuring a URL scan.

| Error | Description |
|-------|-------------|
| `emptyProviders` | `setProviders(_:)` was called with an empty array. |

### emptyProviders

An empty list would silently fall through to having no sources configured at all,
which is indistinguishable from a mistake, so it is rejected instead.

