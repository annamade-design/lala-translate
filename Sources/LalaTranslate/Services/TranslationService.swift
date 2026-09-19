import SwiftUI
import Translation
@MainActor
final class TranslationService: ObservableObject {
    @Published var request: TranslationRequest?
    @Published var result: TranslationResult?
    @Published var message: String?
    @Published var busy = false
    @Published var needsPermission = false
    func submit(_ text: String) {
        if busy, request?.text == text { return }
        let source = LanguagePreference.source(for: text)
        result = nil; message = nil; needsPermission = false; busy = true
        request = TranslationRequest(text: text, source: source, target: LanguagePreference.target(for: source))
    }
    func showError(_ error: SelectionError) {
        cancel(); result = nil; message = error.message
        needsPermission = if case .permissionRequired = error { true } else { false }
    }
    func cancel() { request = nil; busy = false }
    func run(_ request: TranslationRequest, session: TranslationSession) async {
        do {
            let availability = LanguageAvailability()
            let target = Locale.Language(identifier: request.target)
            let status: LanguageAvailability.Status
            if let source = request.source {
                status = await availability.status(from: Locale.Language(identifier: source), to: target)
            } else {
                status = try await availability.status(for: request.text, to: target)
            }
            guard self.request?.id == request.id, !Task.isCancelled else { return }
            if status == .unsupported {
                message = "Apple 翻译暂不支持这组语言。"; busy = false; return
            }
            if status == .supported, request.source != nil {
                message = "请在系统提示中下载翻译语言；首次下载可能需要一些时间。"
                try await session.prepareTranslation()
            }
            try Task.checkCancellation()
            let response = try await session.translate(request.text)
            guard self.request?.id == request.id, !Task.isCancelled else { return }
            result = TranslationResult(original: response.sourceText, translated: response.targetText,
                source: response.sourceLanguage.minimalIdentifier, target: response.targetLanguage.minimalIdentifier)
            message = nil; busy = false
        } catch {
            guard self.request?.id == request.id, !Task.isCancelled else { return }
            busy = false
            switch error {
            case TranslationError.unsupportedSourceLanguage, TranslationError.unsupportedTargetLanguage, TranslationError.unsupportedLanguagePairing:
                message = "Apple 翻译暂不支持这组语言。"
            case TranslationError.unableToIdentifyLanguage:
                message = "无法识别语言，请选择较完整的一句话。"
            default:
                message = "翻译未完成。请确认语言下载已完成，然后重试。"
            }
        }
    }
}
struct TranslationTaskHost: View {
    let request: TranslationRequest
    @ObservedObject var service: TranslationService
    var body: some View {
        Color.clear.frame(width: 0, height: 0)
            .translationTask(.init(source: request.source.map { Locale.Language(identifier: $0) }, target: Locale.Language(identifier: request.target))) { session in
                await service.run(request, session: session)
            }
    }
}
