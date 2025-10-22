import Foundation
import Vision
import AppKit

class AIRenameService {
    static let shared = AIRenameService()

    private init() {}

    // MARK: - Main AI Rename Function

    func generateSmartName(for file: FileItem, prompt: String, provider: AIProvider = .local) async throws -> String {
        // Only use Apple Vision (local, on-device AI)
        return try await renameWithAppleVision(file: file, prompt: prompt)
    }

    func batchRename(files: [FileItem], prompt: String, provider: AIProvider = .local) async throws -> [(original: FileItem, newName: String)] {
        var results: [(FileItem, String)] = []

        // Process files in parallel (max 5 at a time to not overwhelm API)
        for chunk in files.chunked(into: 5) {
            let chunkResults = try await withThrowingTaskGroup(of: (FileItem, String).self) { group in
                for file in chunk {
                    group.addTask {
                        let newName = try await self.generateSmartName(for: file, prompt: prompt, provider: provider)
                        return (file, newName)
                    }
                }

                var chunkResults: [(FileItem, String)] = []
                for try await result in group {
                    chunkResults.append(result)
                }
                return chunkResults
            }

            results.append(contentsOf: chunkResults)
        }

        return results
    }

    // MARK: - Apple Vision (Local AI)

    private func renameWithAppleVision(file: FileItem, prompt: String) async throws -> String {
        // Get multiple analysis results
        let imageAnalysis = await analyzeImageWithMultipleMethods(file: file)

        // Build filename from prompt + analysis
        var components: [String] = []

        // Add cleaned prompt words (max 3)
        let promptWords = prompt
            .lowercased()
            .split(separator: " ")
            .filter { $0.count > 2 } // Skip short words like "a", "in", "of"
            .prefix(3)
            .map { String($0) }
        components.append(contentsOf: promptWords)

        // Add image classification if available
        if let classification = imageAnalysis.classification?.prefix(2) {
            components.append(contentsOf: classification.map { $0.replacingOccurrences(of: " ", with: "-") })
        }

        // Add scene if available (but different from classification)
        if let scene = imageAnalysis.scene,
           !components.contains(where: { $0.contains(scene) }) {
            components.append(scene)
        }

        // Create base name (max 4 components to keep it reasonable)
        let baseName = components
            .prefix(4)
            .joined(separator: "-")
            .lowercased()
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))

        // Add index if multiple files (optional - could use timestamp instead)
        let cleanName = baseName.isEmpty ? "renamed-image" : baseName

        return "\(cleanName).\(file.fileExtension)"
    }

    private func analyzeImageWithMultipleMethods(file: FileItem) async -> ImageAnalysisResult {
        guard let image = NSImage(contentsOf: file.url),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return ImageAnalysisResult()
        }

        return await withCheckedContinuation { continuation in
            var result = ImageAnalysisResult()
            let dispatchGroup = DispatchGroup()

            // 1. Image Classification (what is it?)
            dispatchGroup.enter()
            let classifyRequest = VNClassifyImageRequest { request, _ in
                if let observations = request.results as? [VNClassificationObservation] {
                    result.classification = observations
                        .prefix(3)
                        .filter { $0.confidence > 0.3 }
                        .map { $0.identifier }
                }
                dispatchGroup.leave()
            }

            // 2. Scene Classification (where/what scene?)
            dispatchGroup.enter()
            let sceneRequest = VNRecognizeAnimalsRequest { request, _ in
                if let observations = request.results as? [VNRecognizedObjectObservation],
                   let topObservation = observations.first {
                    result.scene = topObservation.labels.first?.identifier
                }
                dispatchGroup.leave()
            }

            // 3. Text Recognition (any text in image?)
            dispatchGroup.enter()
            let textRequest = VNRecognizeTextRequest { request, _ in
                if let observations = request.results as? [VNRecognizedTextObservation] {
                    let recognizedText = observations
                        .compactMap { $0.topCandidates(1).first?.string }
                        .joined(separator: " ")
                    if !recognizedText.isEmpty {
                        result.text = recognizedText.prefix(30).description
                    }
                }
                dispatchGroup.leave()
            }
            textRequest.recognitionLevel = .fast

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            try? handler.perform([classifyRequest, sceneRequest, textRequest])

            dispatchGroup.notify(queue: .main) {
                continuation.resume(returning: result)
            }
        }
    }

}

// MARK: - Image Analysis Result

struct ImageAnalysisResult {
    var classification: [String]? // What it is (cat, food, document)
    var scene: String?              // Scene type (indoor, outdoor, nature)
    var text: String?               // Any text found in image
}

// MARK: - Errors

enum AIError: LocalizedError {
    case apiError(String)
    case parsingFailed
    case noAPIKey
    case rateLimitExceeded

    var errorDescription: String? {
        switch self {
        case .apiError(let message):
            return "AI API Error: \(message)"
        case .parsingFailed:
            return "Failed to parse AI response"
        case .noAPIKey:
            return "No API key configured"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Try again in a moment."
        }
    }
}

// MARK: - Helper Extensions

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
