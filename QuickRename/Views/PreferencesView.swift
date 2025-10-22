import SwiftUI
import AppKit

struct PreferencesView: View {
    @ObservedObject var preferences = AppPreferences.shared
    @ObservedObject var updateChecker = UpdateChecker.shared
    @ObservedObject var licenseManager = LicenseManager.shared
    @ObservedObject var trialManager = TrialManager.shared
    @State private var editingAction: String? = nil
    @State private var licenseKey: String = ""
    @State private var licenseEmail: String = ""
    @State private var showLicenseAlert: Bool = false
    @State private var licenseAlertMessage: String = ""
    @State private var isValidatingLicense: Bool = false
    @State private var showColorUpgradePrompt: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Preferences")
                    .font(.headline)

                Spacer()

                Button("Reset to Defaults") {
                    preferences.resetToDefaults()
                }
                .buttonStyle(.bordered)
            }
            .padding()

            Divider()

            // Content
            VStack(alignment: .leading, spacing: 20) {
                // General Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("General")
                        .font(.title3.bold())

                    Toggle("Launch at Login", isOn: $preferences.launchAtLogin)

                    Picker("Theme", selection: $preferences.appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 250)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Accent Color")
                            .font(.subheadline)

                        HStack(spacing: 12) {
                            ForEach(AccentColor.allCases, id: \.self) { color in
                                let isLocked = !licenseManager.availableColors().contains(color)

                                Circle()
                                    .fill(color.color.gradient)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(color.color, lineWidth: preferences.accentColor == color ? 3 : 0)
                                    )
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundColor(.white)
                                            .opacity(preferences.accentColor == color ? 1 : 0)
                                    )
                                    .overlay(
                                        Image(systemName: "lock.fill")
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                            .opacity(isLocked ? 1 : 0)
                                    )
                                    .opacity(isLocked ? 0.5 : 1.0)
                                    .onTapGesture {
                                        if isLocked {
                                            showColorUpgradePrompt = true
                                        } else {
                                            withAnimation(.spring(response: 0.3)) {
                                                preferences.accentColor = color
                                            }
                                        }
                                    }
                                    .help(isLocked ? "\(color.rawValue) (Pro)" : color.rawValue)
                            }
                        }
                    }
                }

                Divider()

                // Global Hotkey Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Global Hotkey")
                        .font(.title3.bold())

                    Text("Open Namnge from anywhere in macOS")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ShortcutRow(
                        action: "globalOpenApp",
                        actionName: "Open Namnge",
                        shortcut: preferences.shortcut(for: "globalOpenApp"),
                        isEditing: editingAction == "globalOpenApp",
                        onEdit: {
                            editingAction = "globalOpenApp"
                        },
                        onUpdate: { newShortcut in
                            preferences.shortcuts["globalOpenApp"] = newShortcut
                            editingAction = nil

                            // Notify app to refresh global hotkey
                            NotificationCenter.default.post(
                                name: NSNotification.Name("PreferencesChanged"),
                                object: nil
                            )
                        }
                    )
                }

                Divider()

                // License Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("License")
                            .font(.title3.bold())

                        Spacer()

                        if licenseManager.isPro {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                Text("Pro")
                                    .font(.caption.bold())
                                    .foregroundColor(.yellow)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(6)
                        } else if trialManager.isTrialActive {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.orange)
                                Text("Trial: \(trialManager.trialDaysRemaining) days left")
                                    .font(.caption.bold())
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(6)
                        } else {
                            Text("Free")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(6)
                        }
                    }

                    if licenseManager.isPro {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("License Email:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(licenseManager.licenseEmail)
                                    .font(.caption.bold())
                            }

                            if let expiryDate = licenseManager.expiryDate {
                                HStack {
                                    Text("Expires:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(expiryDate, style: .date)
                                        .font(.caption.bold())
                                }
                            }

                            Button("Deactivate License") {
                                licenseManager.deactivateLicense()
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.red)
                        }
                        .padding(12)
                        .background(preferences.accentColor.color.opacity(0.1))
                        .cornerRadius(8)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            if !trialManager.hasStartedTrial {
                                Button {
                                    trialManager.startTrial()
                                } label: {
                                    HStack {
                                        Image(systemName: "star.fill")
                                        Text("Start 7-Day Pro Trial")
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(preferences.accentColor.color)
                            }

                            Text("Enter your license key to unlock Pro features:")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            TextField("License Key (e.g. NAMNGE-PRO-XXXX-XXXX)", text: $licenseKey)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit { /* Prevent default behavior */ }

                            TextField("Email", text: $licenseEmail)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit { /* Prevent default behavior */ }

                            HStack {
                                Button {
                                    isValidatingLicense = true
                                    Task {
                                        let result = await licenseManager.validateLicense(key: licenseKey, email: licenseEmail)
                                        isValidatingLicense = false
                                        licenseAlertMessage = result.message
                                        showLicenseAlert = true

                                        if result.success {
                                            licenseKey = ""
                                            licenseEmail = ""
                                        }
                                    }
                                } label: {
                                    if isValidatingLicense {
                                        ProgressView()
                                            .controlSize(.small)
                                            .frame(width: 100)
                                    } else {
                                        Text("Activate License")
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(preferences.accentColor.color)
                                .disabled(licenseKey.isEmpty || licenseEmail.isEmpty || isValidatingLicense)

                                Button("Buy Pro") {
                                    NSWorkspace.shared.open(URL(string: "https://namnge.com/pricing")!)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                .alert("License Activation", isPresented: $showLicenseAlert) {
                    Button("OK") { }
                } message: {
                    Text(licenseAlertMessage)
                }

                Divider()

                // Updates Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Updates")
                        .font(.title3.bold())

                    HStack {
                        Text("Check for app updates")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Button("Check Now") {
                            updateChecker.checkForUpdates(manual: true)
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Divider()

                // Instructions
                VStack(alignment: .leading, spacing: 4) {
                    Text("💡 How to use:")
                        .font(.caption.bold())
                    Text("• Click on the shortcut to record a new one")
                        .font(.caption2)
                    Text("• Press Esc to cancel recording")
                        .font(.caption2)
                    Text("• Press Delete/Backspace to clear the shortcut")
                        .font(.caption2)
                }
                .padding(8)
                .background(preferences.accentColor.color.opacity(0.1))
                .cornerRadius(6)

                Spacer()
            }
            .padding()
        }
        .frame(width: 500, height: 680)
        .accentColor(preferences.accentColor.color)
        .tint(preferences.accentColor.color)
        .sheet(isPresented: $showColorUpgradePrompt) {
            UpgradePromptView(feature: .allColors, currentUsage: nil)
        }
    }
}

struct ShortcutRow: View {
    let action: String
    let actionName: String
    let shortcut: KeyboardShortcut
    let isEditing: Bool
    let onEdit: () -> Void
    let onUpdate: (KeyboardShortcut) -> Void

    var body: some View {
        HStack {
            Text(actionName)
                .font(.system(size: 13))

            Spacer()

            if isEditing {
                ShortcutRecorder(onRecord: onUpdate)
                    .frame(width: 120)
            } else {
                Button(action: onEdit) {
                    HStack(spacing: 4) {
                        if shortcut.key.isEmpty {
                            Text("No Shortcut")
                                .foregroundColor(.secondary)
                                .font(.system(size: 12))
                        } else {
                            Text(shortcut.displayString)
                                .font(.system(size: 12, design: .monospaced))
                        }
                        Image(systemName: "pencil.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isEditing ? AppPreferences.shared.accentColor.color.opacity(0.1) : Color.clear)
        .cornerRadius(6)
    }
}

struct ShortcutRecorder: View {
    let onRecord: (KeyboardShortcut) -> Void

    @State private var recordedKey: String = ""
    @State private var recordedModifiers: [String] = []

    var body: some View {
        Text(displayText)
            .font(.system(size: 12, design: .monospaced))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
            .background(AppPreferences.shared.accentColor.color.opacity(0.2))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(AppPreferences.shared.accentColor.color, lineWidth: 2)
            )
            .onAppear {
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    handleKeyPress(event)
                    return nil
                }
            }
    }

    private var displayText: String {
        if recordedKey.isEmpty {
            return "Press keys..."
        }

        let modifierSymbols = recordedModifiers.map { modifier -> String in
            switch modifier {
            case "command": return "⌘"
            case "option": return "⌥"
            case "shift": return "⇧"
            case "control": return "⌃"
            default: return ""
            }
        }
        return (modifierSymbols + [recordedKey.uppercased()]).joined()
    }

    private func handleKeyPress(_ event: NSEvent) {
        // Handle Escape to cancel
        if event.keyCode == 53 {
            onRecord(KeyboardShortcut(key: "", modifiers: []))
            return
        }

        // Handle Delete/Backspace to clear
        if event.keyCode == 51 || event.keyCode == 117 {
            onRecord(KeyboardShortcut(key: "", modifiers: []))
            return
        }

        var modifiers: [String] = []
        if event.modifierFlags.contains(.command) {
            modifiers.append("command")
        }
        if event.modifierFlags.contains(.option) {
            modifiers.append("option")
        }
        if event.modifierFlags.contains(.shift) {
            modifiers.append("shift")
        }
        if event.modifierFlags.contains(.control) {
            modifiers.append("control")
        }

        let key = event.charactersIgnoringModifiers ?? ""

        if !key.isEmpty {
            recordedKey = key
            recordedModifiers = modifiers

            // Auto-submit after recording
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onRecord(KeyboardShortcut(key: recordedKey, modifiers: recordedModifiers))
            }
        }
    }
}

#Preview {
    PreferencesView()
}
