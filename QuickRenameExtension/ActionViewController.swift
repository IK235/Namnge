import Cocoa

class ActionViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Simply open the main app with selected files
        guard let items = self.extensionContext?.inputItems as? [NSExtensionItem],
              let firstItem = items.first,
              let attachments = firstItem.attachments else {
            done()
            return
        }

        var fileURLs: [URL] = []
        let group = DispatchGroup()

        for attachment in attachments {
            group.enter()
            attachment.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (data, error) in
                defer { group.leave() }
                if let url = data as? URL {
                    fileURLs.append(url)
                }
            }
        }

        group.notify(queue: .main) {
            // Open main app with files
            NSWorkspace.shared.open(
                fileURLs,
                withApplicationAt: URL(fileURLWithPath: "/Applications/Namnge.app"),
                configuration: NSWorkspace.OpenConfiguration()
            ) { (app, error) in
                self.done()
            }
        }
    }

    @objc func done() {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
