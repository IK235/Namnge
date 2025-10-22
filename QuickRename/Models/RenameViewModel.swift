import SwiftUI
import AppKit
import Combine

enum SortOption {
    case name
    case size
    case date
}

@MainActor
class RenameViewModel: ObservableObject {
    @Published var files: [FileItem] = []
    @Published var selectedPattern: RenamePattern = .findReplace {
        didSet {
            operation.pattern = selectedPattern
            Task { @MainActor in
                updatePreview()
            }
        }
    }
    @Published var operation = RenameOperation(pattern: .findReplace) {
        didSet {
            Task { @MainActor in
                updatePreview()
            }
        }
    }
    @Published var errorMessage: String?
    @Published var hasRenamed = false

    private var originalFiles: [FileItem] = []
    private let renameService = RenameService.shared
    var history: RenameHistory?

    var changedFilesCount: Int {
        files.filter { $0.isChanged }.count
    }

    var hasConflicts: Bool {
        files.contains { $0.hasConflict }
    }

    func selectFiles() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.message = "Select files to rename"

        if panel.runModal() == .OK {
            addFiles(urls: panel.urls)
        }
    }

    func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (item, error) in
                if let data = item as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil) {
                    Task { @MainActor in
                        self.addFiles(urls: [url])
                    }
                }
            }
        }
    }

    func addFiles(urls: [URL]) -> Int {
        let fileManager = FileManager.default
        var filesAdded = 0

        for url in urls {
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    // Add all files in directory
                    if let contents = try? fileManager.contentsOfDirectory(
                        at: url,
                        includingPropertiesForKeys: nil,
                        options: [.skipsHiddenFiles]
                    ) {
                        for fileURL in contents {
                            if !fileURL.hasDirectoryPath {
                                if addFile(url: fileURL) {
                                    filesAdded += 1
                                }
                            }
                        }
                    }
                } else {
                    if addFile(url: url) {
                        filesAdded += 1
                    }
                }
            }
        }

        updatePreview()
        return filesAdded
    }

    private func addFile(url: URL) -> Bool {
        // Avoid duplicates
        guard !files.contains(where: { $0.url == url }) else { return false }

        files.append(FileItem(url: url))
        return true
    }

    func clearFiles() {
        files.removeAll()
        originalFiles.removeAll()
        hasRenamed = false
        errorMessage = nil
    }

    func refreshFiles() {
        // Re-check all files to update their current state
        let currentURLs = files.map { $0.url }
        files.removeAll()

        for url in currentURLs {
            // Check if file still exists at original location or was renamed
            let directory = url.deletingLastPathComponent()
            if let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: [.nameKey]) {
                for case let fileURL as URL in enumerator {
                    if fileURL.lastPathComponent == url.lastPathComponent {
                        // File exists with original name
                        _ = addFiles(urls: [fileURL])
                        break
                    }
                }
            }
        }

        updatePreview()
    }

    func sortFiles(by option: SortOption) {
        switch option {
        case .name:
            files.sort { $0.originalName.localizedStandardCompare($1.originalName) == .orderedAscending }
        case .size:
            files.sort { $0.fileSize > $1.fileSize }
        case .date:
            files.sort { (file1, file2) -> Bool in
                guard let date1 = try? FileManager.default.attributesOfItem(atPath: file1.url.path)[.modificationDate] as? Date,
                      let date2 = try? FileManager.default.attributesOfItem(atPath: file2.url.path)[.modificationDate] as? Date else {
                    return false
                }
                return date1 > date2
            }
        }
    }

    func updatePreview() {
        if operation.pattern == .aiSmart {
            // AI preview handled separately (async)
            errorMessage = nil
            return
        }

        files = renameService.previewRename(files: files, operation: operation)
        errorMessage = hasConflicts ? "Multiple files would have the same name" : nil
    }

    func performAIRename() async {
        guard !operation.aiPrompt.isEmpty else {
            errorMessage = "Please describe what you want to rename"
            return
        }

        errorMessage = "🤖 AI is thinking..."

        do {
            let results = try await AIRenameService.shared.batchRename(
                files: files,
                prompt: operation.aiPrompt,
                provider: operation.aiProvider
            )

            // Update files with AI-generated names
            for (originalFile, newName) in results {
                if let index = files.firstIndex(where: { $0.id == originalFile.id }) {
                    files[index].newName = newName
                }
            }

            // Check for conflicts
            updatePreview()
            errorMessage = "✓ AI generated names for \(results.count) files!"

        } catch {
            errorMessage = "AI Error: \(error.localizedDescription)"
        }
    }

    func performRename() {
        guard !files.isEmpty else {
            errorMessage = "No files selected"
            return
        }

        guard changedFilesCount > 0 else {
            errorMessage = "No changes to apply"
            return
        }

        guard !hasConflicts else {
            errorMessage = "Fix conflicts before renaming"
            return
        }

        do {
            originalFiles = files
            let changedFiles = files.filter { $0.isChanged }

            try renameService.performRename(files: files)
            hasRenamed = true
            errorMessage = "✓ Renamed \(changedFilesCount) files successfully!"

            // Add to history
            history?.addRename(pattern: selectedPattern, files: changedFiles)

            // Update file URLs to reflect new names
            for (index, file) in files.enumerated() {
                let newURL = file.url.deletingLastPathComponent().appendingPathComponent(file.newName)
                files[index] = FileItem(url: newURL)
            }

            // Keep files in list - don't auto-clear!
            // User can manually clear or add more files
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func undo() {
        guard hasRenamed, !originalFiles.isEmpty else { return }

        do {
            try renameService.undoRename(files: originalFiles)
            files = originalFiles
            hasRenamed = false
            errorMessage = nil
        } catch {
            errorMessage = "Undo failed: \(error.localizedDescription)"
        }
    }
}
