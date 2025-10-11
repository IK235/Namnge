import Foundation
import AppKit
import Combine

class UpdateChecker: ObservableObject {
    static let shared = UpdateChecker()

    @Published var updateAvailable = false
    @Published var latestVersion = ""
    @Published var downloadURL = ""

    private let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    private let githubRepo = "ikbalerdal/Namnge" // Update with your actual GitHub repo
    private let checkInterval: TimeInterval = 86400 // 24 hours

    private init() {
        // Check for updates on init if it's been more than 24 hours
        checkIfShouldUpdate()
    }

    private func checkIfShouldUpdate() {
        let lastCheck = UserDefaults.standard.double(forKey: "lastUpdateCheck")
        let now = Date().timeIntervalSince1970

        if now - lastCheck > checkInterval {
            checkForUpdates()
        }
    }

    func checkForUpdates(manual: Bool = false) {
        let urlString = "https://api.github.com/repos/\(githubRepo)/releases/latest"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil else {
                if manual {
                    DispatchQueue.main.async {
                        self?.showErrorAlert()
                    }
                }
                return
            }

            do {
                let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
                let latestVersion = release.tagName.replacingOccurrences(of: "v", with: "")

                DispatchQueue.main.async {
                    self.latestVersion = latestVersion
                    self.downloadURL = release.htmlURL

                    // Compare versions
                    if self.isNewerVersion(latestVersion, than: self.currentVersion) {
                        self.updateAvailable = true
                        if manual {
                            self.showUpdateAlert(version: latestVersion)
                        }
                    } else if manual {
                        self.showNoUpdateAlert()
                    }

                    // Save last check time
                    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastUpdateCheck")
                }
            } catch {
                if manual {
                    DispatchQueue.main.async {
                        self.showErrorAlert()
                    }
                }
            }
        }.resume()
    }

    private func isNewerVersion(_ new: String, than current: String) -> Bool {
        let newComponents = new.split(separator: ".").compactMap { Int($0) }
        let currentComponents = current.split(separator: ".").compactMap { Int($0) }

        for i in 0..<max(newComponents.count, currentComponents.count) {
            let newValue = i < newComponents.count ? newComponents[i] : 0
            let currentValue = i < currentComponents.count ? currentComponents[i] : 0

            if newValue > currentValue {
                return true
            } else if newValue < currentValue {
                return false
            }
        }

        return false
    }

    private func showUpdateAlert(version: String) {
        let alert = NSAlert()
        alert.messageText = "Update Available"
        alert.informativeText = "Namnge \(version) is now available. You are currently using version \(currentVersion).\n\nWould you like to download it?"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Download")
        alert.addButton(withTitle: "Later")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: downloadURL) {
                NSWorkspace.shared.open(url)
            }
        }
    }

    private func showNoUpdateAlert() {
        let alert = NSAlert()
        alert.messageText = "You're Up to Date"
        alert.informativeText = "Namnge \(currentVersion) is currently the newest version available."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func showErrorAlert() {
        let alert = NSAlert()
        alert.messageText = "Update Check Failed"
        alert.informativeText = "Unable to check for updates. Please try again later."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    func dismissUpdate() {
        updateAvailable = false
    }
}

// MARK: - GitHub API Models

struct GitHubRelease: Codable {
    let tagName: String
    let htmlURL: String
    let body: String

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlURL = "html_url"
        case body
    }
}
