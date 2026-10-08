# URL Scan

Extracts URLs from text and checks their safety levels, trying each configured ``ConfidenceLevelProviding`` source in order.

By default only Trustall's own service (``RemoteConfidenceLevelProvider``) is used; call
``setProviders(_:)`` to add or replace sources.

## API

| Method | Description |
|--------|-------------|
| `setProviders(_ providers: [any ConfidenceLevelProviding]) throws` | Sets the sources to try, in order, when checking a URL. |
| `extractURLs(from text: String) async throws -> [URL]` | Extracts HTTP(S) URLs from text without contacting safety providers or checking reachability. |
| `checkConfidenceLevels(in text: String, maxConcurrentRequests: Int = 4) async throws -> [URL : ConfidenceLevel]` | Extracts URLs from text and checks each distinct URL's safety level. |
| `checkConfidenceLevel(urlString: String) async throws -> ConfidenceLevel` | Checks the safety confidence level of a URL. |

### Extract URLs from Text

**Details (`extractURLs`):**

Supported bare domains receive an HTTPS scheme. URLs follow their order in the text,
including repeated occurrences. Empty text or text without recognized URLs returns `[]`.
Detection is heuristic; for example, Chinese prose immediately following a hostname may
be included in that hostname.

#### Parameters (`extractURLs`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `text` | `String` | Yes | The text to inspect. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

#### Return Value (`extractURLs`)

The recognized URL occurrences, in source order.

**Throws (`extractURLs`):** An error if the detector cannot be initialized, or `CancellationError` if cancelled.

### Check URL Safety Levels in Text

**Details (`checkConfidenceLevels`):**

Each invocation checks at most `maxConcurrentRequests` distinct URLs concurrently using
``checkConfidenceLevel(urlString:)``, including its configured providers and cache.
Repeated URLs (according to `URL` equality) are checked once. The returned dictionary
has no ordering guarantee. Text without recognized URLs returns `[:]`.
This is a per-invocation concurrency limit, not a requests-per-second limit.

#### Parameters (`checkConfidenceLevels`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `text` | `String` | Yes | The text containing URLs to scan. |
| `maxConcurrentRequests` | `Int = 4` | No | Maximum simultaneous URL checks in this invocation. Defaults to 4 and must be greater than zero. Use 1 for sequential checks. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

#### Return Value (`checkConfidenceLevels`)

Each distinct URL and its safety level, including normal `.unknown` answers.

**Throws (`checkConfidenceLevels`):** ``Error/invalidMaxConcurrentRequests`` if the limit is less than 1, even for empty text. Otherwise, detection errors or the first scan error or cancellation encountered. No partial result is returned. Remaining tasks are cancelled and awaited; providers must cooperate with cancellation to stop promptly. Completed cache writes are retained.

```swift
let trustall = Trustall()
let message = "Your parcel is on hold: https://example.com/track. Pay the fee at example.org"

Task {
    do {
        // The dictionary has no order, so take the order from extractURLs(from:).
        let urls = try await trustall.urlScan.extractURLs(from: message)
        let levels = try await trustall.urlScan.checkConfidenceLevels(in: message)

        for url in urls {
            let level = levels[url] ?? .unknown
            if level.isDangerous {
                print("Warning: \(url) is \(level.rawValue)")
            }
        }
    } catch {
        // One failed URL check fails the whole call; no partial result is returned.
        print("Scan failed: \(error)")
    }
}
```

### Check URL Safety Level

#### Parameters (`checkConfidenceLevel`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `urlString` | `String` | Yes | The URL string to scan. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

#### Return Value (`checkConfidenceLevel`)

A ``ConfidenceLevel`` indicating the safety level of the URL. If none of the configured sources had an answer and none failed, ``ConfidenceLevel/unknown`` is returned.

**Throws (`checkConfidenceLevel`):** ``ScanFailure`` if no source returns an answer and at least one source fails. Original errors are retained in attempt order. A provider's `CancellationError` propagates immediately without trying another source or logging. Neither failure nor cancellation is cached. Logging settings do not change this contract.

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

**Details (`setProviders`):**

The first source that returns an answer (anything other than ``ConfidenceLevel/unknown``)
stops the check; a source that has no answer or throws an ordinary error is skipped in
favor of the next one. Explicit cancellation immediately stops the check.

This configuration belongs to the process, not to a `Trustall` instance, and is safe to
call from any thread. Call it right after `Trustall.configure(_:)`.

- Important: This must be called once in *every* process that uses `URLScan`, the Safari
  Web Extension included — an app and its extension are separate processes and share
  nothing here. A process that never calls it silently falls back to Trustall's own
  service, so a source list meant to keep URLs away from Trustall would not hold there.
  Put the call somewhere every process runs, not in the app delegate alone.

#### Parameters (`setProviders`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `providers` | `[any ConfidenceLevelProviding]` | Yes | The sources to try, in order. Must not be empty. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

**Throws (`setProviders`):** ``Error/emptyProviders`` if `providers` is empty.

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

Calls for different URLs may run concurrently, including within a text scan. Protect any
mutable state and cooperate with task cancellation to stop unnecessary work promptly.

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
| `invalidMaxConcurrentRequests` | The requested concurrency limit was less than 1. |

### emptyProviders

An empty list would silently fall through to having no sources configured at all,
which is indistinguishable from a mistake, so it is rejected instead.

