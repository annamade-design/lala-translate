import AppKit
@MainActor
enum MenuBarView {
    static func menu(target: AppDelegate) -> NSMenu {
        let menu = NSMenu()
        let translate = menu.addItem(withTitle: "Translate Selected Text  ⌥T", action: #selector(AppDelegate.trigger), keyEquivalent: "")
        translate.target = target
        let settings = menu.addItem(withTitle: "Settings…", action: #selector(AppDelegate.openSettings), keyEquivalent: ",")
        settings.target = target
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Lala Translate", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        return menu
    }
}
