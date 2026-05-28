import CoreData

enum ClipboardContentType: String {
    case text
    case image
    case file
}

@objc(ClipboardItem)
final class ClipboardItem: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var content: String
    @NSManaged var timestamp: Date
    @NSManaged var contentHash: String
    @NSManaged var isPinned: Bool
    @NSManaged var contentType: String
    @NSManaged var imageData: Data?
    @NSManaged var fileName: String?
    @NSManaged var sourceAppBundleId: String?
    @NSManaged var sourceAppName: String?

    var contentTypeEnum: ClipboardContentType {
        ClipboardContentType(rawValue: contentType) ?? .text
    }
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
        contentAttr.defaultValue = ""

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

        let typeAttr = NSAttributeDescription()
        typeAttr.name = "contentType"
        typeAttr.attributeType = .stringAttributeType
        typeAttr.isOptional = false
        typeAttr.defaultValue = ClipboardContentType.text.rawValue

        let imageAttr = NSAttributeDescription()
        imageAttr.name = "imageData"
        imageAttr.attributeType = .binaryDataAttributeType
        imageAttr.isOptional = true
        imageAttr.allowsExternalBinaryDataStorage = true

        let fileNameAttr = NSAttributeDescription()
        fileNameAttr.name = "fileName"
        fileNameAttr.attributeType = .stringAttributeType
        fileNameAttr.isOptional = true

        let sourceBundleAttr = NSAttributeDescription()
        sourceBundleAttr.name = "sourceAppBundleId"
        sourceBundleAttr.attributeType = .stringAttributeType
        sourceBundleAttr.isOptional = true

        let sourceNameAttr = NSAttributeDescription()
        sourceNameAttr.name = "sourceAppName"
        sourceNameAttr.attributeType = .stringAttributeType
        sourceNameAttr.isOptional = true

        entity.properties = [
            idAttr, contentAttr, timestampAttr, hashAttr, pinAttr,
            typeAttr, imageAttr, fileNameAttr,
            sourceBundleAttr, sourceNameAttr,
        ]
        return entity
    }
}
