import AppKit

final class PasteManager {
    static let shared = PasteManager()

    func copyToClipboard(item: ClipboardItem) {
        let pb = NSPasteboard.general
        pb.clearContents()

        switch item.contentTypeEnum {
        case .text:
            pb.setString(item.content, forType: .string)
        case .image:
            if let data = item.imageData {
                pb.setData(data, forType: .png)
            }
        case .file:
            if !item.content.isEmpty {
                let names = item.content.components(separatedBy: ", ")
                let urls = names.compactMap { name -> URL? in
                    // try to reconstruct file URL from recent file items
                    // search common locations
                    let searchPaths: [String] = [
                        NSHomeDirectory() + "/Desktop",
                        NSHomeDirectory() + "/Downloads",
                        NSHomeDirectory() + "/Documents",
                    ]
                    for dir in searchPaths {
                        let url = URL(fileURLWithPath: dir).appendingPathComponent(name)
                        if FileManager.default.fileExists(atPath: url.path) {
                            return url
                        }
                    }
                    return nil
                }
                if !urls.isEmpty {
                    pb.writeObjects(urls as [NSURL])
                }
            }
        }
    }

    func copyAndPaste(item: ClipboardItem) {
        copyToClipboard(item: item)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.simulatePaste()
        }
    }

    // legacy support
    func copyToClipboard(_ text: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
    }

    func copyAndPaste(_ text: String) {
        copyToClipboard(text)

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
