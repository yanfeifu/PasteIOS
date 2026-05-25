import CoreData
import Combine
import CryptoKit

final class ClipboardStore: ObservableObject {
    static let shared = ClipboardStore()

    @Published var items: [ClipboardItem] = []

    private let container: NSPersistentContainer
    private let maxItems = 200

    init() {
        let model = NSManagedObjectModel()
        model.entities = [ClipboardItem.entityDescription()]

        container = NSPersistentContainer(name: "PasteIOS", managedObjectModel: model)

        let storeURL = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/PasteIOS")
        try? FileManager.default.createDirectory(at: storeURL, withIntermediateDirectories: true)

        let storeDescription = NSPersistentStoreDescription(url: storeURL.appendingPathComponent("PasteIOS.sqlite"))
        container.persistentStoreDescriptions = [storeDescription]

        container.loadPersistentStores { _, error in
            if let error = error {
                print("CoreData failed: \(error.localizedDescription)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        fetchItems()
        cleanupIfNeeded()
    }

    func addItem(content: String) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let hash = contentHash(trimmed)

        // dedup: skip if same as most recent item
        if let last = items.first, last.contentHash == hash {
            last.timestamp = Date()
            save()
            return
        }

        let item = ClipboardItem(context: container.viewContext)
        item.id = UUID()
        item.content = trimmed
        item.timestamp = Date()
        item.contentHash = hash
        item.isPinned = false

        save()
        fetchItems()
        cleanupIfNeeded()
    }

    func deleteItem(_ item: ClipboardItem) {
        container.viewContext.delete(item)
        save()
        fetchItems()
    }

    func deleteAll() {
        let pinned = items.filter { $0.isPinned }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ClipboardItem")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? container.viewContext.execute(deleteRequest)

        // re-add pinned items
        for item in pinned {
            addItem(content: item.content)
        }

        save()
        fetchItems()
    }

    func pinItem(_ item: ClipboardItem) {
        item.isPinned.toggle()
        save()
        fetchItems()
    }

    func save() {
        guard container.viewContext.hasChanges else { return }
        try? container.viewContext.save()
    }

    private func fetchItems() {
        let request = NSFetchRequest<ClipboardItem>(entityName: "ClipboardItem")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = maxItems

        items = (try? container.viewContext.fetch(request)) ?? []
    }

    private func cleanupIfNeeded() {
        guard items.count > maxItems else { return }
        let pinned = items.filter { $0.isPinned }
        let unpinned = items.filter { !$0.isPinned }

        if unpinned.count > maxItems {
            let toDelete = unpinned.suffix(unpinned.count - maxItems + pinned.count)
            for item in toDelete {
                container.viewContext.delete(item)
            }
            save()
            fetchItems()
        }
    }

    private func contentHash(_ text: String) -> String {
        let data = Data(text.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
