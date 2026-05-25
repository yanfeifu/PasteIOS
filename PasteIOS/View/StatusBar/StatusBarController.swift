import AppKit
import SwiftUI

final class StatusBarController: NSObject, NSPopoverDelegate {
    static let shared = StatusBarController()

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!

    var isPopoverShown: Bool { popover?.isShown ?? false }

    override init() {
        super.init()
        setupStatusBar()
        setupPopover()
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "doc.on.clipboard",
                accessibilityDescription: "PasteIOS"
            )
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 480)
        popover.behavior = .transient
        popover.delegate = self
        popover.contentViewController = NSHostingController(
            rootView: ClipboardPopoverView()
        )
    }

    @objc func togglePopover() {
        if popover.isShown {
            popover.close()
        } else {
            if let button = statusItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }

    func popoverWillShow(_ notification: Notification) {
        // pause monitoring during interaction to avoid self-triggering
    }

    func popoverDidClose(_ notification: Notification) {
        NSApp.hide(self)
    }
}
