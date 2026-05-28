import SwiftUI

struct ClipboardRowView: View {
    @ObservedObject var item: ClipboardItem
    var onCopy: ((ClipboardItem) -> Void)?
    var onPaste: ((ClipboardItem) -> Void)?
    var onDelete: ((ClipboardItem) -> Void)?
    var onPin: ((ClipboardItem) -> Void)?

    @State private var isHovered = false
    @State private var isHoveringThumbnail = false

    var body: some View {
        HStack(spacing: 0) {
            contentPreview

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
        .frame(minHeight: 36)
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

    @ViewBuilder
    private var contentPreview: some View {
        switch item.contentTypeEnum {
        case .text:
            textPreview
        case .image:
            imagePreview
        case .file:
            filePreview
        }
    }

    private var textPreview: some View {
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
    }

    private var imagePreview: some View {
        HStack(spacing: 8) {
            thumbnailView
                .onHover { hovering in
                    isHoveringThumbnail = hovering
                }

            VStack(alignment: .leading, spacing: 2) {
                Text("图片")
                    .font(.system(size: 13))
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
        }
        .overlay(alignment: .topLeading) {
            if isHoveringThumbnail, let data = item.imageData, let nsImage = NSImage(data: data) {
                ImagePreviewPopover(nsImage: nsImage)
                    .offset(x: 48, y: -8)
            }
        }
    }

    private var thumbnailView: some View {
        Group {
            if let data = item.imageData, let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 40, height: 28)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
            }
        }
    }

    private var filePreview: some View {
        HStack(spacing: 8) {
            Group {
                if let name = item.fileName {
                    Image(nsImage: NSWorkspace.shared.icon(forFile: name))
                        .resizable()
                        .frame(width: 28, height: 28)
                } else {
                    Image(systemName: "doc")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .frame(width: 28, height: 28)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.content.truncated(limit: 50))
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

// MARK: - Image hover preview

private struct ImagePreviewPopover: View {
    let nsImage: NSImage

    var body: some View {
        Image(nsImage: nsImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 200, maxHeight: 200)
            .padding(4)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
    }
}
