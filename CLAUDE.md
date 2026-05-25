# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

PasteIOS is a macOS menu bar clipboard manager (like Windows clipboard history), built with SwiftUI + AppKit. It monitors the system clipboard, stores text history, and provides a popover UI triggered by menu bar click or global shortcut `Cmd+Shift+V`.

## Build & verify

```bash
# Type-check all Swift sources (works without Xcode project)
cd PasteIOS
swiftc -typecheck -parse-as-library \
  App/PasteIOSApp.swift \
  Model/ClipboardItem.swift Model/ClipboardStore.swift \
  Service/ClipboardMonitor.swift Service/HotkeyManager.swift Service/PasteManager.swift \
  ViewModel/ClipboardListViewModel.swift ViewModel/SettingsViewModel.swift \
  View/StatusBar/StatusBarController.swift \
  View/Popover/ClipboardPopoverView.swift View/Popover/ClipboardRowView.swift View/Popover/SearchBarView.swift \
  View/Settings/SettingsView.swift \
  Util/String+Truncate.swift Util/Date+Format.swift \
  -sdk $(xcrun --show-sdk-path) \
  -target arm64-apple-macosx14.0 \
  -F /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks \
  -framework SwiftUI -framework AppKit -framework CoreData -framework Combine -framework CryptoKit

# Build in Xcode (open PasteIOS.xcodeproj)
xcodebuild -project PasteIOS.xcodeproj -scheme PasteIOS -configuration Debug build
```

## Architecture

**Pattern**: MVVM with singleton services, Combine-driven reactive data flow.

**Data flow**: `NSPasteboard` → `ClipboardMonitor` (polling) → `ClipboardStore` (CoreData) → `ClipboardListViewModel` → SwiftUI views

**Key design decisions**:
- **CoreData model is programmatic** — `ClipboardItem.entityDescription()` builds `NSEntityDescription` at runtime, no `.xcdatamodeld` file. The store lives at `~/Library/Application Support/PasteIOS/PasteIOS.sqlite`.
- **No third-party dependencies** — everything uses native Apple frameworks.
- **Clipboard polling, not event-driven** — `NSPasteboard.changeCount` is polled every 0.5s via Combine `Timer.publish`. Polling pauses while the popover is shown to avoid self-triggering.
- **Dedup via SHA256 hash** — each copied text is hashed. If identical to the most recent item, only the timestamp is bumped.
- **Global hotkey** uses `NSEvent.addGlobalMonitorForEvents(matching: .keyDown)` which requires Accessibility permissions. Paste simulation uses `CGEvent` to send `Cmd+V`.
- **Menu bar only** — `LSUIElement = YES`, `NSApp.setActivationPolicy(.accessory)`. No Dock icon. Settings are accessed via the `Settings` scene.

**Max history**: 200 items (hardcoded in `ClipboardStore`). Pinned items are preserved across "clear all". Cleanup runs on every add.

## File map

| Layer | Files | Purpose |
|-------|-------|---------|
| App | `App/PasteIOSApp.swift` | `@main` entry, `AppDelegate` bootstraps services |
| Model | `Model/ClipboardItem.swift` | `NSManagedObject` subclass + programmatic entity description |
| Model | `Model/ClipboardStore.swift` | CoreData stack, CRUD, dedup, cleanup |
| Service | `Service/ClipboardMonitor.swift` | Timer-based `NSPasteboard` polling |
| Service | `Service/HotkeyManager.swift` | `Cmd+Shift+V` global keyboard shortcut |
| Service | `Service/PasteManager.swift` | Clipboard write + `CGEvent` paste simulation |
| ViewModel | `ViewModel/ClipboardListViewModel.swift` | Search filtering, actions delegate to services |
| ViewModel | `ViewModel/SettingsViewModel.swift` | Settings persistence in `UserDefaults` |
| View | `View/StatusBar/StatusBarController.swift` | `NSStatusBar` + `NSPopover` with SwiftUI hosting |
| View | `View/Popover/ClipboardPopoverView.swift` | Main popover: search bar + scrollable history list |
| View | `View/Popover/ClipboardRowView.swift` | Single history row with hover action buttons |
| View | `View/Popover/SearchBarView.swift` | Search text field with clear button |
| View | `View/Settings/SettingsView.swift` | Settings window (history count, launch at login) |
| Util | `Util/String+Truncate.swift` | First-line truncation |
| Util | `Util/Date+Format.swift` | Chinese-locale relative date formatting |
