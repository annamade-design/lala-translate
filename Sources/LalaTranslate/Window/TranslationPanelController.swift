import AppKit
import SwiftUI
final class TranslationPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
@MainActor
final class TranslationPanelController {
    let panel: TranslationPanel
    let service: TranslationService
    let speech = SpeechService()
    var pinned = false
    var dismissalMonitor: Any?
    init(service: TranslationService) {
        self.service = service
        panel = TranslationPanel(contentRect: NSRect(x: 0, y: 0, width: 400, height: 360), styleMask: [.titled, .fullSizeContentView, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.titleVisibility = .hidden; panel.titlebarAppearsTransparent = true
        panel.isFloatingPanel = true; panel.level = .floating; panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = true; panel.isReleasedWhenClosed = false
        panel.contentView = NSHostingView(rootView: TranslationPanelView(service: service, close: { [weak self] in self?.close() }, togglePin: { [weak self] value in self?.pinned = value }, speech: speech))
        dismissalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            guard let self, !self.pinned, !self.service.busy else { return }
            self.close()
        }
    }
    func show() {
        if pinned && panel.isVisible { panel.orderFrontRegardless(); return }
        let point = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { $0.frame.contains(point) } ?? NSScreen.main
        if let frame = screen?.visibleFrame {
            let x = max(frame.minX + 8, min(point.x + 14, frame.maxX - panel.frame.width - 8))
            let y = max(frame.minY + 8, min(point.y - panel.frame.height - 14, frame.maxY - panel.frame.height - 8))
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }
        panel.orderFrontRegardless()
    }
    func close() { speech.stop(); service.cancel(); panel.orderOut(nil) }
}
