import Foundation

struct FileItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let originalName: String
    var newName: String
    var hasConflict: Bool = false

    init(url: URL) {
        self.url = url
        self.originalName = url.lastPathComponent
        self.newName = url.lastPathComponent
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
}

extension String {
    func deletingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }
}
