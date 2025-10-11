import Foundation

struct FileItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let originalName: String
    var newName: String
    var hasConflict: Bool = false
    let fileSize: Int64

    init(url: URL) {
        self.url = url
        self.originalName = url.lastPathComponent
        self.newName = url.lastPathComponent

        // Get file size
        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
           let size = attributes[.size] as? Int64 {
            self.fileSize = size
        } else {
            self.fileSize = 0
        }
    }

    var isChanged: Bool {
        originalName != newName
    }

    var fileExtension: String {
        url.pathExtension
    }

    var nameWithoutExtension: String {
        originalName.deletingSuffix(".\(fileExtension)")
    }

    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
}

extension String {
    func deletingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }
}
