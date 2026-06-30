import Combine
import Foundation

struct LatencyResult {
    var loadTime: TimeInterval?
    var firstTokenLatency: TimeInterval?
    var totalGenerationTime: TimeInterval?
    var tokensPerSecond: Double?
    var generatedText: String = ""
}

@MainActor
final class LlamaState: ObservableObject {
    @Published var prompt = LlamaState.defaultPrompt
    @Published var status = "Model not loaded."
    @Published var result = LatencyResult()
    @Published var runCount = 0
    @Published var errorMessage = ""
    @Published var isRunning = false

    private let endOfTurnToken = "<|END_OF_TURN_TOKEN|>"
    private let startOfTurnToken = "<|START_OF_TURN_TOKEN|>"
    private let maxGeneratedTokens = 80
    private let nanosecondsPerSecond = 1_000_000_000.0
    private var llamaContext: LlamaContext?

    static let modelFilename = "tiny-aya-earth-q4_k_m"
    static let modelExtension = "gguf"
    static let modelSHA256 = "01ecc5d1195a21a9e3e2efa4f4b7c547502a58efda8d38b80646823b56d383c4"

    static let defaultPrompt = """
    You are a translator. Output ONLY the English translation of the text below. Do not explain, do not add notes, do not repeat the original. Do not answer the text, ask questions, or offer help. If the text is already in English, output it unchanged.

    Ninahitaji msaada kupata makazi usiku wa leo.
    """

    func loadBundledModel() {
        errorMessage = ""
        status = "Loading model..."

        guard let modelURL = Bundle.main.url(
            forResource: Self.modelFilename,
            withExtension: Self.modelExtension,
            subdirectory: "models"
        ) else {
            status = "Model not found."
            errorMessage = """
            Add tiny-aya-earth-q4_k_m.gguf to llama.swiftui/Resources/models before running on device.
            Do not commit the model file.
            """
            return
        }

        do {
            let start = DispatchTime.now().uptimeNanoseconds
            llamaContext = try LlamaContext.create_context(path: modelURL.path())
            let end = DispatchTime.now().uptimeNanoseconds
            result.loadTime = Double(end - start) / nanosecondsPerSecond
            status = "Loaded \(modelURL.lastPathComponent)."
        } catch {
            status = "Model load failed."
            errorMessage = String(describing: error)
        }
    }

    func runTranslation() async {
        guard !isRunning else { return }
        guard let llamaContext else {
            status = "Load the model first."
            return
        }

        isRunning = true
        errorMessage = ""
        status = "Running translation..."
        result.generatedText = ""
        result.firstTokenLatency = nil
        result.totalGenerationTime = nil
        result.tokensPerSecond = nil

        let start = DispatchTime.now().uptimeNanoseconds
        await llamaContext.completion_init(text: chatFormattedPrompt(prompt))
        var generatedTokenCount = 0
        var firstTokenTime: UInt64?
        var foundStopToken = false

        while await !llamaContext.is_done && generatedTokenCount < maxGeneratedTokens {
            let piece = await llamaContext.completion_loop()
            if !piece.isEmpty {
                generatedTokenCount += 1
                if firstTokenTime == nil {
                    firstTokenTime = DispatchTime.now().uptimeNanoseconds
                }
                result.generatedText += piece

                if containsStopToken(result.generatedText) {
                    foundStopToken = true
                    break
                }
            }
        }

        result.generatedText = cleanedGeneratedText(result.generatedText)

        let end = DispatchTime.now().uptimeNanoseconds
        result.totalGenerationTime = Double(end - start) / nanosecondsPerSecond
        if let firstTokenTime {
            result.firstTokenLatency = Double(firstTokenTime - start) / nanosecondsPerSecond
        }
        if let total = result.totalGenerationTime, total > 0 {
            result.tokensPerSecond = Double(generatedTokenCount) / total
        }

        runCount += 1
        if foundStopToken {
            status = "Run \(runCount) complete."
        } else if generatedTokenCount >= maxGeneratedTokens {
            status = "Run \(runCount) stopped at token limit."
        } else {
            status = "Run \(runCount) complete."
        }
        await llamaContext.clear()
        isRunning = false
    }

    func clearOutput() {
        result.generatedText = ""
        result.firstTokenLatency = nil
        result.totalGenerationTime = nil
        result.tokensPerSecond = nil
        errorMessage = ""
        status = llamaContext == nil ? "Model not loaded." : "Ready."
    }

    private func chatFormattedPrompt(_ userPrompt: String) -> String {
        """
        <|START_OF_TURN_TOKEN|><|USER_TOKEN|>\(userPrompt.trimmingCharacters(in: .whitespacesAndNewlines))<|END_OF_TURN_TOKEN|><|START_OF_TURN_TOKEN|><|CHATBOT_TOKEN|><|START_RESPONSE|>
        """
    }

    private func containsStopToken(_ text: String) -> Bool {
        text.contains(endOfTurnToken) || text.contains(startOfTurnToken)
    }

    private func cleanedGeneratedText(_ text: String) -> String {
        var cleaned = text
        let tokensToRemove = [
            endOfTurnToken,
            startOfTurnToken,
            "<|CHATBOT_TOKEN|>",
            "<|USER_TOKEN|>",
            "<|START_RESPONSE|>"
        ]

        for token in tokensToRemove {
            cleaned = cleaned.replacingOccurrences(of: token, with: "")
        }

        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
