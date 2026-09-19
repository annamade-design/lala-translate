import XCTest
@testable import LalaTranslate
final class CoreTests: XCTestCase {
    func testRouting() {
        XCTAssertEqual(LanguagePreference.target(for: "en"), "zh-Hans")
        XCTAssertEqual(LanguagePreference.target(for: "zh-Hans"), "en")
        XCTAssertEqual(LanguagePreference.target(for: "zh-Hant"), "en")
        XCTAssertEqual(LanguagePreference.target(for: "fr"), "zh-Hans")
        XCTAssertEqual(LanguagePreference.target(for: nil), "zh-Hans")
    }
    func testRealLanguageDetection() {
        XCTAssertEqual(LanguagePreference.source(for: "This is a translation test."), "en")
        XCTAssertTrue(LanguagePreference.source(for: "这是一个翻译测试。")?.hasPrefix("zh") == true)
        XCTAssertTrue(LanguagePreference.source(for: "這是一個翻譯測試。")?.hasPrefix("zh") == true)
    }
    func testInputBoundaries() throws {
        XCTAssertThrowsError(try SelectionError.validate(" \n\t"))
        XCTAssertThrowsError(try SelectionError.validate(String(repeating: "字", count: 10_001)))
        XCTAssertEqual(try SelectionError.validate(String(repeating: "字", count: 10_000)).count, 10_000)
        XCTAssertEqual(try SelectionError.validate(" test \n"), "test")
    }
    @MainActor func testRepeatedAndSupersededRequests() {
        let service = TranslationService()
        service.submit("This is a translation test.")
        let first = service.request?.id
        service.submit("This is a translation test.")
        XCTAssertEqual(first, service.request?.id)
        service.submit("这是一个翻译测试。")
        XCTAssertNotEqual(first, service.request?.id)
        XCTAssertEqual(service.request?.target, "en")
        service.showError(.noSelection)
        XCTAssertNil(service.request)
        XCTAssertFalse(service.busy)
        XCTAssertTrue(service.message?.contains("No text selected.") == true)
    }
    @MainActor func testPermissionFailureAndCancel() {
        let service = TranslationService()
        service.submit("Hello world")
        service.showError(.permissionRequired)
        XCTAssertTrue(service.needsPermission)
        XCTAssertNil(service.result)
        XCTAssertNil(service.request)
        service.submit("Hello world")
        XCTAssertFalse(service.needsPermission)
        service.cancel()
        XCTAssertFalse(service.busy)
        XCTAssertNil(service.request)
    }
}
