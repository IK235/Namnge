import SwiftUI
import AppKit
import Combine

@MainActor
class RenameViewModel: ObservableObject {
    @Published var files: [FileItem] = []
    @Published var selectedPattern: RenamePattern = .findReplace {
        didSet {
            operation.pattern = selectedPattern
            updatePreview()
        }
    }
    @Published var operation = RenameOperation(pattern: .findReplace) {
        didSet {
            updatePreview()
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

    func addFiles(urls: [URL]) {
        let fileManager = FileManager.default

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
                                addFile(url: fileURL)
                            }
                        }
                    }
                } else {
                    addFile(url: url)
                }
            }
        }

        updatePreview()
    }

    private func addFile(url: URL) {
        // Avoid duplicates
        guard !files.contains(where: { $0.url == url }) else { return }
        files.append(FileItem(url: url))
    }

    func clearFiles() {
        files.removeAll()
        originalFiles.removeAll()
        hasRenamed = false
        errorMessage = nil
    }

    func updatePreview() {
        files = renameService.previewRename(files: files, operation: operation)
        errorMessage = hasConflicts ? "Multiple files would have the same name" : nil
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
