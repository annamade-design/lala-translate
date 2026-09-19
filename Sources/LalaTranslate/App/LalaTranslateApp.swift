import SwiftUI
import AppKit
@main
struct LalaTranslateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene { Settings { SettingsView() } }
}
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let translation = TranslationService()
    let shortcut = ShortcutService()
    var panel: TranslationPanelController!
    var statusItem: NSStatusItem!
    var previousApplication: NSRunningApplication?
    var observer: NSObjectProtocol?
    var settingsWindow: NSWindow?
    private var didRequestAccessibilityPermission = false
    private var isHandlingSelection = false
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        panel = TranslationPanelController(service: translation)
        previousApplication = NSWorkspace.shared.frontmostApplication
        observer = NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { [weak self] notice in
            guard let app = notice.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication, app.processIdentifier != ProcessInfo.processInfo.processIdentifier else { return }
            MainActor.assumeIsolated { self?.previousApplication = app }
        }
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "character.bubble", accessibilityDescription: "Lala Translate")
        statusItem.menu = MenuBarView.menu(target: self)
        shortcut.onTrigger = { [weak self] in self?.trigger() }
        if !shortcut.register() { translation.message = "⌥T 已被其他应用占用，请释放快捷键后重新启动。"; panel.show() }
        if !AccessibilitySelectedTextProvider.isTrusted {
            requestAccessibilityPermissionOnce()
            translation.showError(.permissionRequired)
            panel.show()
        }
        // Fixed public fixtures only; no user text is accepted through command-line arguments.
        if ProcessInfo.processInfo.arguments.contains("--translation-smoke-test") {
            translation.submit("Start automatically when logging in")
            panel.show()
        }
        if ProcessInfo.processInfo.arguments.contains("--settings-smoke-test") { openSettings() }
    }
    @objc func openSettings() {
        if settingsWindow == nil {
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 550, height: 610), styleMask: [.titled, .closable], backing: .buffered, defer: false)
            window.title = "Lala Translate · Settings"
            window.contentView = NSHostingView(rootView: SettingsView())
            window.isReleasedWhenClosed = false
            window.center()
            settingsWindow = window
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }
    private func requestAccessibilityPermissionOnce() {
        guard !didRequestAccessibilityPermission else { return }
        didRequestAccessibilityPermission = true
        AccessibilitySelectedTextProvider.requestPermission()
    }
    @objc func trigger() {
        guard !isHandlingSelection else { return }
        isHandlingSelection = true
        defer { isHandlingSelection = false }
        let frontmost = NSWorkspace.shared.frontmostApplication
        let app = frontmost?.processIdentifier == ProcessInfo.processInfo.processIdentifier ? previousApplication : frontmost
        do {
            let text: String
            do {
                text = try AccessibilitySelectedTextProvider().selectedText(processID: app?.processIdentifier)
            } catch {
                let originalError = error
                do {
                    text = try ClipboardSelectedTextProvider().selectedText(processID: app?.processIdentifier)
                } catch {
                    throw originalError
                }
            }
            translation.submit(text)
        }
        catch let error as SelectionError { translation.showError(error) }
        catch { translation.showError(.unavailable) }
        panel.show()
    }
}
