import Foundation
import Combine

struct RenameHistoryItem: Identifiable {
    let id = UUID()
    let date: Date
    let fileCount: Int
    let pattern: RenamePattern
    let files: [(url: URL, original: String, new: String)]

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

class RenameHistory: ObservableObject {
    @Published var items: [RenameHistoryItem] = []

    var totalFilesRenamed: Int {
        items.reduce(0) { $0 + $1.fileCount }
    }

    func addRename(pattern: RenamePattern, files: [FileItem]) {
        let item = RenameHistoryItem(
            date: Date(),
            fileCount: files.count,
            pattern: pattern,
            files: files.map { (url: $0.url, original: $0.originalName, new: $0.newName) }
        )
        items.insert(item, at: 0)

        // Keep only last 50 items
        if items.count > 50 {
            items = Array(items.prefix(50))
        }
    }

    func undoRename(_ item: RenameHistoryItem) -> Bool {
        var successCount = 0

        for file in item.files {
            // Get the current location of the renamed file
            let renamedURL = file.url.deletingLastPathComponent().appendingPathComponent(file.new)
            let originalURL = file.url.deletingLastPathComponent().appendingPathComponent(file.original)

            // Check if renamed file exists
            if FileManager.default.fileExists(atPath: renamedURL.path) {
                do {
                    try FileManager.default.moveItem(at: renamedURL, to: originalURL)
                    successCount += 1
                } catch {
                    print("Failed to undo rename for \(file.new): \(error)")
                }
            }
        }

        // Remove from history if all files were successfully restored
        if successCount == item.files.count {
            items.removeAll { $0.id == item.id }
            return true
        }

        return false
    }

    func undoMultiple(_ items: [RenameHistoryItem]) -> (success: Int, failed: Int) {
        var successCount = 0
        var failedCount = 0

        for item in items {
            if undoRename(item) {
                successCount += 1
            } else {
                failedCount += 1
            }
        }

        return (successCount, failedCount)
    }

    func clear() {
        items.removeAll()
    }
}
