import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("通用", systemImage: "gearshape")
                }

            aboutTab
                .tabItem {
                    Label("关于", systemImage: "info.circle")
                }
        }
        .frame(width: 400, height: 250)
    }

    private var generalTab: some View {
        Form {
            Section {
                Picker("最大历史条数", selection: $viewModel.maxHistoryCount) {
                    Text("50").tag(50)
                    Text("100").tag(100)
                    Text("200").tag(200)
                    Text("500").tag(500)
                }
                .pickerStyle(.segmented)
            } header: {
                Text("历史记录")
            }

            Section {
                Toggle("登录时自动启动", isOn: $viewModel.launchAtLogin)
            } header: {
                Text("启动")
            }

            Section {
                HStack {
                    Text("全局快捷键")
                    Spacer()
                    Text("⌘⇧V")
                        .foregroundColor(.secondary)
                        .font(.system(.body, design: .monospaced))
                }
            } header: {
                Text("快捷键（后续版本支持自定义）")
            }
        }
        .formStyle(.grouped)
    }

    private var aboutTab: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)

            Text("PasteIOS")
                .font(.title2)

            Text("版本 1.1")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("macOS 剪贴板管理工具")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding(.top, 32)
        .frame(maxWidth: .infinity)
    }
}
