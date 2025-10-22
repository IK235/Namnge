import Foundation
import Combine

class TrialManager: ObservableObject {
    static let shared = TrialManager()

    @Published var trialDaysRemaining: Int = 0
    @Published var isTrialActive: Bool = false
    @Published var hasTrialEnded: Bool = false
    @Published var hasStartedTrial: Bool = false

    private let trialDuration: Int = 7 // 7 days

    private init() {
        checkTrialStatus()
    }

    func startTrial() {
        guard !hasStartedTrial else { return }

        let trialEndDate = Calendar.current.date(byAdding: .day, value: trialDuration, to: Date())!
        UserDefaults.standard.set(trialEndDate, forKey: "trial_end_date")
        UserDefaults.standard.set(true, forKey: "trial_started")
        UserDefaults.standard.set(Date(), forKey: "trial_start_date")

        checkTrialStatus()
    }

    func checkTrialStatus() {
        hasStartedTrial = UserDefaults.standard.bool(forKey: "trial_started")

        guard let trialEndDate = UserDefaults.standard.object(forKey: "trial_end_date") as? Date else {
            isTrialActive = false
            hasTrialEnded = hasStartedTrial
            return
        }

        let now = Date()
        if now < trialEndDate {
            isTrialActive = true
            hasTrialEnded = false
            let components = Calendar.current.dateComponents([.day], from: now, to: trialEndDate)
            trialDaysRemaining = max(0, (components.day ?? 0) + 1)
        } else {
            isTrialActive = false
            hasTrialEnded = true
            trialDaysRemaining = 0
        }
    }

    // AI Usage Tracking (Free tier: 5 per month)
    func incrementAIUsage() {
        let currentMonth = Calendar.current.dateComponents([.year, .month], from: Date())
        let monthKey = "\(currentMonth.year!)-\(currentMonth.month!)"
        let usageKey = "ai_usage_\(monthKey)"

        let currentUsage = UserDefaults.standard.integer(forKey: usageKey)
        UserDefaults.standard.set(currentUsage + 1, forKey: usageKey)
    }

    func getAIUsageCount() -> Int {
        let currentMonth = Calendar.current.dateComponents([.year, .month], from: Date())
        let monthKey = "\(currentMonth.year!)-\(currentMonth.month!)"
        let usageKey = "ai_usage_\(monthKey)"

        return UserDefaults.standard.integer(forKey: usageKey)
    }

    func canUseAI() -> Bool {
        // Pro users have unlimited AI
        if LicenseManager.shared.isPro {
            return true
        }

        // Trial users have unlimited AI
        if isTrialActive {
            return true
        }

        // Free users: 5 AI renames per month
        return getAIUsageCount() < 5
    }

    func getRemainingAIUsage() -> Int {
        if LicenseManager.shared.isPro || isTrialActive {
            return Int.max
        }
        return max(0, 5 - getAIUsageCount())
    }
}
