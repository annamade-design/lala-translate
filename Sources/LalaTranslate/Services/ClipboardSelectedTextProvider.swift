import AppKit
import CoreGraphics

/// Used only after the user explicitly invokes Translate Selected Text and AX fails.
struct ClipboardSelectedTextProvider: SelectedTextProvider {
    func selectedText(processID: Int32?) throws -> String {
        guard let processID else { throw SelectionError.unavailable }

        let pasteboard = NSPasteboard.general
        let savedItems = (pasteboard.pasteboardItems ?? []).map { item in
            item.types.compactMap { type -> (NSPasteboard.PasteboardType, Data)? in
                guard let data = item.data(forType: type) else { return nil }
                return (type, data)
            }
        }
        let originalChangeCount = pasteboard.changeCount

        // A copy may replace the pasteboard even when it produces no text.
        // Restore all readable item types on every path that changes it.
        defer {
            if pasteboard.changeCount != originalChangeCount {
                pasteboard.clearContents()
                let items = savedItems.map { saved -> NSPasteboardItem in
                    let item = NSPasteboardItem()
                    for (type, data) in saved { item.setData(data, forType: type) }
                    return item
                }
                if !items.isEmpty { pasteboard.writeObjects(items) }
            }
        }

        guard let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: 8, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: 8, keyDown: false) else {
            throw SelectionError.unavailable
        }
        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand
        keyDown.postToPid(processID)
        keyUp.postToPid(processID)

        let deadline = Date().addingTimeInterval(0.4)
        while pasteboard.changeCount == originalChangeCount && Date() < deadline {
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.01))
        }
        guard pasteboard.changeCount != originalChangeCount,
              let text = pasteboard.string(forType: .string) else {
            throw SelectionError.noSelection
        }
        return try SelectionError.validate(text)
    }
}
