# URL Scan

Checks URL safety levels to detect malicious websites.

## API

| Method | Description |
|--------|-------------|
| `checkConfidenceLevel(urlString: String) async throws -> ConfidenceLevel` | Checks the safety confidence level of a URL. |

### Check URL Safety Level

#### Parameters (`checkConfidenceLevel`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `urlString` | `String` | Yes | The URL string to scan. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

#### Return Value (`checkConfidenceLevel`)

A ``ConfidenceLevel`` indicating the safety level of the URL.

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

## ConfidenceLevel

Represents the safety confidence level of a URL scan result.

| Level | rawValue | Description | isDangerous |
|-------|----------|-------------|-------------|
| `.safe` | `"safe"` | The URL is considered safe. | false |
| `.suspicious` | `"suspicious"` | The URL is suspicious and should be approached with caution. | true |
| `.unknown` | `"unknown"` | The safety level could not be determined. | false |
| `.malicious` | `"malicious"` | The URL is confirmed as malicious. | true |

## Capabilities and setup

This feature uses **network** requests and may cache results. Document endpoints, transport security, and data categories in your privacy labels and policy as needed.

- [URLSession](https://developer.apple.com/documentation/foundation/urlsession)

## Usage limits

| Item | Limit |
|------|-------|
| Result Cache | Same URL scan results cached for 1 day |
| Network Requirement | Network connection required for first scan |

