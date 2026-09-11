import Foundation
import WhisperKit

@MainActor
final class WhisperState: ObservableObject {
    @Published var status = "Whisper not loaded."
    @Published var transcript = ""
    @Published var detectedLanguage = ""
    @Published var loadTime: TimeInterval?
    @Published var sttTime: TimeInterval?
    @Published var isWorking = false

    private var whisper: WhisperKit?
    private let nanosecondsPerSecond = 1_000_000_000.0

    static let modelVariant = "small"

    func loadWhisper() async {
        guard !isWorking else { return }
        isWorking = true
        status = "Loading Whisper \(Self.modelVariant)… (first run downloads the model)"

        do {
            let start = DispatchTime.now().uptimeNanoseconds
            whisper = try await WhisperKit(model: Self.modelVariant)
            let end = DispatchTime.now().uptimeNanoseconds
            loadTime = Double(end - start) / nanosecondsPerSecond
            status = String(format: "Whisper loaded in %.1f s.", loadTime ?? 0)
        } catch {
            status = "Whisper load failed."
            transcript = String(describing: error)
        }
        isWorking = false
    }

    func transcribe(clip: String = "test_en") async {
        guard !isWorking else { return }
        guard let whisper else {
            status = "Load Whisper first."
            return
        }
        guard let url = Bundle.main.url(forResource: clip, withExtension: "wav") else {
            status = "\(clip).wav not in bundle. Add it to the project (16 kHz mono WAV)."
            return
        }

        isWorking = true
        status = "Transcribing \(clip)…"
        transcript = ""
        detectedLanguage = ""
        sttTime = nil

        do {
            let start = DispatchTime.now().uptimeNanoseconds
            let results = try await whisper.transcribe(audioPath: url.path)
            let end = DispatchTime.now().uptimeNanoseconds
            sttTime = Double(end - start) / nanosecondsPerSecond

            let first = results.first
            transcript = first?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? "(empty)"
            detectedLanguage = first?.language ?? "?"
            status = String(format: "Done in %.2f s.", sttTime ?? 0)
        } catch {
            status = "Transcription failed."
            transcript = String(describing: error)
        }
        isWorking = false
    }
}
