import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    @ObservedObject private var preferences = AppPreferences.shared

    let pages: [(icon: String, title: String, description: String)] = [
        ("tag", "Welcome to Namnge", "Batch rename files quickly and easily with AI-powered suggestions."),
        ("square.grid.2x2", "9 Rename Patterns", "Find & Replace, Sequential Numbers, Add Prefix/Suffix, Change Case, Date Stamps, Regex, and AI Smart Rename."),
        ("sparkles", "AI Smart Rename", "Use Groq or Apple Vision to generate intelligent, context-aware filenames for your photos and documents."),
        ("star.fill", "Favorites & Presets", "Save your frequently used rename patterns as favorites and presets for quick access."),
        ("keyboard", "Global Hotkey", "Press ⌘⌥R from anywhere to open Namnge. Customize it in Preferences."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .padding()
            }

            // Content
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: pages[currentPage].icon)
                    .font(.system(size: 72))
                    .foregroundStyle(preferences.accentColor.color)

                Text(pages[currentPage].title)
                    .font(.title.bold())

                Text(pages[currentPage].description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                // Page indicator dots
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? preferences.accentColor.color : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 16)
            }
            .animation(.easeInOut, value: currentPage)

            // Bottom buttons
            HStack {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button("Skip") {
                        isPresented = false
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()

                if currentPage < pages.count - 1 {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(preferences.accentColor.color)
                } else {
                    Button("Get Started") {
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(preferences.accentColor.color)
                }
            }
            .padding()
        }
        .frame(width: 600, height: 500)
        .accentColor(preferences.accentColor.color)
        .tint(preferences.accentColor.color)
    }
}
