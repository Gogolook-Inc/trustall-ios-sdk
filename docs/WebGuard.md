# Web Guard

Scans URLs visited in Safari and sends warning notifications for dangerous websites.

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `notificationURLKey` | `String` | The key used in notification `userInfo` to store the scanned URL string. |

## API

| Method | Description |
|--------|-------------|
| `beginRequest(with context: NSExtensionContext, content: UNNotificationContent)` | Handles the Safari Web Extension's request to scan the current page URL. |

### Handle Requests in Safari Web Extension

#### Parameters (`beginRequest`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `context` | `NSExtensionContext` | Yes | The extension context from the Safari Web Extension. |
| `content` | `UNNotificationContent` | Yes | The notification content to display for dangerous URLs. |

*The **Required** column follows the Swift signature: `No` if a default value is present; `Optional` if the parameter type is optional (`?`); otherwise `Yes`.*

## Extension Integration

```swift
import SafariServices
import TrustallSDK
import UserNotifications

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
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

    func beginRequest(with context: NSExtensionContext) {
        let content: UNNotificationContent = {
            let content = UNMutableNotificationContent()
            content.title = "Warning"
            content.body = "The website may be risky."
            return content.copy() as! UNNotificationContent
        }()
        trustall.webGuard.beginRequest(with: context, content: content)
    }
}
```

## Capabilities and setup

This feature integrates through a **Safari Web Extension**. Configure the extension target, entitlements, and host app relationship per Apple’s current guidance.

