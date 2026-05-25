import CoreData

@objc(ClipboardItem)
final class ClipboardItem: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var content: String
    @NSManaged var timestamp: Date
    @NSManaged var contentHash: String
    @NSManaged var isPinned: Bool
}

extension ClipboardItem: Identifiable {
    static func entityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "ClipboardItem"
        entity.managedObjectClassName = NSStringFromClass(ClipboardItem.self)

        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false

        let contentAttr = NSAttributeDescription()
        contentAttr.name = "content"
        contentAttr.attributeType = .stringAttributeType
        contentAttr.isOptional = false

        let timestampAttr = NSAttributeDescription()
        timestampAttr.name = "timestamp"
        timestampAttr.attributeType = .dateAttributeType
        timestampAttr.isOptional = false

        let hashAttr = NSAttributeDescription()
        hashAttr.name = "contentHash"
        hashAttr.attributeType = .stringAttributeType
        hashAttr.isOptional = false

        let pinAttr = NSAttributeDescription()
        pinAttr.name = "isPinned"
        pinAttr.attributeType = .booleanAttributeType
        pinAttr.isOptional = false
        pinAttr.defaultValue = NSNumber(value: false)

        entity.properties = [idAttr, contentAttr, timestampAttr, hashAttr, pinAttr]
        return entity
    }
}
