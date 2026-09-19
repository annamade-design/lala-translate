import Foundation
protocol SelectedTextProvider {
    func selectedText(processID: Int32?) throws -> String
}
enum SelectionError: Error {
    case permissionRequired, noSelection, unsupported, unavailable, tooLong
    var message: String {
        switch self {
        case .permissionRequired: return "请在系统设置 → 隐私与安全性 → 辅助功能中允许 Lala Translate 读取选中文字。"
        case .noSelection: return "No text selected. 请先选中文字，再按 ⌥T。"
        case .unsupported: return "当前应用未提供选中文字。请尝试其他文本区域或应用。"
        case .unavailable: return "暂时无法读取当前应用，请重新选中文字后重试。"
        case .tooLong: return "选中文字过长，请缩短至 10,000 字以内。"
        }
    }
    static func validate(_ text: String) throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw SelectionError.noSelection }
        guard trimmed.count <= 10_000 else { throw SelectionError.tooLong }
        return trimmed
    }
}
