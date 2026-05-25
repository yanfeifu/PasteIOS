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

        guard let string = pb.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !string.isEmpty else { return }

        // skip if popover is shown (user is interacting with history)
        guard !StatusBarController.shared.isPopoverShown else { return }

        store.addItem(content: string)
    }
}
