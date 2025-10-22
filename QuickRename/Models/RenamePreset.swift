import Foundation
import Combine
import AppKit
import UniformTypeIdentifiers

// MARK: - Rename Preset

struct RenamePreset: Codable, Identifiable {
    let id: UUID
    var name: String
    var patternRaw: String  // Store pattern as string for Codable
    var findText: String
    var replaceText: String
    var prefixText: String
    var suffixText: String
    var removeText: String
    var caseStyleRaw: String  // Store caseStyle as string for Codable
    var dateFormat: String
    var regexPattern: String
    var regexReplacement: String
    var sequentialStart: Int
    var sequentialPadding: Int
    var aiProviderRaw: String  // Store aiProvider as string for Codable
    var aiPrompt: String

    init(id: UUID = UUID(), name: String, operation: RenameOperation) {
        self.id = id
        self.name = name
        self.patternRaw = operation.pattern.rawValue
        self.findText = operation.findText
        self.replaceText = operation.replaceText
        self.prefixText = operation.prefixText
        self.suffixText = operation.suffixText
        self.removeText = operation.removeText
        self.caseStyleRaw = operation.caseStyle.rawValue
        self.dateFormat = operation.dateFormat
        self.regexPattern = operation.regexPattern
        self.regexReplacement = operation.regexReplacement
        self.sequentialStart = operation.sequentialStart
        self.sequentialPadding = operation.sequentialPadding
        self.aiProviderRaw = operation.aiProvider.rawValue
        self.aiPrompt = operation.aiPrompt
    }

    func toOperation() -> RenameOperation {
        let pattern = RenamePattern(rawValue: patternRaw) ?? .findReplace
        var operation = RenameOperation(pattern: pattern)
        operation.findText = findText
        operation.replaceText = replaceText
        operation.prefixText = prefixText
        operation.suffixText = suffixText
        operation.removeText = removeText
        operation.caseStyle = CaseStyle(rawValue: caseStyleRaw) ?? .lowercase
        operation.dateFormat = dateFormat
        operation.regexPattern = regexPattern
        operation.regexReplacement = regexReplacement
        operation.sequentialStart = sequentialStart
        operation.sequentialPadding = sequentialPadding
        operation.aiProvider = AIProvider(rawValue: aiProviderRaw) ?? .local
        operation.aiPrompt = aiPrompt
        return operation
    }
}

// MARK: - Preset Manager

class PresetManager: ObservableObject {
    static let shared = PresetManager()

    @Published var presets: [RenamePreset] = []

    private let presetsKey = "renamePresets"

    private init() {
        loadPresets()
    }

    func savePreset(name: String, operation: RenameOperation) {
        let preset = RenamePreset(name: name, operation: operation)
        presets.append(preset)
        saveToUserDefaults()
    }

    func deletePreset(_ preset: RenamePreset) {
        presets.removeAll { $0.id == preset.id }
        saveToUserDefaults()
    }

    func updatePreset(_ preset: RenamePreset, operation: RenameOperation) {
        if let index = presets.firstIndex(where: { $0.id == preset.id }) {
            presets[index] = RenamePreset(id: preset.id, name: preset.name, operation: operation)
            saveToUserDefaults()
        }
    }

    func exportPresets() -> URL? {
        guard !presets.isEmpty else { return nil }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "Namnge Presets.json"
        savePanel.message = "Export your presets"

        guard savePanel.runModal() == .OK, let url = savePanel.url else {
            return nil
        }

        do {
            let data = try JSONEncoder().encode(presets)
            try data.write(to: url)
            return url
        } catch {
            print("Failed to export presets: \(error)")
            return nil
        }
    }

    func importPresets() -> Bool {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        openPanel.message = "Import presets"

        guard openPanel.runModal() == .OK, let url = openPanel.url else {
            return false
        }

        do {
            let data = try Data(contentsOf: url)
            let importedPresets = try JSONDecoder().decode([RenamePreset].self, from: data)

            // Add imported presets (avoid duplicates by name)
            for preset in importedPresets {
                if !presets.contains(where: { $0.name == preset.name }) {
                    presets.append(preset)
                }
            }

            saveToUserDefaults()
            return true
        } catch {
            print("Failed to import presets: \(error)")
            return false
        }
    }

    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(encoded, forKey: presetsKey)
        }
    }

    private func loadPresets() {
        if let data = UserDefaults.standard.data(forKey: presetsKey),
           let decoded = try? JSONDecoder().decode([RenamePreset].self, from: data) {
            presets = decoded
        }
    }
}
