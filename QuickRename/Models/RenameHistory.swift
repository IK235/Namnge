import Foundation
import Combine

struct RenameHistoryItem: Identifiable {
    let id = UUID()
    let date: Date
    let fileCount: Int
    let pattern: RenamePattern
    let files: [(original: String, new: String)]

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

class RenameHistory: ObservableObject {
    @Published var items: [RenameHistoryItem] = []

    func addRename(pattern: RenamePattern, files: [FileItem]) {
        let item = RenameHistoryItem(
            date: Date(),
            fileCount: files.count,
            pattern: pattern,
            files: files.map { (original: $0.originalName, new: $0.newName) }
        )
        items.insert(item, at: 0)

        // Keep only last 50 items
        if items.count > 50 {
            items = Array(items.prefix(50))
        }
    }

    func clear() {
        items.removeAll()
    }
}
