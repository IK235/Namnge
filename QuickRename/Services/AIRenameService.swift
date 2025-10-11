import Foundation
import Vision
import AppKit

class AIRenameService {
    static let shared = AIRenameService()

    // API Keys - Set these via environment variables or in your local config
    private let groqAPIKey: String? = ProcessInfo.processInfo.environment["GROQ_API_KEY"]
    private let groqEndpoint = "https://api.groq.com/openai/v1/chat/completions"

    // Add your other API keys here
    private var claudeAPIKey: String? = ProcessInfo.processInfo.environment["CLAUDE_API_KEY"]
    private var openAIKey: String? = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]

    private init() {}

    // MARK: - Main AI Rename Function

    func generateSmartName(for file: FileItem, prompt: String, provider: AIProvider = .groq) async throws -> String {
        switch provider {
        case .groq:
            return try await renameWithGroq(file: file, prompt: prompt)
        case .claude:
            return try await renameWithClaude(file: file, prompt: prompt)
        case .local:
            return try await renameWithAppleVision(file: file, prompt: prompt)
        }
    }

    func batchRename(files: [FileItem], prompt: String, provider: AIProvider = .groq) async throws -> [(original: FileItem, newName: String)] {
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

    // MARK: - Groq API (Fast & Free)

    private func renameWithGroq(file: FileItem, prompt: String) async throws -> String {
        guard let apiKey = groqAPIKey else {
            throw AIError.noAPIKey
        }

        let url = URL(string: groqEndpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        // Check if it's an image file
        let isImage = ["jpg", "jpeg", "png", "heic", "gif"].contains(file.fileExtension.lowercased())

        let systemPrompt = """
        You are a file naming expert. Generate a concise, descriptive filename based on the user's request.
        Rules:
        - No spaces (use hyphens or underscores)
        - Keep original file extension
        - Max 50 characters
        - Be descriptive but concise
        - Use proper capitalization (Title-Case or kebab-case)
        - Return ONLY the filename, nothing else
        """

        let userMessage: String
        if isImage {
            // For images, try to analyze if possible
            let imageDescription = await analyzeImageLocally(file: file)
            userMessage = """
            Original filename: \(file.originalName)
            File type: Image (\(file.fileExtension))
            Image content: \(imageDescription ?? "Unknown")
            User request: \(prompt)

            Generate a new filename.
            """
        } else {
            userMessage = """
            Original filename: \(file.originalName)
            File type: \(file.fileExtension)
            User request: \(prompt)

            Generate a new filename.
            """
        }

        let body: [String: Any] = [
            "model": "llama-3.1-8b-instant",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userMessage]
            ],
            "temperature": 0.7,
            "max_tokens": 100
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError("API request failed")
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        guard let choices = json?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.parsingFailed
        }

        // Clean up the response
        let cleanName = content
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "'", with: "")

        // Ensure it has the right extension
        let hasExtension = cleanName.lowercased().hasSuffix(".\(file.fileExtension.lowercased())")
        return hasExtension ? cleanName : "\(cleanName).\(file.fileExtension)"
    }

    // MARK: - Claude API (Best Quality)

    private func renameWithClaude(file: FileItem, prompt: String) async throws -> String {
        guard let apiKey = claudeAPIKey else {
            // Fallback to Groq if no Claude key
            return try await renameWithGroq(file: file, prompt: prompt)
        }

        // TODO: Implement Claude API if you get API key
        // For now, fallback to Groq
        return try await renameWithGroq(file: file, prompt: prompt)
    }

    // MARK: - Apple Vision (Local/Offline)

    private func renameWithAppleVision(file: FileItem, prompt: String) async throws -> String {
        let imageDescription = await analyzeImageLocally(file: file)

        // Simple local logic based on image analysis
        if let description = imageDescription {
            let words = prompt.split(separator: " ").prefix(3).joined(separator: "-")
            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
                .replacingOccurrences(of: "/", with: "-")

            return "\(words)-\(description)-\(timestamp).\(file.fileExtension)"
        }

        // Fallback: use prompt + timestamp
        let cleanPrompt = prompt.replacingOccurrences(of: " ", with: "-")
        return "\(cleanPrompt)-\(file.nameWithoutExtension).\(file.fileExtension)"
    }

    private func analyzeImageLocally(file: FileItem) async -> String? {
        guard let image = NSImage(contentsOf: file.url),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        return await withCheckedContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                guard let observations = request.results as? [VNClassificationObservation],
                      let topResult = observations.first else {
                    continuation.resume(returning: nil)
                    return
                }

                // Get top classification
                let label = topResult.identifier.replacingOccurrences(of: " ", with: "-")
                continuation.resume(returning: label)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
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
