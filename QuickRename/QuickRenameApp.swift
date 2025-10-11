import SwiftUI
import AppKit

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

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon - we're menubar only
        NSApp.setActivationPolicy(.accessory)

        // Create menubar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "pencil.and.list.clipboard", accessibilityDescription: "QuickRename")
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Create popover
        popover = NSPopover()
        popover?.contentViewController = NSHostingController(rootView: ContentView().environmentObject(viewModel))
        popover?.behavior = .transient
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
}
