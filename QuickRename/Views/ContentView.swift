import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var viewModel: RenameViewModel
    @StateObject private var history = RenameHistory()
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            // Liquid glass background
            VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                mainView
                    .tabItem {
                        Label("Rename", systemImage: "pencil.and.list.clipboard")
                    }
                    .tag(0)

                historyView
                    .tabItem {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }
                    .tag(1)
            }
        }
        .frame(width: 700, height: 550)
        .onAppear {
            viewModel.history = history
        }
    }

    var mainView: some View {
        HSplitView {
            // Left sidebar - Pattern selection
            VStack(alignment: .leading, spacing: 0) {
                Text("Rename Patterns")
                    .font(.headline)
                    .padding()

                List(RenamePattern.allCases, selection: $viewModel.selectedPattern) { pattern in
                    Label(pattern.rawValue, systemImage: pattern.icon)
                        .tag(pattern)
                }
                .listStyle(.sidebar)
            }
            .frame(minWidth: 200, idealWidth: 220, maxWidth: 280)

            // Center - Settings and Preview
            VStack(spacing: 0) {
                // Settings panel
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Settings")
                            .font(.headline)

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
                        Text("Preview (\(viewModel.files.count) files)")
                            .font(.headline)

                        Spacer()

                        Button(action: { viewModel.clearFiles() }) {
                            Label("Clear", systemImage: "trash")
                        }
                        .disabled(viewModel.files.isEmpty)
                    }
                    .padding([.horizontal, .top])

                    if viewModel.files.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)

                            Text("Drop files here or click to select")
                                .font(.headline)
                                .foregroundStyle(.secondary)

                            Button("Select Files") {
                                viewModel.selectFiles()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(viewModel.files) { file in
                            FileRowView(file: file)
                        }
                        .listStyle(.plain)
                    }
                }
                .background(Color(nsColor: .controlBackgroundColor))
                .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                    viewModel.handleDrop(providers: providers)
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
                            Task {
                                await viewModel.performAIRename()
                            }
                        }) {
                            Label("Generate AI Names", systemImage: "sparkles")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
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

                // Footer with Quit button
                HStack {
                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)

                    Spacer()
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
                                .foregroundStyle(.blue)

                            Text(item.pattern.rawValue)
                                .font(.headline)

                            Spacer()

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
                                    .foregroundStyle(.blue)

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

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: file.hasConflict ? "exclamationmark.circle.fill" : "doc")
                .foregroundStyle(file.hasConflict ? .red : .secondary)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(file.originalName)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.secondary)

                if file.isChanged {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundStyle(.blue)

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
}

struct PatternSettingsView: View {
    let pattern: RenamePattern
    @Binding var operation: RenameOperation

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(pattern.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            switch pattern {
            case .findReplace:
                TextField("Find text", text: $operation.findText)
                TextField("Replace with", text: $operation.replaceText)

            case .sequential:
                HStack {
                    Text("Start at:")
                    TextField("Number", value: $operation.sequentialStart, format: .number)
                        .frame(width: 80)
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

            case .suffix:
                TextField("Suffix text", text: $operation.suffixText)

            case .removeText:
                TextField("Text to remove", text: $operation.removeText)

            case .changeCase:
                Picker("Case style", selection: $operation.caseStyle) {
                    ForEach(CaseStyle.allCases, id: \.self) { style in
                        Text(style.rawValue).tag(style)
                    }
                }

            case .dateStamp:
                TextField("Date format", text: $operation.dateFormat)
                Text("Example: \(formattedDate)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            case .regex:
                TextField("Regex pattern", text: $operation.regexPattern)
                TextField("Replacement", text: $operation.regexReplacement)
                Text("Example: IMG_(\\d+) → Photo_$1")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            case .aiSmart:
                VStack(alignment: .leading, spacing: 12) {
                    Text("🤖 Describe what you want:")
                        .font(.subheadline.bold())

                    TextField("e.g., 'Paris vacation photos' or 'Invoices from Q1 2024'", text: $operation.aiPrompt, axis: .vertical)
                        .lineLimit(2...4)

                    HStack {
                        Text("AI Provider:")
                            .font(.caption)

                        Picker("", selection: $operation.aiProvider) {
                            Text("⚡ Groq (Fast)").tag(AIProvider.groq)
                            Text("🧠 Apple Vision (Local)").tag(AIProvider.local)
                        }
                        .labelsHidden()
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("💡 Tips:")
                            .font(.caption.bold())
                        Text("• Be specific: 'Wedding photos from June 2024'")
                            .font(.caption2)
                        Text("• Mention location, date, or subject")
                            .font(.caption2)
                        Text("• AI works best with images and documents")
                            .font(.caption2)
                    }
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
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
