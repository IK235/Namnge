import Foundation
import Combine

enum ProFeature {
    case aiRename
    case unlimitedFiles
    case allColors
    case exportPresets
    case unlimitedHistory
}

class LicenseManager: ObservableObject {
    static let shared = LicenseManager()

    @Published var isPro: Bool = false
    @Published var licenseEmail: String = ""
    @Published var licenseKey: String = ""
    @Published var expiryDate: Date?
    @Published var plan: String = "" // "pro_monthly" or "pro_yearly"

    private let API_URL = "https://namnge.com/api/validate" // You'll change this to your actual API

    private init() {
        checkExistingLicense()
    }

    func validateLicense(key: String, email: String) async -> (success: Bool, message: String) {
        // Trim whitespace
        let cleanKey = key.trimmingCharacters(in: .whitespaces)
        let cleanEmail = email.trimmingCharacters(in: .whitespaces).lowercased()

        // Basic validation
        guard !cleanKey.isEmpty, !cleanEmail.isEmpty else {
            return (false, "Please enter both license key and email")
        }

        guard cleanEmail.contains("@") && cleanEmail.contains(".") else {
            return (false, "Please enter a valid email address")
        }

        // TODO: Replace with actual API call when backend is ready
        // For now, we'll use a simple check for testing

        #if DEBUG
        // Development mode: Accept any key starting with "NAMNGE-PRO-"
        if cleanKey.hasPrefix("NAMNGE-PRO-") {
            await MainActor.run {
                self.isPro = true
                self.licenseEmail = cleanEmail
                self.licenseKey = cleanKey
                self.plan = "pro_yearly"
                self.expiryDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())

                // Save to UserDefaults
                UserDefaults.standard.set(cleanKey, forKey: "license_key")
                UserDefaults.standard.set(cleanEmail, forKey: "license_email")
                UserDefaults.standard.set(true, forKey: "is_pro")
            }
            return (true, "License activated successfully!")
        }
        #endif

        // Actual API validation
        guard let url = URL(string: API_URL) else {
            return (false, "Invalid API URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10

        let body: [String: String] = [
            "license_key": cleanKey,
            "email": cleanEmail
        ]

        do {
            request.httpBody = try JSONEncoder().encode(body)
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return (false, "Invalid server response")
            }

            if httpResponse.statusCode == 200 {
                let licenseResponse = try JSONDecoder().decode(LicenseResponse.self, from: data)

                if licenseResponse.valid {
                    await MainActor.run {
                        self.isPro = true
                        self.licenseEmail = cleanEmail
                        self.licenseKey = cleanKey
                        self.plan = licenseResponse.plan
                        self.expiryDate = licenseResponse.expiryDate

                        // Save to UserDefaults
                        UserDefaults.standard.set(cleanKey, forKey: "license_key")
                        UserDefaults.standard.set(cleanEmail, forKey: "license_email")
                        UserDefaults.standard.set(true, forKey: "is_pro")
                    }
                    return (true, "License activated successfully!")
                } else {
                    return (false, licenseResponse.message ?? "Invalid license key")
                }
            } else {
                return (false, "Server error: \(httpResponse.statusCode)")
            }
        } catch {
            // If API is not available yet, show friendly message
            return (false, "Could not connect to license server. Please check your internet connection.")
        }
    }

    func checkExistingLicense() {
        if let savedKey = UserDefaults.standard.string(forKey: "license_key"),
           let savedEmail = UserDefaults.standard.string(forKey: "license_email") {
            Task {
                _ = await validateLicense(key: savedKey, email: savedEmail)
            }
        }
    }

    func deactivateLicense() {
        isPro = false
        licenseEmail = ""
        licenseKey = ""
        expiryDate = nil
        plan = ""

        UserDefaults.standard.removeObject(forKey: "license_key")
        UserDefaults.standard.removeObject(forKey: "license_email")
        UserDefaults.standard.set(false, forKey: "is_pro")
    }

    // Feature checks
    func canUseFeature(_ feature: ProFeature) -> Bool {
        switch feature {
        case .aiRename:
            return isPro || TrialManager.shared.isTrialActive || TrialManager.shared.canUseAI()
        case .unlimitedFiles, .allColors, .exportPresets, .unlimitedHistory:
            return isPro || TrialManager.shared.isTrialActive
        }
    }

    func maxFiles() -> Int {
        return (isPro || TrialManager.shared.isTrialActive) ? Int.max : 50
    }

    func availableColors() -> [AccentColor] {
        return (isPro || TrialManager.shared.isTrialActive) ? AccentColor.allCases : [.blue, .purple, .pink]
    }

    func maxHistoryDays() -> Int {
        return (isPro || TrialManager.shared.isTrialActive) ? Int.max : 30
    }
}

struct LicenseResponse: Codable {
    let valid: Bool
    let plan: String
    let expiryDate: Date?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case valid
        case plan
        case expiryDate = "expiry_date"
        case message
    }
}
