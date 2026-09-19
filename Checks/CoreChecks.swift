import Foundation
@main struct CoreChecks {
    @MainActor static func main() throws {
        var checks = 0
        func check(_ condition: @autoclosure () -> Bool, _ name: String) {
            guard condition() else { fatalError("FAILED: \(name)") }
            checks += 1
        }
        for (source, target) in [("en", "zh-Hans"), ("zh-Hans", "en"), ("zh-Hant", "en"), ("fr", "zh-Hans")] {
            check(LanguagePreference.target(for: source) == target, "language routing")
        }
        check(LanguagePreference.target(for: nil) == "zh-Hans", "unknown routing")
        check(LanguagePreference.source(for: "This is a translation test.") == "en", "English detection")
        check(LanguagePreference.source(for: "这是一个翻译测试。")?.hasPrefix("zh") == true, "Simplified detection")
        check(LanguagePreference.source(for: "這是一個翻譯測試。")?.hasPrefix("zh") == true, "Traditional detection")
        for value in [" \n\t", String(repeating: "字", count: 10_001)] {
            do { _ = try SelectionError.validate(value); fatalError("Invalid input accepted") }
            catch is SelectionError { checks += 1 }
        }
        let maximum = try SelectionError.validate(String(repeating: "字", count: 10_000))
        check(maximum.count == 10_000, "boundary")
        let trimmed = try SelectionError.validate(" test \n")
        check(trimmed == "test", "trimming")
        let service = TranslationService()
        service.submit("This is a translation test.")
        let first = service.request?.id
        service.submit("This is a translation test.")
        check(first == service.request?.id, "duplicate suppression")
        service.submit("这是一个翻译测试。")
        check(first != service.request?.id, "new request supersedes old")
        check(service.request?.target == "en", "request routing")
        service.showError(.noSelection)
        check(service.request == nil && !service.busy, "empty clears active request")
        check(service.message?.contains("No text selected.") == true, "empty feedback")
        service.showError(.permissionRequired)
        check(service.needsPermission && service.result == nil, "permission feedback")
        service.submit("Hello world")
        check(!service.needsPermission, "permission state reset")
        service.cancel()
        check(service.request == nil && !service.busy, "cancel")
        print("PASS: \(checks) core checks")
    }
}
