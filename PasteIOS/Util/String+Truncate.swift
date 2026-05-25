import Foundation

extension String {
    func truncated(limit: Int = 80) -> String {
        let firstLine = self.components(separatedBy: .newlines).first ?? self
        if firstLine.count <= limit {
            return firstLine
        }
        return String(firstLine.prefix(limit)) + "..."
    }
}
