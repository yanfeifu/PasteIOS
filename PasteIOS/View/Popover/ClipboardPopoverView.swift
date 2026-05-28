import SwiftUI

struct ClipboardPopoverView: View {
    @StateObject private var viewModel = ClipboardListViewModel()

    var body: some View {
        VStack(spacing: 0) {
            SearchBarView(text: $viewModel.searchText)
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 8)

            Divider()

            if viewModel.filteredItems.isEmpty {
                emptyView
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.filteredItems) { item in
                            ClipboardRowView(
                                item: item,
                                onCopy: { viewModel.copyItem($0) },
                                onPaste: { viewModel.copyAndPaste($0) },
                                onDelete: { viewModel.deleteItem($0) },
                                onPin: { viewModel.togglePin($0) }
                            )

                            Divider()
                                .padding(.leading, 12)
                        }
                    }
                }
            }

            Divider()

            bottomBar
        }
        .frame(width: 360, height: 480)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.5))
            Text("暂无剪贴板历史")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Text("复制文本、图片或文件后自动出现在这里")
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var bottomBar: some View {
        HStack {
            Button(action: { viewModel.clearAll() }) {
                Label("清空历史", systemImage: "trash")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)

            Spacer()

            Text("\(viewModel.filteredItems.count) 条记录")
                .font(.system(size: 10))
                .foregroundColor(.secondary)

            Spacer()

            Button(action: openSettings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .help("设置")

            Button(action: { NSApp.terminate(nil) }) {
                Image(systemName: "power")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .help("退出")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func openSettings() {
        if #available(macOS 14.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
}
