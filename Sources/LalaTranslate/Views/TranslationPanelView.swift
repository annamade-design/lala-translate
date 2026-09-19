import SwiftUI
struct TranslationPanelView: View {
    @ObservedObject var service: TranslationService
    var close: () -> Void
    var togglePin: (Bool) -> Void
    let speech: SpeechService
    @State private var pinned = false
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack { Text("Lala Translate").font(.headline); Spacer(); Button { pinned.toggle(); togglePin(pinned) } label: { Image(systemName: pinned ? "pin.fill" : "pin") }.buttonStyle(.plain).help("Pin"); Button(action: close) { Image(systemName: "xmark") }.buttonStyle(.plain).help("Close") }
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if let request = service.request {
                        Text(request.text).textSelection(.enabled)
                        actions(text: request.text, language: request.source)
                        Text("\(LanguagePreference.name(request.source ?? "auto")) → \(LanguagePreference.name(request.target))").font(.caption).foregroundStyle(.secondary)
                    }
                    if service.busy { ProgressView().controlSize(.small) }
                    if let result = service.result { Divider(); Text(result.translated).font(.title3).textSelection(.enabled); actions(text: result.translated, language: result.target) }
                    if let message = service.message { Text(message).foregroundStyle(.secondary) }
                    if service.needsPermission { Button("打开辅助功能设置", action: AccessibilitySelectedTextProvider.openSettings) }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            Text("Translations are processed using Apple's Translation framework.").font(.caption2).foregroundStyle(.tertiary)
        }.padding(20).frame(width: 400, height: 360)
        .background(.regularMaterial)
        .background { if let request = service.request { TranslationTaskHost(request: request, service: service).id(request.id) } }
        .onExitCommand(perform: close)
    }
    private func actions(text: String, language: String?) -> some View {
        HStack(spacing: 12) {
            Button { speech.speak(text, language: language) } label: { Label("Speak", systemImage: "speaker.wave.2") }
            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(text, forType: .string)
            } label: { Label("Copy", systemImage: "doc.on.doc") }
        }.buttonStyle(.borderless).font(.caption)
    }
}
