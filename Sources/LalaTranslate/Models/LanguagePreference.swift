import Foundation
import NaturalLanguage
struct LanguagePreference {
    static func source(for text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.range(of: #"\p{Han}"#, options: .regularExpression) != nil {
            return "zh-Hans"
        }
        if trimmed.range(of: #"^[A-Za-z\s'’.,!?:;()"“”-]+$"#, options: .regularExpression) != nil {
            return "en"
        }
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(trimmed)
        return recognizer.dominantLanguage?.rawValue
    }
    static func target(for source: String?) -> String {
        source?.hasPrefix("zh") == true ? "en" : "zh-Hans"
    }
    static func name(_ code: String) -> String {
        Locale.current.localizedString(forIdentifier: code) ?? code
    }
}
