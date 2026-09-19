import Carbon
struct ShortcutConfiguration {
    var keyCode: UInt32 = UInt32(kVK_ANSI_T)
    var modifiers: UInt32 = UInt32(optionKey)
}
final class ShortcutService {
    private var hotKey: EventHotKeyRef?
    private var handler: EventHandlerRef?
    var onTrigger: (() -> Void)?
    func register(_ configuration: ShortcutConfiguration = .init()) -> Bool {
        if let hotKey { UnregisterEventHotKey(hotKey); self.hotKey = nil }
        if handler == nil {
            var event = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
            let result = InstallEventHandler(GetApplicationEventTarget(), { _, _, context in
                guard let context else { return OSStatus(eventNotHandledErr) }
                Unmanaged<ShortcutService>.fromOpaque(context).takeUnretainedValue().onTrigger?()
                return noErr
            }, 1, &event, Unmanaged.passUnretained(self).toOpaque(), &handler)
            guard result == noErr else { return false }
        }
        return RegisterEventHotKey(configuration.keyCode, configuration.modifiers,
            EventHotKeyID(signature: 0x4C414C41, id: 1), GetApplicationEventTarget(), 0, &hotKey) == noErr
    }
    deinit {
        if let hotKey { UnregisterEventHotKey(hotKey) }
        if let handler { RemoveEventHandler(handler) }
    }
}
