# Session Summary - 2026/05/25

## 项目

PasteIOS - macOS 菜单栏剪贴板管理器

## 技术栈

SwiftUI + AppKit / MVVM / CoreData (程序化模型) / Combine / 零第三方依赖

## 已完成

- [x] 项目目录结构搭建
- [x] 15 个 Swift 源文件编写并通过 `swiftc -typecheck` 类型检查
  - App 入口 + AppDelegate（菜单栏启动、服务初始化）
  - Model 层：CoreData 实体（程序化 `NSEntityDescription`）+ ClipboardStore（CRUD、SHA256 去重、200条上限、固定项保护）
  - Service 层：ClipboardMonitor（0.5s 轮询）、HotkeyManager（Cmd+Shift+V）、PasteManager（CGEvent 粘贴）
  - ViewModel 层：ClipboardListViewModel（搜索过滤）、SettingsViewModel
  - View 层：StatusBarController（NSStatusBar + NSPopover）、ClipboardPopoverView、ClipboardRowView、SearchBarView、SettingsView
  - Util 层：文本截断、中文相对时间格式化
- [x] 资源文件：Info.plist（LSUIElement=YES）、entitlements、Assets.xcassets
- [x] CLAUDE.md 项目文档
- [x] **Xcode 项目构建修复**：手写 pbxproj 在 Xcode 26.5 下解析失败，改用 XcodeGen (`project.yml`) 生成项目文件，`xcodebuild` 构建成功。旧 pbxproj 备份为 `project.pbxproj.bak`。
- [x] **快捷键修复**：`NSEvent.addGlobalMonitorForEvents` 需要辅助功能权限，改用 Carbon `RegisterEventHotKey` API 注册全局 Cmd+Shift+V 热键，无需额外权限。
- [x] **功能验证**：App 启动、菜单栏图标、剪贴板监控、Popover 弹窗、Cmd+Shift+V 弹出、搜索过滤均通过。

## 项目文件路径

- 源文件：`PasteIOS/PasteIOS/` 下按 App/Model/Service/ViewModel/View/Util 分层
- Xcode 项目由 `project.yml` (XcodeGen) 生成，修改后运行 `xcodegen generate` 重新生成

## 下次可继续

1. 构建运行，验证菜单栏图标、剪贴板监控、粘贴功能
2. 第二阶段：图片/文件支持、iCloud 同步、快捷键自定义
