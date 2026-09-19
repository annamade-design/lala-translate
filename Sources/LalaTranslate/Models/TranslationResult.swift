import Foundation
struct TranslationResult {
    let original: String
    let translated: String
    let source: String
    let target: String
}
struct TranslationRequest: Identifiable {
    let id = UUID()
    let text: String
    let source: String?
    let target: String
}
