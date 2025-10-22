import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var viewModel: RenameViewModel
    @StateObject private var history = RenameHistory()
    @StateObject private var presetManager = PresetManager.shared
    @ObservedObject private var preferences = AppPreferences.shared
    @ObservedObject private var updateChecker = UpdateChecker.shared
    @ObservedObject private var licenseManager = LicenseManager.shared
    @ObservedObject private var trialManager = TrialManager.shared
    @State private var selectedTab = 0
    @State private var showSavePresetDialog = false
    @State private var showLoadPresetMenu = false
    @State private var presetName = ""
    @State private var searchText = ""
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    @State private var preferencesWindowInstance: NSWindow?
    @State private var showUpgradePrompt = false
    @State private var upgradeFeature: ProFeature = .aiRename
    @State private var upgradeUsageInfo: String?

    var filteredFiles: [FileItem] {
        if searchText.isEmpty {
            return viewModel.files
        } else {
            return viewModel.files.filter { file in
                file.originalName.localizedCaseInsensitiveContains(searchText) ||
                file.newName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    func openPreferences() {
        if preferencesWindowInstance == nil {
            let preferencesView = PreferencesView()
            let hostingController = NSHostingController(rootView: preferencesView)

            let window = NSWindow(contentViewController: hostingController)
            window.title = "Namnge Preferences"
            window.styleMask = [.titled, .closable]
            window.center()

            preferencesWindowInstance = window
        }

        preferencesWindowInstance?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    var body: some View {
        ZStack {
            // Liquid glass background
            VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Tab Bar
                HStack(spacing: 4) {
                    Button {
                        withAnimation {
                            selectedTab = 0
                        }
                    } label: {
                        Label("Rename", systemImage: "tag")
                            .font(.system(size: 11))
                            .foregroundColor(selectedTab == 0 ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(selectedTab == 0 ? preferences.accentColor.color : Color.clear)
                            .cornerRadius(5)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Button {
                        withAnimation {
                            selectedTab = 1
                        }
                    } label: {
                        Label("History", systemImage: "clock.arrow.circlepath")
                            .font(.system(size: 11))
                            .foregroundColor(selectedTab == 1 ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(selectedTab == 1 ? preferences.accentColor.color : Color.clear)
                            .cornerRadius(5)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(4)

                // Update banner
                if updateChecker.updateAvailable {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundStyle(preferences.accentColor.color)

                        Text("Update available: v\(updateChecker.latestVersion)")
                            .font(.caption)

                        Spacer()

                        Button("Download") {
                            if let url = URL(string: updateChecker.downloadURL) {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .tint(preferences.accentColor.color)

                        Button {
                            updateChecker.dismissUpdate()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(preferences.accentColor.color.opacity(0.1))
                }

                // Content based on selected tab
                if selectedTab == 0 {
                    mainView
                } else {
                    historyView
                }
            }
        }
        .frame(width: 700, height: 550)
        .accentColor(preferences.accentColor.color)
        .onAppear {
            viewModel.history = history
        }
        .sheet(isPresented: $showSavePresetDialog) {
            SavePresetDialog(
                presetName: $presetName,
                onSave: {
                    if !presetName.isEmpty {
                        presetManager.savePreset(name: presetName, operation: viewModel.operation)
                        presetName = ""
                        showSavePresetDialog = false
                    }
                },
                onCancel: {
                    presetName = ""
                    showSavePresetDialog = false
                }
            )
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
                .onDisappear {
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                }
        }
        .sheet(isPresented: $showUpgradePrompt) {
            UpgradePromptView(feature: upgradeFeature, currentUsage: upgradeUsageInfo)
        }
        .tint(preferences.accentColor.color)
    }

    var mainView: some View {
        HSplitView {
            // Left sidebar - Pattern selection
            VStack(alignment: .leading, spacing: 0) {
                Text("Rename Patterns")
                    .font(.headline)
                    .padding()

                List(RenamePattern.allCases, selection: $viewModel.selectedPattern) { pattern in
                    HStack {
                        Label(pattern.rawValue, systemImage: pattern.icon)
                            .foregroundStyle(.white)

                        Spacer()

                        Image(systemName: preferences.isFavorite(pattern) ? "star.fill" : "star")
                            .foregroundStyle(preferences.isFavorite(pattern) ? .yellow : .secondary)
                            .scaleEffect(preferences.isFavorite(pattern) ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: preferences.isFavorite(pattern))
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    preferences.toggleFavorite(pattern)
                                }
                            }
                    }
                    .tag(pattern)
                    .contentShape(Rectangle())
                    .listRowBackground(
                        viewModel.selectedPattern == pattern ?
                            preferences.accentColor.color : Color.clear
                    )
                }
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
            }
            .frame(minWidth: 200, idealWidth: 220, maxWidth: 280)

            // Center - Settings and Preview
            VStack(spacing: 0) {
                // Settings panel
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Settings")
                                .font(.headline)

                            Spacer()

                            // Preset buttons
                            Menu {
                                ForEach(presetManager.presets) { preset in
                                    Button(preset.name) {
                                        let operation = preset.toOperation()
                                        viewModel.selectedPattern = operation.pattern
                                        viewModel.operation = operation
                                    }
                                }

                                if presetManager.presets.isEmpty {
                                    Text("No presets saved")
                                }

                                Divider()

                                Button {
                                    if !licenseManager.canUseFeature(.exportPresets) {
                                        upgradeFeature = .exportPresets
                                        upgradeUsageInfo = nil
                                        showUpgradePrompt = true
                                    } else {
                                        _ = presetManager.importPresets()
                                    }
                                } label: {
                                    HStack {
                                        Label("Import Presets...", systemImage: "square.and.arrow.down")
                                        if !licenseManager.canUseFeature(.exportPresets) {
                                            Image(systemName: "lock.fill")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }

                                Button {
                                    if !licenseManager.canUseFeature(.exportPresets) {
                                        upgradeFeature = .exportPresets
                                        upgradeUsageInfo = nil
                                        showUpgradePrompt = true
                                    } else {
                                        _ = presetManager.exportPresets()
                                    }
                                } label: {
                                    HStack {
                                        Label("Export Presets...", systemImage: "square.and.arrow.up")
                                        if !licenseManager.canUseFeature(.exportPresets) {
                                            Image(systemName: "lock.fill")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .disabled(presetManager.presets.isEmpty && licenseManager.canUseFeature(.exportPresets))
                            } label: {
                                Label("Load", systemImage: "folder")
                            }
                            .tint(preferences.accentColor.color)

                            Button {
                                showSavePresetDialog = true
                            } label: {
                                Label("Save", systemImage: "square.and.arrow.down")
                            }
                            .tint(preferences.accentColor.color)
                        }

                        PatternSettingsView(
                            pattern: viewModel.selectedPattern,
                            operation: $viewModel.operation
                        )
                    }
                    .padding()
                }
                .frame(maxHeight: 300)

                Divider()

                // File list with preview
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Preview (\(filteredFiles.count) files)")
                            .font(.headline)

                        // File limit indicator for free users
                        if !licenseManager.isPro && !trialManager.isTrialActive {
                            let maxFiles = licenseManager.maxFiles()
                            Text("\(viewModel.files.count)/\(maxFiles)")
                                .font(.caption.bold())
                                .foregroundColor(viewModel.files.count >= maxFiles ? .red : .secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(viewModel.files.count >= maxFiles ? Color.red.opacity(0.2) : Color.secondary.opacity(0.1))
                                .cornerRadius(4)
                        }

                        if viewModel.hasConflicts {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                            Text("Duplicates detected")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        Spacer()

                        // Sort menu
                        Menu {
                            Button {
                                viewModel.sortFiles(by: .name)
                            } label: {
                                Label("Name (A-Z)", systemImage: "textformat.abc")
                            }

                            Button {
                                viewModel.sortFiles(by: .size)
                            } label: {
                                Label("Size", systemImage: "arrow.up.arrow.down")
                            }

                            Button {
                                viewModel.sortFiles(by: .date)
                            } label: {
                                Label("Date Modified", systemImage: "calendar")
                            }
                        } label: {
                            Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                        }
                        .tint(preferences.accentColor.color)
                        .disabled(viewModel.files.isEmpty)

                        Button(action: { viewModel.clearFiles() }) {
                            Label("Clear", systemImage: "trash")
                        }
                        .tint(preferences.accentColor.color)
                        .disabled(viewModel.files.isEmpty)
                    }
                    .padding([.horizontal, .top])

                    // Search field
                    if !viewModel.files.isEmpty {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                            TextField("Search files...", text: $searchText)
                                .textFieldStyle(.plain)
                                .onSubmit { /* Prevent default behavior */ }
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(8)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(6)
                        .padding(.horizontal)
                    }

                    if viewModel.files.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)

                            Text("Drop files here or click to select")
                                .font(.headline)
                                .foregroundStyle(.secondary)

                            Button("Select Files") {
                                let oldCount = viewModel.files.count
                                viewModel.selectFiles()

                                // Check if we hit the file limit
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    let maxFiles = licenseManager.maxFiles()
                                    if viewModel.files.count >= maxFiles && oldCount < maxFiles {
                                        upgradeFeature = .unlimitedFiles
                                        upgradeUsageInfo = "\(viewModel.files.count) of \(maxFiles) files (limit reached)"
                                        showUpgradePrompt = true
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(preferences.accentColor.color)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(filteredFiles) { file in
                            FileRowView(file: file)
                        }
                        .listStyle(.plain)
                    }
                }
                .background(Color(nsColor: .controlBackgroundColor))
                .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                    let oldCount = viewModel.files.count
                    viewModel.handleDrop(providers: providers)

                    // Check if we hit the file limit
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        let maxFiles = licenseManager.maxFiles()
                        if viewModel.files.count >= maxFiles && oldCount < maxFiles {
                            upgradeFeature = .unlimitedFiles
                            upgradeUsageInfo = "\(viewModel.files.count) of \(maxFiles) files (limit reached)"
                            showUpgradePrompt = true
                        }
                    }
                    return true
                }

                Divider()

                // Action buttons
                HStack {
                    if let error = viewModel.errorMessage {
                        Label(error, systemImage: viewModel.errorMessage?.hasPrefix("✓") == true ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(viewModel.errorMessage?.hasPrefix("✓") == true ? .green : .red)
                            .font(.caption)
                    }

                    Spacer()

                    // AI Generate button (only for AI Smart pattern)
                    if viewModel.selectedPattern == .aiSmart {
                        Button(action: {
                            // Check if user can use AI
                            if !licenseManager.canUseFeature(.aiRename) {
                                upgradeFeature = .aiRename
                                upgradeUsageInfo = "\(trialManager.getAIUsageCount()) of 5 AI renames used this month"
                                showUpgradePrompt = true
                                return
                            }

                            Task {
                                await viewModel.performAIRename()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Label("Generate AI Names", systemImage: "sparkles")

                                // Show remaining AI usage for free users
                                if !licenseManager.isPro && !trialManager.isTrialActive {
                                    Text("(\(trialManager.getRemainingAIUsage()) left)")
                                        .font(.caption)
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(preferences.accentColor.color)
                        .disabled(viewModel.files.isEmpty || viewModel.operation.aiPrompt.isEmpty)
                    }

                    if viewModel.hasRenamed {
                        Button("Undo") {
                            viewModel.undo()
                        }
                        .keyboardShortcut("z", modifiers: .command)
                    }

                    if viewModel.selectedPattern != .aiSmart {
                        Button("Rename \(viewModel.changedFilesCount) Files") {
                            viewModel.performRename()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(preferences.accentColor.color)
                        .disabled(viewModel.changedFilesCount == 0 || viewModel.hasConflicts)
                        .keyboardShortcut(.return, modifiers: .command)
                    } else {
                        Button("Apply Renames") {
                            viewModel.performRename()
                        }
                        .buttonStyle(.bordered)
                        .disabled(viewModel.changedFilesCount == 0 || viewModel.hasConflicts)
                    }
                }
                .padding()

                Divider()

                // Footer with Preferences and Quit buttons
                HStack {
                    Button("Preferences") {
                        openPreferences()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(preferences.accentColor.color)
                    .keyboardShortcut(",", modifiers: .command)

                    Spacer()

                    // Usage statistics
                    if history.totalFilesRenamed > 0 {
                        Text("\(history.totalFilesRenamed) files renamed")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(6)
                    }

                    Spacer()

                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    .keyboardShortcut("q", modifiers: .command)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(nsColor: .windowBackgroundColor))
            }
        }
    }

    var historyView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Rename History")
                    .font(.headline)

                Spacer()

                Button("Clear History") {
                    history.clear()
                }
                .disabled(history.items.isEmpty)
            }
            .padding()

            Divider()

            if history.items.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)

                    Text("No rename history yet")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text("Your rename operations will appear here")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(history.items) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: item.pattern.icon)
                                .foregroundStyle(preferences.accentColor.color)

                            Text(item.pattern.rawValue)
                                .font(.headline)

                            Spacer()

                            Button {
                                let success = history.undoRename(item)
                                if success {
                                    // Refresh the file list in rename tab
                                    viewModel.refreshFiles()
                                }
                            } label: {
                                Label("Undo", systemImage: "arrow.uturn.backward")
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)

                            Text(item.formattedDate)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text("\(item.fileCount) files renamed")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        ForEach(item.files.prefix(3), id: \.original) { file in
                            HStack(spacing: 4) {
                                Text(file.original)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.secondary)

                                Image(systemName: "arrow.right")
                                    .font(.caption2)
                                    .foregroundStyle(preferences.accentColor.color)

                                Text(file.new)
                                    .font(.system(.caption, design: .monospaced))
                            }
                        }

                        if item.files.count > 3 {
                            Text("+ \(item.files.count - 3) more files")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
    }
}


struct FileRowView: View {
    let file: FileItem
    @State private var thumbnail: NSImage?
    @ObservedObject private var preferences = AppPreferences.shared

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail or icon
            Group {
                if let thumbnail = thumbnail {
                    Image(nsImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    Image(systemName: file.hasConflict ? "exclamationmark.circle.fill" : iconForFile(file.url))
                        .foregroundStyle(file.hasConflict ? .red : .secondary)
                        .font(.title3)
                        .frame(width: 40, height: 40)
                }
            }
            .onAppear {
                loadThumbnail()
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(file.originalName)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(file.formattedFileSize)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                }

                if file.isChanged {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundStyle(preferences.accentColor.color)

                        Text(file.newName)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(file.hasConflict ? .red : .primary)
                    }
                }
            }

            Spacer()

            if file.hasConflict {
                Text("CONFLICT")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }

    private func loadThumbnail() {
        let url = file.url
        DispatchQueue.global(qos: .userInitiated).async {
            let size = CGSize(width: 80, height: 80)
            let image = NSWorkspace.shared.icon(forFile: url.path)

            // Try to get actual thumbnail for images
            if let cgImage = NSImage(contentsOf: url)?.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                let thumbnail = NSImage(cgImage: cgImage, size: size)
                DispatchQueue.main.async {
                    self.thumbnail = thumbnail
                }
            } else {
                // Use file icon
                DispatchQueue.main.async {
                    self.thumbnail = image
                }
            }
        }
    }

    private func iconForFile(_ url: URL) -> String {
        let ext = url.pathExtension.lowercased()

        switch ext {
        case "jpg", "jpeg", "png", "gif", "heic", "webp":
            return "photo"
        case "mp4", "mov", "avi", "mkv":
            return "video"
        case "mp3", "wav", "m4a", "flac":
            return "music.note"
        case "pdf":
            return "doc.richtext"
        case "doc", "docx", "txt", "rtf":
            return "doc.text"
        case "xls", "xlsx", "numbers":
            return "tablecells"
        case "zip", "rar", "7z":
            return "archivebox"
        default:
            return "doc"
        }
    }
}

struct PatternSettingsView: View {
    let pattern: RenamePattern
    @Binding var operation: RenameOperation
    @ObservedObject private var preferences = AppPreferences.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(pattern.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            switch pattern {
            case .findReplace:
                TextField("Find text", text: $operation.findText)
                    .onSubmit { /* Prevent default behavior */ }
                TextField("Replace with", text: $operation.replaceText)
                    .onSubmit { /* Prevent default behavior */ }

            case .sequential:
                HStack {
                    Text("Start at:")
                    TextField("Number", value: $operation.sequentialStart, format: .number)
                        .frame(width: 80)
                        .onSubmit { /* Prevent default behavior */ }
                }
                HStack {
                    Text("Padding:")
                    Picker("", selection: $operation.sequentialPadding) {
                        Text("1 (1, 2, 3)").tag(1)
                        Text("2 (01, 02, 03)").tag(2)
                        Text("3 (001, 002, 003)").tag(3)
                        Text("4 (0001, 0002, 0003)").tag(4)
                    }
                    .labelsHidden()
                }

            case .prefix:
                TextField("Prefix text", text: $operation.prefixText)
                    .onSubmit { /* Prevent default behavior */ }

            case .suffix:
                TextField("Suffix text", text: $operation.suffixText)
                    .onSubmit { /* Prevent default behavior */ }

            case .removeText:
                TextField("Text to remove", text: $operation.removeText)
                    .onSubmit { /* Prevent default behavior */ }

            case .changeCase:
                Picker("Case style", selection: $operation.caseStyle) {
                    ForEach(CaseStyle.allCases, id: \.self) { style in
                        Text(style.rawValue).tag(style)
                    }
                }

            case .dateStamp:
                TextField("Date format", text: $operation.dateFormat)
                    .onSubmit { /* Prevent default behavior */ }
                Text("Example: \(formattedDate)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            case .regex:
                TextField("Regex pattern", text: $operation.regexPattern)
                    .onSubmit { /* Prevent default behavior */ }
                TextField("Replacement", text: $operation.regexReplacement)
                    .onSubmit { /* Prevent default behavior */ }
                Text("Example: IMG_(\\d+) → Photo_$1")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            case .aiSmart:
                VStack(alignment: .leading, spacing: 12) {
                    Text("🤖 Describe what you want:")
                        .font(.subheadline.bold())

                    TextField("e.g., 'Paris vacation photos' or 'Invoices from Q1 2024'", text: $operation.aiPrompt, axis: .vertical)
                        .lineLimit(2...4)
                        .onSubmit { /* Prevent default behavior */ }

                    Text("✨ Powered by Apple Vision AI (on-device)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("💡 Tips:")
                            .font(.caption.bold())
                        Text("• Be specific: 'Wedding photos from June 2024'")
                            .font(.caption2)
                        Text("• Mention location, date, or subject")
                            .font(.caption2)
                        Text("• Works best with images - fully offline & private")
                            .font(.caption2)
                    }
                    .padding(8)
                    .background(preferences.accentColor.color.opacity(0.1))
                    .cornerRadius(6)
                }
            }
        }
        .textFieldStyle(.roundedBorder)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = operation.dateFormat
        return formatter.string(from: Date())
    }
}

// MARK: - Save Preset Dialog

struct SavePresetDialog: View {
    @Binding var presetName: String
    let onSave: () -> Void
    let onCancel: () -> Void
    @ObservedObject private var preferences = AppPreferences.shared

    var body: some View {
        VStack(spacing: 20) {
            Text("Save Preset")
                .font(.headline)

            TextField("Preset name (e.g. 'Travel Photos')", text: $presetName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
                .onSubmit { /* Prevent default behavior */ }

            HStack(spacing: 12) {
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.escape)

                Button("Save") {
                    onSave()
                }
                .keyboardShortcut(.return)
                .disabled(presetName.isEmpty)
                .buttonStyle(.borderedProminent)
                .tint(preferences.accentColor.color)
            }
        }
        .padding()
        .frame(width: 350, height: 150)
    }
}

// MARK: - Visual Effect Blur (Liquid Glass)

struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}

#Preview {
    ContentView()
        .environmentObject(RenameViewModel())
}
