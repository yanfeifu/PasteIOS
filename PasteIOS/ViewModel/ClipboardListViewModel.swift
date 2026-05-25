import Foundation
import Combine

final class ClipboardListViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var items: [ClipboardItem] = []

    private let store = ClipboardStore.shared
    private var cancellables = Set<AnyCancellable>()

    var filteredItems: [ClipboardItem] {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { return items }
        return items.filter { $0.content.localizedCaseInsensitiveContains(text) }
    }

    init() {
        store.$items
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
            .store(in: &cancellables)
    }

    func copyItem(_ item: ClipboardItem) {
        PasteManager.shared.copyToClipboard(item.content)
        // bump timestamp so it moves to top
        item.timestamp = Date()
        store.save()
    }

    func copyAndPaste(_ item: ClipboardItem) {
        PasteManager.shared.copyAndPaste(item.content)
        item.timestamp = Date()
        store.save()
    }

    func deleteItem(_ item: ClipboardItem) {
        store.deleteItem(item)
    }

    func togglePin(_ item: ClipboardItem) {
        store.pinItem(item)
    }

    func clearAll() {
        store.deleteAll()
    }
}