- [Safari Services](https://developer.apple.com/documentation/safariservices)


> **Disclaimer and verification environment**
>
> The manifests, JavaScript, and plist snippets in this guide are **examples only**. Follow Apple’s current documentation and the capabilities of your target **iOS version and extension types**; after upgrading Xcode or iOS, **re-test** your integration.
>
> **Baseline used alongside the main README:** Validate this guide against the same **Xcode / iOS SDK** baseline used to produce the current prebuilt XCFramework release. Keep that **SDK / toolchain** baseline separate from the app’s **minimum deployment target** (for example, `iOS 16.0+` in the README).
>
> **Safari in this document means iOS Safari** (Safari on iPhone and iPad), **not** the macOS desktop Safari app. Use a device or simulator running the **iOS version your team validates for the current release baseline** to verify Web Extension behavior; record the **exact iOS build and device model** you used for QA. Xcode itself may run on macOS; keep that **build machine** context separate from the **end-user Safari** context, which here is **iOS Safari**.

## Safari Web Extension Setup Guide

The Safari Web Extension requires both Swift code and web resources (HTML, CSS, JavaScript). This guide provides a complete, ready-to-use implementation.

### Step 1: Create Safari Web Extension Target

1. In Xcode, select **File > New > Target**
2. Choose **Safari Extension** (not Safari App Extension)
3. Name it (e.g., `SafariWebGuard`)
4. Make sure "Safari Web Extension" type is selected

### Step 2: Create the Resources Folder Structure

Create the following folder structure in your Safari Extension target:

```
Resources/
├── _locales/
│   └── en/
│       └── messages.json
├── images/
│   ├── icon-48.png
│   ├── icon-64.png
│   ├── icon-96.png
│   ├── icon-128.png
│   ├── icon-256.png
│   ├── icon-512.png
│   └── toolbar-icon.svg
├── manifest.json
├── background.js
├── content.js
├── popup.html
├── popup.css
└── popup.js
```

### Step 3: Copy the Following Files

**`manifest.json`** - Extension manifest (manifest v3)

```json
{
    "manifest_version": 3,
    "default_locale": "en",

    "name": "__MSG_extension_name__",
    "description": "__MSG_extension_description__",
    "version": "1.0",

    "icons": {
        "48": "images/icon-48.png",
        "96": "images/icon-96.png",
        "128": "images/icon-128.png",
        "256": "images/icon-256.png",
        "512": "images/icon-512.png"
    },

    "background": {
        "scripts": [ "background.js" ],
        "persistent": false
    },

    "content_scripts": [{
        "js": [ "content.js" ],
        "matches": [ "<all_urls>" ]
    }],

    "action": {
        "default_popup": "popup.html",
        "default_icon": "images/toolbar-icon.svg"
    },

    "permissions": [ "activeTab", "nativeMessaging", "tabs"]
}
```

**`background.js`** - Background script for native messaging

```javascript
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === "trustall_web_guard")
        scan(request.url, request.title);
});

function scan(url, title) {
    browser.runtime.sendNativeMessage({ action: "trustall_web_guard", url: url, title: title }, function(response) {
        console.log("Received response:", response);
        sendResponse(response);
    });
}
```

**`content.js`** - Content script injected into web pages (auto-scans every page)

```javascript
checkURLInBackground()

function checkURLInBackground() {
    let url = window.location.href
    let title = document.title
    browser.runtime.sendMessage({ action: "trustall_web_guard", url: url, title: title });
}

browser.runtime.onMessage.addListener(function(message, sender, sendResponse) {
    if (message.action === "goToTrustallSDKMainApp") {
        let url = message['scheme'] + "://"
        location.href = url;
    }
});
```

**`popup.html`** - Toolbar popup UI

```html
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Popup</title>
        <link rel="stylesheet" href="popup.css">
    </head>
    <body>
        <div class="container">
            <img src="images/icon-128.png" alt="Icon" class="icon">
            <div class="title" id="title"></div>
            <div class="content" id="content"></div>
            <button class="action-button" id="actionButton"></button>
        </div>
        <script src="popup.js"></script>
    </body>
</html>
```

**`popup.css`** - Popup styles

```css
body {
    margin: 0;
    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
    min-width: 280px;
}

.container {
    text-align: center;
    padding: 40px 20px;
}

.icon {
    width: 48px;
    height: 48px;
}

.title {
    color: rgba(33, 33, 33, 0.9);
    font-size: 15px;
    font-weight: 600;
    padding-top: 20px;
}

.content {
    color: rgba(33, 33, 33, 0.7);
    font-size: 13px;
    padding-top: 8px;
    line-height: 1.4;
}

.action-button {
    background-color: #00C300;
    color: #FFFFFF;
    font-size: 13px;
    font-weight: 600;
    padding: 8px 24px;
    margin-top: 20px;
    border: none;
    cursor: pointer;
    border-radius: 16px;
}

.action-button:hover {
    background-color: #00A000;
}
```

**`popup.js`** - Popup logic

```javascript
document.addEventListener('DOMContentLoaded', function () {
    const titleText = browser.i18n.getMessage("popupTitle");
    const contentText = browser.i18n.getMessage("popupContent");
    const buttonText = browser.i18n.getMessage("popupButtonTitle");

    document.getElementById('title').textContent = titleText;
    document.getElementById('content').textContent = contentText;

    const actionButton = document.getElementById('actionButton');
    actionButton.textContent = buttonText;

    actionButton.addEventListener('click', function() {
        window.close();
        browser.tabs.query({active: true, currentWindow: true}, function(tabs) {
            // ⚠️ IMPORTANT: Change "your-app-scheme" to your app's URL scheme
            browser.tabs.sendMessage(tabs[0].id, {
                "action": "goToTrustallSDKMainApp",
                "scheme": "your-app-scheme"
            });
        });
    });
});
```

**`_locales/en/messages.json`** - Localization strings

```json
{
    "extension_name": {
        "message": "Your App Safari Web Guard"
    },
    "extension_description": {
        "message": "Automatically check websites and notify when risks are found."
    },
    "popupTitle": {
        "message": "Auto Web Checker is enabled"
    },
    "popupContent": {
        "message": "When a suspicious website is found, you will be alerted via notification."
    },
    "popupButtonTitle": {
        "message": "Back to App"
    }
}
```

### Step 4: Add Your App Icons

Add the following icon files to the `Resources/images/` folder:

| File | Size | Purpose |
|------|------|---------|
| `icon-48.png` | 48x48 | Extension icon |
| `icon-64.png` | 64x64 | Extension icon |
| `icon-96.png` | 96x96 | Extension icon |
| `icon-128.png` | 128x128 | Extension icon / Popup icon |
| `icon-256.png` | 256x256 | Extension icon |
| `icon-512.png` | 512x512 | Extension icon |
| `toolbar-icon.svg` | Vector | Safari toolbar button |

### Step 5: Required Customizations

Before building, make sure to update these values:

| File | What to Change | Example |
|------|----------------|---------|
| `popup.js` | URL scheme (line with `"scheme":`) | `"scheme": "myapp"` |
| `messages.json` | `extension_name` | `"Your App Safari Web Guard"` |
| `messages.json` | `extension_description` | Your app description |
| `messages.json` | `popupButtonTitle` | `"Back to Your App"` |

### How It Works

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           Safari Browser                                 │
├─────────────────────────────────────────────────────────────────────────┤
│  1. User visits a webpage                                                │
│           │                                                              │
│           ▼                                                              │
│  ┌─────────────────┐                                                     │
│  │   content.js    │  Injected into every page                           │
│  │                 │  Extracts URL and page title                        │
│  └────────┬────────┘                                                     │
│           │ sendMessage({ action: "trustall_web_guard", url, title })    │
│           ▼                                                              │
│  ┌─────────────────┐                                                     │
│  │  background.js  │  Receives message from content script               │
│  │                 │  Forwards to native app                             │
│  └────────┬────────┘                                                     │
│           │ sendNativeMessage({ action: "trustall_web_guard", url, title })│
└───────────┼─────────────────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      Safari Web Extension (Native)                       │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────┐                                            │
│  │ SafariWebExtensionHandler│  Receives native message                   │
│  │                          │  Calls SDK to scan URL                     │
│  └────────────┬─────────────┘                                            │
│               │ webGuard.beginRequest(with: context)                     │
│               ▼                                                          │
│  ┌──────────────────────────┐                                            │
│  │   Trustall                │  Checks URL against security database      │
│  │                          │  Returns: safe/suspicious/malicious        │
│  └────────────┬─────────────┘                                            │
│               │                                                          │
│               ▼                                                          │
│  ┌──────────────────────────┐                                            │
│  │  Local Notification      │  If dangerous URL detected:                │
│  │  (Automatic)             │  "⚠️ Beware: [URL]"                        │
│  └──────────────────────────┘                                            │
└─────────────────────────────────────────────────────────────────────────┘
```

### Troubleshooting

| Issue | Solution |
|-------|----------|
| Extension not appearing in Safari | Go to Safari > Settings > Extensions and enable your extension |
| "Back to App" button not working | Make sure the URL scheme is registered in your main app's `Info.plist` |
| No notifications appearing | Check notification permissions in iOS Settings > Your App > Notifications |
| Extension crashes on load | Verify `Trustall.configure()` is called in `SafariWebExtensionHandler.init()` |

