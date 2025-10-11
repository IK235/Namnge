import Foundation
import SwiftUI
import AppKit
import Combine
import ServiceManagement

// MARK: - Appearance Mode

enum AppearanceMode: String, Codable, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
}

// MARK: - Accent Color

enum AccentColor: String, Codable, CaseIterable {
    case blue = "Blue"
    case purple = "Purple"
    case pink = "Pink"
    case red = "Red"
    case orange = "Orange"
    case yellow = "Yellow"
    case green = "Green"
    case teal = "Teal"

    var color: Color {
        switch self {
        case .blue: return .blue
        case .purple: return .purple
        case .pink: return .pink
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .teal: return .teal
        }
    }
}

// MARK: - Keyboard Shortcut

struct KeyboardShortcut: Codable, Hashable {
    var key: String
    var modifiers: [String] // "command", "option", "shift", "control"

    var displayString: String {
        let modifierSymbols = modifiers.map { modifier -> String in
            switch modifier {
            case "command": return "⌘"
            case "option": return "⌥"
            case "shift": return "⇧"
            case "control": return "⌃"
            default: return ""
            }
        }
        return (modifierSymbols + [key.uppercased()]).joined()
    }

    static let `default` = KeyboardShortcut(key: "", modifiers: [])
}

// MARK: - App Preferences

class AppPreferences: ObservableObject {
    static let shared = AppPreferences()

    @Published var shortcuts: [String: KeyboardShortcut] = [:] {
        didSet {
            saveShortcuts()
        }
    }

    @Published var favoritePatterns: Set<String> = [] {
        didSet {
            saveFavorites()
        }
    }

    @Published var appearanceMode: AppearanceMode = .system {
        didSet {
            saveAppearance()
            applyAppearance()
        }
    }

    @Published var launchAtLogin: Bool = false {
        didSet {
            saveLaunchAtLogin()
            applyLaunchAtLogin()
        }
    }

    @Published var accentColor: AccentColor = .blue {
        didSet {
            saveAccentColor()
        }
    }

    // Default shortcuts (only global hotkey)
    private let defaultShortcuts: [String: KeyboardShortcut] = [
        "globalOpenApp": KeyboardShortcut(key: "R", modifiers: ["command", "option"])
    ]

    private init() {
        loadShortcuts()
        loadFavorites()
        loadAppearance()
        loadLaunchAtLogin()
        loadAccentColor()
        applyAppearance()
    }

    func shortcut(for action: String) -> KeyboardShortcut {
        return shortcuts[action] ?? defaultShortcuts[action] ?? .default
    }

    func resetToDefaults() {
        shortcuts = defaultShortcuts
    }

    // MARK: - Persistence

    private func saveShortcuts() {
        if let encoded = try? JSONEncoder().encode(shortcuts) {
            UserDefaults.standard.set(encoded, forKey: "keyboardShortcuts")
        }
    }

    private func loadShortcuts() {
        if let data = UserDefaults.standard.data(forKey: "keyboardShortcuts"),
           let decoded = try? JSONDecoder().decode([String: KeyboardShortcut].self, from: data) {
            shortcuts = decoded
        } else {
            shortcuts = defaultShortcuts
        }
    }

    func toggleFavorite(_ pattern: RenamePattern) {
        if favoritePatterns.contains(pattern.rawValue) {
            favoritePatterns.remove(pattern.rawValue)
        } else {
            favoritePatterns.insert(pattern.rawValue)
        }
    }

    func isFavorite(_ pattern: RenamePattern) -> Bool {
        favoritePatterns.contains(pattern.rawValue)
    }

    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(Array(favoritePatterns)) {
            UserDefaults.standard.set(encoded, forKey: "favoritePatterns")
        }
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: "favoritePatterns"),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            favoritePatterns = Set(decoded)
        }
    }

    private func saveAppearance() {
        UserDefaults.standard.set(appearanceMode.rawValue, forKey: "appearanceMode")
    }

    private func loadAppearance() {
        if let savedMode = UserDefaults.standard.string(forKey: "appearanceMode"),
           let mode = AppearanceMode(rawValue: savedMode) {
            appearanceMode = mode
        }
    }

    func applyAppearance() {
        DispatchQueue.main.async {
            switch self.appearanceMode {
            case .light:
                NSApp.appearance = NSAppearance(named: .aqua)
            case .dark:
                NSApp.appearance = NSAppearance(named: .darkAqua)
            case .system:
                NSApp.appearance = nil
            }
        }
    }

    private func saveLaunchAtLogin() {
        UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
    }

    private func loadLaunchAtLogin() {
        launchAtLogin = UserDefaults.standard.bool(forKey: "launchAtLogin")
    }

    func applyLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            if launchAtLogin {
                try? SMAppService.mainApp.register()
            } else {
                try? SMAppService.mainApp.unregister()
            }
        }
    }

    private func saveAccentColor() {
        UserDefaults.standard.set(accentColor.rawValue, forKey: "accentColor")
    }

    private func loadAccentColor() {
        if let savedColor = UserDefaults.standard.string(forKey: "accentColor"),
           let color = AccentColor(rawValue: savedColor) {
            accentColor = color
        }
    }
}

// MARK: - Shortcut Action Names

extension AppPreferences {
    static let actionNames: [String: String] = [
        "globalOpenApp": "Open Namnge"
    ]
}
