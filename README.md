# PasteIOS

macOS 菜单栏剪贴板管理器，类似 Windows 的剪贴板历史。

## 功能

- 自动监控系统剪贴板（0.5s 轮询）
- 支持文本、图片（PNG/TIFF）、文件三种剪贴板类型
- 记录每个条目的复制来源应用，显示应用图标
- 文本/图片悬停预览弹窗，图片支持 800x800 大尺寸预览
- 菜单栏图标 + Popover 弹窗显示历史列表
- 全局快捷键 `Cmd+Shift+V` 弹出剪贴板历史
- 搜索过滤历史记录
- 点击条目复制到剪贴板并粘贴到前台应用
- SHA256 按类型去重（连续相同内容仅更新时间戳）
- 最多保存 200 条记录，可固定重要条目
- 菜单栏 App，无 Dock 图标

## 技术栈

SwiftUI + AppKit / MVVM / CoreData / Combine / 零第三方依赖

## 项目结构

```
PasteIOS/
├── App/PasteIOSApp.swift          # @main 入口 + AppDelegate
├── Model/
│   ├── ClipboardItem.swift        # CoreData 实体（程序化构建）
│   └── ClipboardStore.swift       # 持久化存储 CRUD
├── Service/
│   ├── ClipboardMonitor.swift     # NSPasteboard 轮询
│   ├── HotkeyManager.swift        # Carbon 全局快捷键
│   └── PasteManager.swift         # 剪贴板写入 + CGEvent 粘贴
├── ViewModel/
│   ├── ClipboardListViewModel.swift
│   └── SettingsViewModel.swift
├── View/
│   ├── StatusBar/StatusBarController.swift  # NSStatusBar + NSPopover
│   ├── Popover/                            # 主界面（列表、行、搜索）
│   └── Settings/SettingsView.swift
├── Util/
│   ├── String+Truncate.swift
│   └── Date+Format.swift
└── Resources/
    ├── Info.plist
    ├── PasteIOS.entitlements
    └── Assets.xcassets
```

## 构建

项目使用 XcodeGen 管理，修改源文件后无需手动调整 pbxproj。

```bash
# 生成/更新 Xcode 项目
xcodegen generate

# 命令行构建
xcodebuild -project PasteIOS.xcodeproj -scheme PasteIOS -configuration Debug build
```

## 系统要求

macOS 14.0+
