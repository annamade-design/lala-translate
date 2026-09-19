import AppKit
import ApplicationServices
struct AccessibilitySelectedTextProvider: SelectedTextProvider {
    static var isTrusted: Bool { AXIsProcessTrusted() }

    @discardableResult
    static func requestPermission() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    static func openSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
    func selectedText(processID: Int32?) throws -> String {
        guard Self.isTrusted else { throw SelectionError.permissionRequired }
        let root = processID.map(AXUIElementCreateApplication) ?? AXUIElementCreateSystemWide()
        AXUIElementSetMessagingTimeout(root, 0.6)
        var focused: CFTypeRef?
        let focusStatus = AXUIElementCopyAttributeValue(root, kAXFocusedUIElementAttribute as CFString, &focused)
        guard focusStatus == .success, let focused, CFGetTypeID(focused) == AXUIElementGetTypeID() else {
            throw SelectionError.unavailable
        }
        let element = focused as! AXUIElement
        var value: CFTypeRef?
        let status = AXUIElementCopyAttributeValue(element, kAXSelectedTextAttribute as CFString, &value)
        if status == .attributeUnsupported || status == .notImplemented { throw SelectionError.unsupported }
        if status == .noValue { throw SelectionError.noSelection }
        guard status == .success else { throw SelectionError.unavailable }
        guard let text = value as? String else { throw SelectionError.noSelection }
        return try SelectionError.validate(text)
    }
}
