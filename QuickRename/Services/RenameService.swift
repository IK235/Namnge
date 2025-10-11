import Foundation

class RenameService {
    static let shared = RenameService()

    private init() {}

    func previewRename(files: [FileItem], operation: RenameOperation) -> [FileItem] {
        var updatedFiles = files

        for (index, file) in updatedFiles.enumerated() {
            let newName: String

            if operation.pattern == .sequential {
                newName = operation.applySequential(to: file.originalName, index: index)
            } else {
                newName = operation.apply(to: file.originalName)
            }

            updatedFiles[index].newName = newName
        }

        // Check for conflicts
        let nameCount = Dictionary(grouping: updatedFiles, by: { $0.newName })
            .mapValues { $0.count }

        for (index, file) in updatedFiles.enumerated() {
            updatedFiles[index].hasConflict = (nameCount[file.newName] ?? 0) > 1
        }

        return updatedFiles
    }

    func performRename(files: [FileItem]) throws {
        let fileManager = FileManager.default

        // Check for conflicts
        if files.contains(where: { $0.hasConflict }) {
            throw RenameError.conflictingNames
        }

        // Perform renames
        for file in files where file.isChanged {
            let newURL = file.url.deletingLastPathComponent().appendingPathComponent(file.newName)

            // Check if target exists
            if fileManager.fileExists(atPath: newURL.path) {
                throw RenameError.fileAlreadyExists(file.newName)
            }

            do {
                try fileManager.moveItem(at: file.url, to: newURL)
            } catch {
                throw RenameError.renameFailed(file.originalName, error)
            }
        }
    }

    func undoRename(files: [FileItem]) throws {
        let fileManager = FileManager.default

        for file in files where file.isChanged {
            let currentURL = file.url.deletingLastPathComponent().appendingPathComponent(file.newName)
            let originalURL = file.url

            if fileManager.fileExists(atPath: currentURL.path) {
                try fileManager.moveItem(at: currentURL, to: originalURL)
            }
        }
    }
}

enum RenameError: LocalizedError {
    case conflictingNames
    case fileAlreadyExists(String)
    case renameFailed(String, Error)
    case noFilesSelected

    var errorDescription: String? {
        switch self {
        case .conflictingNames:
            return "Multiple files would have the same name. Please adjust your pattern."
        case .fileAlreadyExists(let name):
            return "A file named '\(name)' already exists."
        case .renameFailed(let name, let error):
            return "Failed to rename '\(name)': \(error.localizedDescription)"
        case .noFilesSelected:
            return "No files selected. Please add files to rename."
        }
    }
}
