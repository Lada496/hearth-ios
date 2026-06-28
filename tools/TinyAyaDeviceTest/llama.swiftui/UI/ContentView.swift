import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var llamaState = LlamaState()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text("TinyAyaDeviceTest")
                            .font(.title2.bold())
                        Text("Issue #1 latency test. Run on a physical supported iPhone in airplane mode.")
                            .font(.callout)
                    }

                    infoSection
                    controlsSection
                    promptSection
                    resultsSection

                    if !llamaState.errorMessage.isEmpty {
                        Text(llamaState.errorMessage)
                            .font(.callout)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("Tiny-Aya Test")
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Device")
                .font(.headline)
            Text("Name: \(UIDevice.current.name)")
            Text("System: iOS \(UIDevice.current.systemVersion)")
            Text("Model file: \(LlamaState.modelFilename).\(LlamaState.modelExtension)")
            Text("SHA256: \(LlamaState.modelSHA256)")
                .font(.caption)
                .textSelection(.enabled)
        }
    }

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Controls")
                .font(.headline)
            Text(llamaState.status)
                .font(.callout)

            HStack {
                Button("Load Model") {
                    llamaState.loadBundledModel()
                }
                .buttonStyle(.borderedProminent)

                Button("Run Translation") {
                    Task {
                        await llamaState.runTranslation()
                    }
                }
                .buttonStyle(.bordered)

                Button("Clear") {
                    llamaState.clearOutput()
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var promptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prompt")
                .font(.headline)
            TextEditor(text: $llamaState.prompt)
                .font(.system(size: 14, design: .monospaced))
                .frame(minHeight: 160)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.secondary.opacity(0.4))
                )
        }
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Results")
                .font(.headline)
            metric("Load time", llamaState.result.loadTime)
            metric("First token latency", llamaState.result.firstTokenLatency)
            metric("Total generation time", llamaState.result.totalGenerationTime)
            if let tokensPerSecond = llamaState.result.tokensPerSecond {
                Text("Tokens/sec: \(String(format: "%.2f", tokensPerSecond))")
            } else {
                Text("Tokens/sec: not run")
            }
            Text("Run count: \(llamaState.runCount)")

            Text("Generated translation")
                .font(.subheadline.bold())
            Text(llamaState.result.generatedText.isEmpty ? "No output yet." : llamaState.result.generatedText)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }

    private func metric(_ label: String, _ value: TimeInterval?) -> some View {
        if let value {
            return Text("\(label): \(String(format: "%.3f", value)) s")
        }
        return Text("\(label): not run")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
