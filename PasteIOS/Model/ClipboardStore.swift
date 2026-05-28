import CoreData
import Combine
import CryptoKit
import AppKit

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
        storeDescription.shouldMigrateStoreAutomatically = true
        storeDescription.shouldInferMappingModelAutomatically = true
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

    // MARK: - Add items

    func addItem(content: String, sourceAppBundleId: String? = nil, sourceAppName: String? = nil) {
        addTextItem(content: content, sourceAppBundleId: sourceAppBundleId, sourceAppName: sourceAppName)
    }

    func addTextItem(content: String, sourceAppBundleId: String? = nil, sourceAppName: String? = nil) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let hash = sha256(Data(trimmed.utf8))

        if let last = items.first, last.contentHash == hash, last.contentType == ClipboardContentType.text.rawValue {
            last.timestamp = Date()
            last.sourceAppBundleId = sourceAppBundleId
            last.sourceAppName = sourceAppName
            save()
            return
        }

        let item = ClipboardItem(context: container.viewContext)
        item.id = UUID()
        item.content = trimmed
        item.timestamp = Date()
        item.contentHash = hash
        item.isPinned = false
        item.contentType = ClipboardContentType.text.rawValue
        item.sourceAppBundleId = sourceAppBundleId
        item.sourceAppName = sourceAppName

        save()
        fetchItems()
        cleanupIfNeeded()
    }

    func addImageItem(data: Data, sourceAppBundleId: String? = nil, sourceAppName: String? = nil) {
        guard let image = NSImage(data: data) else { return }
        let thumbnailData = resizeImage(image, maxDimension: 300) ?? data
        let hash = sha256(thumbnailData)

        if let last = items.first, last.contentHash == hash, last.contentType == ClipboardContentType.image.rawValue {
            last.timestamp = Date()
            last.sourceAppBundleId = sourceAppBundleId
            last.sourceAppName = sourceAppName
            save()
            return
        }

        let item = ClipboardItem(context: container.viewContext)
        item.id = UUID()
        item.content = ""
        item.timestamp = Date()
        item.contentHash = hash
        item.isPinned = false
        item.contentType = ClipboardContentType.image.rawValue
        item.imageData = thumbnailData
        item.sourceAppBundleId = sourceAppBundleId
        item.sourceAppName = sourceAppName

        save()
        fetchItems()
        cleanupIfNeeded()
    }

    func addFileItem(urls: [URL], sourceAppBundleId: String? = nil, sourceAppName: String? = nil) {
        let fileURLs = urls.filter { $0.isFileURL }
        guard !fileURLs.isEmpty else { return }

        let names = fileURLs.map { $0.lastPathComponent }
        let hashSource = fileURLs.map(\.absoluteString).sorted().joined()
        let hash = sha256(Data(hashSource.utf8))

        if let last = items.first, last.contentHash == hash, last.contentType == ClipboardContentType.file.rawValue {
            last.timestamp = Date()
            last.sourceAppBundleId = sourceAppBundleId
            last.sourceAppName = sourceAppName
            save()
            return
        }

        // store one item per batch of files
        let item = ClipboardItem(context: container.viewContext)
        item.id = UUID()
        item.content = names.joined(separator: ", ")
        item.timestamp = Date()
        item.contentHash = hash
        item.isPinned = false
        item.contentType = ClipboardContentType.file.rawValue
        item.fileName = names.first
        item.sourceAppBundleId = sourceAppBundleId
        item.sourceAppName = sourceAppName

        save()
        fetchItems()
        cleanupIfNeeded()
    }

    // MARK: - Delete

    func deleteItem(_ item: ClipboardItem) {
        container.viewContext.delete(item)
        save()
        items.removeAll { $0.id == item.id }
    }

    func deleteAll() {
        let pinned = items.filter { $0.isPinned }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ClipboardItem")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? container.viewContext.execute(deleteRequest)

        // re-add pinned items preserving their type
        for item in pinned {
            switch item.contentTypeEnum {
            case .text:
                addTextItem(content: item.content)
            case .image:
                if let data = item.imageData {
                    addImageItem(data: data)
                }
            case .file:
                if let name = item.fileName {
                    // reconstruct file item from stored data
                    let restored = ClipboardItem(context: container.viewContext)
                    restored.id = UUID()
                    restored.content = item.content
                    restored.timestamp = Date()
                    restored.contentHash = sha256(Data(item.contentHash.utf8))
                    restored.isPinned = true
                    restored.contentType = ClipboardContentType.file.rawValue
                    restored.fileName = name
                    restored.sourceAppBundleId = item.sourceAppBundleId
                    restored.sourceAppName = item.sourceAppName
                }
            }
        }

        save()
        fetchItems()
    }

    // MARK: - Pin

    func pinItem(_ item: ClipboardItem) {
        item.isPinned.toggle()
        save()
        fetchItems()
    }

    // MARK: - Persistence

    func save() {
        guard container.viewContext.hasChanges else { return }
        try? container.viewContext.save()
    }

    // MARK: - Private

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

    private func sha256(_ data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func resizeImage(_ image: NSImage, maxDimension: CGFloat) -> Data? {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return nil }

        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else {
            return image.pngData
        }

        let scale = maxDimension / maxSide
        let newSize = NSSize(width: size.width * scale, height: size.height * scale)

        let resized = NSImage(size: newSize)
        resized.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: newSize),
                   from: NSRect(origin: .zero, size: size),
                   operation: .copy, fraction: 1.0)
        resized.unlockFocus()

        return resized.pngData
    }
}

private extension NSImage {
    var pngData: Data? {
        guard let tiff = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff) else { return nil }
        return bitmap.representation(using: .png, properties: [:])
    }
}
