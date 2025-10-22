import SwiftUI

struct UpgradePromptView: View {
    let feature: ProFeature
    let currentUsage: String?
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var preferences = AppPreferences.shared
    @ObservedObject private var trialManager = TrialManager.shared

    var body: some View {
        VStack(spacing: 20) {
            // Icon and title
            VStack(spacing: 12) {
                Image(systemName: iconForFeature)
                    .font(.system(size: 48))
                    .foregroundStyle(preferences.accentColor.color.gradient)

                Text(titleForFeature)
                    .font(.title2.bold())

                Text(descriptionForFeature)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                if let currentUsage = currentUsage {
                    Text(currentUsage)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)
                }
            }

            // Features list
            VStack(alignment: .leading, spacing: 12) {
                Text("Pro Features:")
                    .font(.headline)

                FeatureRow(icon: "sparkles", text: "Unlimited AI-powered renaming")
                FeatureRow(icon: "doc.on.doc", text: "Rename unlimited files at once")
                FeatureRow(icon: "paintpalette", text: "Access all 8 accent colors")
                FeatureRow(icon: "square.and.arrow.up", text: "Export & import presets")
                FeatureRow(icon: "clock.arrow.circlepath", text: "Unlimited rename history")
            }
            .padding(16)
            .background(preferences.accentColor.color.opacity(0.1))
            .cornerRadius(12)

            // Action buttons
            VStack(spacing: 12) {
                if !trialManager.hasStartedTrial {
                    Button {
                        trialManager.startTrial()
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Start 7-Day Free Trial")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(preferences.accentColor.color)
                    .controlSize(.large)
                }

                Button {
                    NSWorkspace.shared.open(URL(string: "https://namnge.com/pricing")!)
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text(trialManager.hasStartedTrial ? "Upgrade to Pro" : "Buy Pro")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button("Maybe Later") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
        }
        .padding(24)
        .frame(width: 420)
    }

    private var iconForFeature: String {
        switch feature {
        case .aiRename:
            return "sparkles"
        case .unlimitedFiles:
            return "doc.on.doc.fill"
        case .allColors:
            return "paintpalette.fill"
        case .exportPresets:
            return "square.and.arrow.up.fill"
        case .unlimitedHistory:
            return "clock.arrow.circlepath"
        }
    }

    private var titleForFeature: String {
        switch feature {
        case .aiRename:
            return "AI Renaming Limit Reached"
        case .unlimitedFiles:
            return "File Limit Reached"
        case .allColors:
            return "Unlock All Colors"
        case .exportPresets:
            return "Export & Import Presets"
        case .unlimitedHistory:
            return "Unlimited History"
        }
    }

    private var descriptionForFeature: String {
        switch feature {
        case .aiRename:
            return "You've used all 5 AI renames this month. Upgrade to Pro for unlimited AI-powered file renaming."
        case .unlimitedFiles:
            return "Free tier is limited to 50 files at a time. Upgrade to Pro to rename unlimited files in a single batch."
        case .allColors:
            return "Access all 8 beautiful accent colors to customize Namnge to your style."
        case .exportPresets:
            return "Save time by exporting and importing your favorite rename patterns across devices."
        case .unlimitedHistory:
            return "Keep your complete rename history forever with Pro. Free tier stores 30 days."
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    @ObservedObject private var preferences = AppPreferences.shared

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(preferences.accentColor.color)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)

            Spacer()
        }
    }
}

#Preview {
    UpgradePromptView(feature: .aiRename, currentUsage: "5 of 5 AI renames used this month")
}
