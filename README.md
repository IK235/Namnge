# Namnge

AI-powered batch file renaming tool for macOS.

![macOS](https://img.shields.io/badge/macOS-14.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## Features

✨ **9 Rename Patterns**
- Find & Replace
- Sequential Numbers
- Add Prefix/Suffix
- Change Case
- Date Stamps
- Regex Pattern Matching
- AI Smart Rename (Groq & Apple Vision)
- Random String
- Custom Pattern

🎯 **Smart Features**
- AI-powered filename suggestions using Groq API and Apple Vision
- Batch rename multiple files at once
- Real-time preview before applying changes
- Favorites & Presets for quick access
- Undo/Redo history
- Duplicate detection
- Search & filter files

🚀 **Productivity**
- Global hotkey (⌘⌥R) to open from anywhere
- Menubar app - always accessible
- Drag & drop support
- Quick Actions from Finder
- Dark/Light mode support
- Launch at login option

📊 **Additional Features**
- Usage statistics
- Export/Import presets
- Automatic update notifications
- First-time onboarding tutorial

## Installation

### Download
Download the latest release from [Releases](https://github.com/ikbalerdal/Namnge/releases)

### Requirements
- macOS 14.0 or later
- For AI features: Groq API key (free at [groq.com](https://groq.com))

## Usage

1. Launch Namnge from Applications or use the global hotkey ⌘⌥R
2. Add files by:
   - Dragging files to the menubar icon
   - Using "Open With" from Finder
   - Using Quick Actions in Finder
3. Select a rename pattern
4. Configure your settings
5. Preview the changes
6. Click "Rename" to apply

### AI Smart Rename

Namnge can analyze your files and suggest intelligent names:

**Groq API (Text-based)**
- Great for documents, code files, and text
- Requires API key from [groq.com](https://groq.com)

**Apple Vision (Image-based)**
- Perfect for photos and images
- Uses on-device Vision framework
- No API key needed

## Global Hotkey

Press **⌘⌥R** from anywhere in macOS to quickly open Namnge. Customize the hotkey in Preferences.

## Building from Source

```bash
# Clone the repository
git clone https://github.com/ikbalerdal/Namnge.git
cd Namnge

# Open in Xcode
open Namnge.xcodeproj

# Build and run (⌘R)
```

## Configuration

### Groq API Setup
1. Get a free API key from [groq.com](https://groq.com)
2. Open Namnge and select "AI Smart Rename"
3. Choose "Groq (Text-based AI)"
4. Enter your API key
5. Start renaming!

### Accessibility Permission
For the global hotkey to work, Namnge needs Accessibility permission:
1. Go to System Settings > Privacy & Security > Accessibility
2. Enable Namnge
3. Restart Namnge

## Technology Stack

- **SwiftUI** - Modern UI framework
- **AppKit** - Native macOS integration
- **Combine** - Reactive programming
- **Vision** - Apple's on-device image analysis
- **Groq API** - Fast LLM inference
- **ServiceManagement** - Launch at login
- **Carbon** - Global hotkey support

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) file for details

## Author

Created by Ikbal Erdal

## Acknowledgments

- Groq for providing fast AI inference
- Apple Vision framework for image analysis
- SwiftUI community for inspiration

---

Made with ❤️ in Sweden 🇸🇪
