import AVFoundation
@MainActor
final class SpeechService {
    private let synthesizer = AVSpeechSynthesizer()
    func speak(_ text: String, language: String?) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        if let language { utterance.voice = AVSpeechSynthesisVoice(language: language) }
        synthesizer.speak(utterance)
    }
    func stop() { synthesizer.stopSpeaking(at: .immediate) }
}
