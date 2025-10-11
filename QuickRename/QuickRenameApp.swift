import SwiftUI
import AppKit
import Combine

@main
struct QuickRenameApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var viewModel = RenameViewModel()
    var preferencesWindow: NSWindow?
    var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon - we're menubar only
        NSApp.setActivationPolicy(.accessory)

        // Create menubar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "tag", accessibilityDescription: "Namnge")
            button.action = #selector(togglePopover)
            button.target = self

            // Enable drag & drop to menubar icon
            button.window?.registerForDraggedTypes([.fileURL])
            button.window?.delegate = self
        }

        // Observe file count changes
        viewModel.$files
            .sink { [weak self] files in
                self?.updateMenuBarBadge(count: files.count)
            }
            .store(in: &cancellables)

        // Create popover with visual effect (liquid glass)
        popover = NSPopover()
        popover?.contentViewController = NSHostingController(rootView: ContentView().environmentObject(viewModel))
        popover?.behavior = .applicationDefined
        popover?.appearance = NSAppearance(named: .vibrantDark)

        // Setup global hotkey
        setupGlobalHotKey()

        // Listen for preference changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(preferencesChanged),
            name: NSNotification.Name("PreferencesChanged"),
            object: nil
        )

        // Check for updates on launch
        UpdateChecker.shared.checkForUpdates()
    }

    func setupGlobalHotKey() {
        // Check for Accessibility permissions
        checkAccessibilityPermissions()

        let globalShortcut = AppPreferences.shared.shortcut(for: "globalOpenApp")
        GlobalHotKeyManager.shared.registerGlobalHotKey(shortcut: globalShortcut)
        GlobalHotKeyManager.shared.onHotKeyPressed = { [weak self] in
            DispatchQueue.main.async {
                self?.showPopover()
            }
        }
    }

    func checkAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        if !accessEnabled {
            // Show alert to user
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let alert = NSAlert()
                alert.messageText = "Accessibility Permission Required"
                alert.informativeText = "Namnge needs Accessibility permission to use global keyboard shortcuts.\n\nPlease:\n1. Go to System Settings > Privacy & Security > Accessibility\n2. Enable Namnge\n3. Restart Namnge"
                alert.alertStyle = .informational
                alert.addButton(withTitle: "Open System Settings")
                alert.addButton(withTitle: "Later")

                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    // Open System Settings to Accessibility
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                }
            }
        }
    }

    @objc func preferencesChanged() {
        setupGlobalHotKey()
    }

    func showPopover() {
        guard let button = statusItem?.button, let popover = popover else { return }
        if !popover.isShown {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        // Handle files opened via Finder "Open With" or Quick Action
        viewModel.addFiles(urls: urls)

        // Show popover
        if let button = statusItem?.button, let popover = popover {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }

        if let popover = popover {
            if popover.isShown {
                popover.close()
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    @objc func openPreferences() {
        if preferencesWindow == nil {
            let preferencesView = PreferencesView()
            let hostingController = NSHostingController(rootView: preferencesView)

            preferencesWindow = NSWindow(contentViewController: hostingController)
            preferencesWindow?.title = "Namnge Preferences"
            preferencesWindow?.styleMask = [.titled, .closable]
            preferencesWindow?.center()
        }

        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func updateMenuBarBadge(count: Int) {
        guard let button = statusItem?.button else { return }

        if count > 0 {
            // Add badge with file count
            let badgeText = "\(count)"
            button.title = " \(badgeText)"
        } else {
            button.title = ""
        }
    }
}

// MARK: - NSWindowDelegate for Drag & Drop

extension AppDelegate: NSWindowDelegate {
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        guard let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL] else {
            return false
        }

        // Add files to viewModel
        viewModel.addFiles(urls: urls)

        // Show popover
        showPopover()

        return true
    }
}
