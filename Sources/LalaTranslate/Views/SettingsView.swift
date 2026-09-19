import SwiftUI
import ServiceManagement
struct SettingsView: View {
    @StateObject private var login = LaunchAtLoginService()
    @State private var trusted = AccessibilitySelectedTextProvider.isTrusted
    @Environment(\.scenePhase) private var phase
    var body: some View {
        Form {
            Section("Translation") {
                LabeledContent("Source language", value: "Automatic")
                LabeledContent("Default target", value: "Simplified Chinese")
                LabeledContent("Chinese target", value: "English")
                Picker("Translation quality", selection: .constant("default")) {
                    Text("Low Latency · 系统默认").tag("default")
                    Text("High Fidelity · 当前 SDK 不支持").tag("high")
                }.disabled(true)
                Text("macOS 15 SDK 不提供 Strategy API，此版本使用系统默认翻译引擎。").font(.caption).foregroundStyle(.secondary)
            }
            Section("Trigger") {
                LabeledContent("Global Shortcut", value: "⌥T (Option + T)")
                Toggle("Auto Translate on Selection", isOn: .constant(false)).disabled(true)
                Text("V0.1 使用快捷键触发；自动选词和快捷键自定义已预留接口。").font(.caption).foregroundStyle(.secondary)
            }
            Section("System") {
                Toggle("Launch at Login", isOn: Binding(get: { login.enabled }, set: { login.setEnabled($0) }))
                Toggle("Show Menu Bar Icon", isOn: .constant(true)).disabled(true)
                Text("菜单栏图标始终保留，方便访问设置和退出。").font(.caption).foregroundStyle(.secondary)
                if let message = login.message { Text(message).font(.caption); Button("打开登录项设置") { SMAppService.openSystemSettingsLoginItems() } }
                HStack {
                    Label(trusted ? "辅助功能已授权" : "辅助功能未授权", systemImage: trusted ? "checkmark.circle" : "exclamationmark.circle")
                    Spacer()
                    Button("打开设置", action: AccessibilitySelectedTextProvider.openSettings)
                    Button("刷新") { trusted = AccessibilitySelectedTextProvider.isTrusted; login.refresh() }
                }
            }
            Section("Privacy") {
                Text("Translations are processed using Apple's Translation framework.")
                Text("无需账号或 API Key。不保存选中文字或译文，不读取浏览历史，不后台读取剪贴板。首次使用可能需要下载 Apple 语言模型。").font(.caption).foregroundStyle(.secondary)
            }
        }.formStyle(.grouped).frame(width: 550, height: 610)
        .onChange(of: phase) { _, value in if value == .active { trusted = AccessibilitySelectedTextProvider.isTrusted; login.refresh() } }
    }
}
