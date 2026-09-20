import SwiftUI
import ServiceManagement
import Carbon
struct SettingsView: View {
    @StateObject private var login = LaunchAtLoginService()
    @State private var trusted = AccessibilitySelectedTextProvider.isTrusted
    @State private var shortcutLabel = ShortcutService.shared.configuration.displayName
    @State private var recordingShortcut = false
    @State private var shortcutError: String?
    @State private var shortcutMonitor: Any?
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
                HStack {
                    LabeledContent("Global Shortcut", value: shortcutLabel)
                    Button(recordingShortcut ? "Press a shortcut…" : "Change…") {
                        shortcutError = nil
                        recordingShortcut = true
                    }.disabled(recordingShortcut)
                    Button("Reset") { setShortcut(.default) }.disabled(recordingShortcut)
                }
                if let shortcutError { Text(shortcutError).font(.caption).foregroundStyle(.red) }
                LabeledContent("Auto Translate on Selection", value: "Coming later")
                Text("Automatic translation on selection is not available yet.").font(.caption).foregroundStyle(.secondary)
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
        .onAppear {
            shortcutLabel = ShortcutService.shared.configuration.displayName
            shortcutMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                guard recordingShortcut else { return event }
                if Int(event.keyCode) == kVK_Escape {
                    recordingShortcut = false
                    return nil
                }
                guard let configuration = ShortcutConfiguration(event: event) else {
                    shortcutError = "Include Command, Option, Control, or Shift."
                    return nil
                }
                setShortcut(configuration)
                recordingShortcut = false
                return nil
            }
        }
        .onDisappear {
            if let shortcutMonitor { NSEvent.removeMonitor(shortcutMonitor); self.shortcutMonitor = nil }
            recordingShortcut = false
        }
        .onChange(of: phase) { _, value in if value == .active { trusted = AccessibilitySelectedTextProvider.isTrusted; login.refresh() } }
    }

    private func setShortcut(_ configuration: ShortcutConfiguration) {
        if ShortcutService.shared.change(to: configuration) {
            shortcutLabel = ShortcutService.shared.configuration.displayName
            shortcutError = nil
        } else {
            shortcutError = "Shortcut is already in use."
        }
    }
}
