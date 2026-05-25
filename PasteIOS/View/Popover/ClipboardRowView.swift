import SwiftUI

struct ClipboardRowView: View {
    @ObservedObject var item: ClipboardItem
    var onCopy: ((ClipboardItem) -> Void)?
    var onPaste: ((ClipboardItem) -> Void)?
    var onDelete: ((ClipboardItem) -> Void)?
    var onPin: ((ClipboardItem) -> Void)?

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.content.truncated(limit: 60))
                    .font(.system(size: 13))
                    .lineLimit(1)
                    .foregroundColor(.primary)

                HStack(spacing: 4) {
                    if item.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.orange)
                    }
                    Text(item.timestamp.relativeDisplay)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if isHovered {
                HStack(spacing: 6) {
                    actionButton(icon: "doc.on.doc", help: "复制") {
                        onCopy?(item)
                    }
                    actionButton(icon: "arrow.turn.down.left", help: "粘贴") {
                        onPaste?(item)
                    }
                    actionButton(icon: item.isPinned ? "pin.slash" : "pin", help: item.isPinned ? "取消固定" : "固定") {
                        onPin?(item)
                    }
                    actionButton(icon: "trash", help: "删除") {
                        onDelete?(item)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .contextMenu {
            Button("复制") { onCopy?(item) }
            Button("粘贴") { onPaste?(item) }
            Divider()
            Button(item.isPinned ? "取消固定" : "固定") { onPin?(item) }
            Divider()
            Button("删除") { onDelete?(item) }
        }
    }

    private func actionButton(icon: String, help: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .frame(width: 20, height: 20)
        }
        .buttonStyle(.plain)
        .help(help)
    }
}
