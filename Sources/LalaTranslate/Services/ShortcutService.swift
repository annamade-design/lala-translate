import AppKit
import Carbon

struct ShortcutConfiguration: Equatable {
    static let `default` = ShortcutConfiguration(keyCode: UInt32(kVK_ANSI_T), modifiers: UInt32(optionKey), key: "T")
    private static let allowedModifiers = UInt32(cmdKey | optionKey | controlKey | shiftKey)
    private static let defaultsKey = "globalShortcut"

    let keyCode: UInt32
    let modifiers: UInt32
    let key: String

    var isValid: Bool {
        keyCode < 128 && !key.isEmpty && modifiers & Self.allowedModifiers != 0 && modifiers & ~Self.allowedModifiers == 0
    }

    var displayName: String {
        var name = ""
        if modifiers & UInt32(controlKey) != 0 { name += "⌃" }
        if modifiers & UInt32(optionKey) != 0 { name += "⌥" }
        if modifiers & UInt32(shiftKey) != 0 { name += "⇧" }
        if modifiers & UInt32(cmdKey) != 0 { name += "⌘" }
        return name + key
    }

    init(keyCode: UInt32, modifiers: UInt32, key: String) {
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.key = key
    }

    init?(event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        var modifiers: UInt32 = 0
        if flags.contains(.command) { modifiers |= UInt32(cmdKey) }
        if flags.contains(.option) { modifiers |= UInt32(optionKey) }
        if flags.contains(.control) { modifiers |= UInt32(controlKey) }
        if flags.contains(.shift) { modifiers |= UInt32(shiftKey) }

        let key: String
        switch Int(event.keyCode) {
        case kVK_Space: key = "Space"
        case kVK_Return: key = "Return"
        case kVK_Tab: key = "Tab"
        case kVK_Delete: key = "Delete"
        case kVK_ForwardDelete: key = "Forward Delete"
        case kVK_LeftArrow: key = "←"
        case kVK_RightArrow: key = "→"
        case kVK_UpArrow: key = "↑"
        case kVK_DownArrow: key = "↓"
        default:
            guard let character = event.charactersIgnoringModifiers?.uppercased(), !character.isEmpty else { return nil }
            key = character
        }
        self.init(keyCode: UInt32(event.keyCode), modifiers: modifiers, key: key)
        guard isValid else { return nil }
    }

    static func saved() -> ShortcutConfiguration? {
        guard let values = UserDefaults.standard.dictionary(forKey: defaultsKey),
              let keyCode = values["keyCode"] as? NSNumber,
              let modifiers = values["modifiers"] as? NSNumber,
              let key = values["key"] as? String else { return nil }
        let configuration = ShortcutConfiguration(keyCode: keyCode.uint32Value, modifiers: modifiers.uint32Value, key: key)
        return configuration.isValid ? configuration : nil
    }

    func save() {
        UserDefaults.standard.set(["keyCode": keyCode, "modifiers": modifiers, "key": key], forKey: Self.defaultsKey)
    }
}

final class ShortcutService {
    static let shared = ShortcutService()
    private var hotKey: EventHotKeyRef?
    private var handler: EventHandlerRef?
    private var nextID: UInt32 = 1
    private(set) var configuration = ShortcutConfiguration.saved() ?? .default
    var onTrigger: (() -> Void)?
    var onShortcutChange: ((ShortcutConfiguration) -> Void)?

    func register() -> Bool {
        if registerHotKey(configuration) { return true }
        guard configuration != .default, registerHotKey(.default) else { return false }
        configuration = .default
        configuration.save()
        onShortcutChange?(configuration)
        return true
    }

    func change(to newConfiguration: ShortcutConfiguration) -> Bool {
        guard newConfiguration.isValid else { return false }
        if newConfiguration.keyCode == configuration.keyCode && newConfiguration.modifiers == configuration.modifiers { return true }
        guard registerHotKey(newConfiguration) else { return false }
        configuration = newConfiguration
        configuration.save()
        onShortcutChange?(configuration)
        return true
    }

    private func registerHotKey(_ newConfiguration: ShortcutConfiguration) -> Bool {
        if handler == nil {
            var event = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
            let result = InstallEventHandler(GetApplicationEventTarget(), { _, _, context in
                guard let context else { return OSStatus(eventNotHandledErr) }
                Unmanaged<ShortcutService>.fromOpaque(context).takeUnretainedValue().onTrigger?()
                return noErr
            }, 1, &event, Unmanaged.passUnretained(self).toOpaque(), &handler)
            guard result == noErr else { return false }
        }
        var replacement: EventHotKeyRef?
        let result = RegisterEventHotKey(newConfiguration.keyCode, newConfiguration.modifiers,
            EventHotKeyID(signature: 0x4C414C41, id: nextID), GetApplicationEventTarget(), 0, &replacement)
        guard result == noErr, let replacement else { return false }
        nextID &+= 1
        if let hotKey { UnregisterEventHotKey(hotKey) }
        hotKey = replacement
        return true
    }

    deinit {
        if let hotKey { UnregisterEventHotKey(hotKey) }
        if let handler { RemoveEventHandler(handler) }
    }
}
