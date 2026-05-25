import SwiftUI
import AppKit

@main
struct PasteIOSApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        ClipboardMonitor.shared.start()
        setupHotkey()

        // hide from dock - already set in Info.plist, but double ensure
        NSApp.setActivationPolicy(.accessory)
    }

    private func setupHotkey() {
        HotkeyManager.shared.onHotkeyPressed = {
            StatusBarController.shared.togglePopover()
        }
        HotkeyManager.shared.register()
    }

    func applicationWillTerminate(_ notification: Notification) {
        HotkeyManager.shared.unregister()
        ClipboardMonitor.shared.stop()
        ClipboardStore.shared.save()
    }
}
