import Foundation
import AppKit

class GlobalHotKeyManager {
    static let shared = GlobalHotKeyManager()

    private var eventMonitor: Any?
    var onHotKeyPressed: (() -> Void)?
    private var currentShortcut: KeyboardShortcut?

    private init() {}

    func registerGlobalHotKey(shortcut: KeyboardShortcut) {
        // Unregister existing hotkey first
        unregisterGlobalHotKey()

        guard !shortcut.key.isEmpty else { return }

        currentShortcut = shortcut

        // Use NSEvent.addGlobalMonitorForEvents instead of Carbon
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }

        // Also monitor local events
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
            return event
        }
    }

    func unregisterGlobalHotKey() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        currentShortcut = nil
    }

    private func handleKeyEvent(_ event: NSEvent) {
        guard let shortcut = currentShortcut else { return }

        // Check if key matches
        let eventKey = event.charactersIgnoringModifiers?.uppercased() ?? ""
        let shortcutKey = shortcut.key.uppercased()

        guard eventKey == shortcutKey else { return }

        // Check modifiers
        var requiredModifiers: NSEvent.ModifierFlags = []
        if shortcut.modifiers.contains("command") {
            requiredModifiers.insert(.command)
        }
        if shortcut.modifiers.contains("option") {
            requiredModifiers.insert(.option)
        }
        if shortcut.modifiers.contains("shift") {
            requiredModifiers.insert(.shift)
        }
        if shortcut.modifiers.contains("control") {
            requiredModifiers.insert(.control)
        }

        // Check if all required modifiers are pressed
        let eventModifiers = event.modifierFlags.intersection([.command, .option, .shift, .control])

        if eventModifiers == requiredModifiers {
            DispatchQueue.main.async {
                self.onHotKeyPressed?()
            }
        }
    }
}
