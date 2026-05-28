import AppKit
import Combine

final class ClipboardMonitor: ObservableObject {
    static let shared = ClipboardMonitor()

    private let store = ClipboardStore.shared
    private var lastChangeCount = NSPasteboard.general.changeCount
    private var cancellables = Set<AnyCancellable>()
    private var isRunning = false

    func start() {
        guard !isRunning else { return }
        isRunning = true

        Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.check()
            }
            .store(in: &cancellables)
    }

    func stop() {
        isRunning = false
        cancellables.removeAll()
    }

    private func check() {
        let pb = NSPasteboard.general
        guard pb.changeCount != lastChangeCount else { return }
        lastChangeCount = pb.changeCount

        guard !StatusBarController.shared.isPopoverShown else { return }

        // 1. check for image
        let imageTypes: [NSPasteboard.PasteboardType] = [.png, .tiff]
        if let matchedType = pb.availableType(from: imageTypes),
           let data = pb.data(forType: matchedType) {
            store.addImageItem(data: data)
            return
        }

        // 2. check for file URLs
        if let urls = pb.readObjects(forClasses: [NSURL.self],
                                     options: [.urlReadingFileURLsOnly: true]) as? [URL],
           !urls.isEmpty {
            store.addFileItem(urls: urls)
            return
        }

        // 3. check for text
        if let string = pb.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines),
           !string.isEmpty {
            store.addItem(content: string)
        }
    }
}
