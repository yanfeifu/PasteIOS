import AppKit

final class PasteManager {
    static let shared = PasteManager()

    func copyToClipboard(_ text: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
    }

    func copyAndPaste(_ text: String) {
        copyToClipboard(text)

        // brief delay to ensure pasteboard is updated before pasting
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.simulatePaste()
        }
    }

    private func simulatePaste() {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }

        let cmdKey: CGKeyCode = 0x37
        let vKey: CGKeyCode = 9

        let events: [(CGEvent?, CGEventFlags)] = [
            (CGEvent(keyboardEventSource: source, virtualKey: cmdKey, keyDown: true), []),
            (CGEvent(keyboardEventSource: source, virtualKey: vKey, keyDown: true), .maskCommand),
            (CGEvent(keyboardEventSource: source, virtualKey: vKey, keyDown: false), .maskCommand),
            (CGEvent(keyboardEventSource: source, virtualKey: cmdKey, keyDown: false), []),
        ]

        for (event, flags) in events {
            event?.flags = flags
            event?.post(tap: .cghidEventTap)
            Thread.sleep(forTimeInterval: 0.01)
        }
    }
}
