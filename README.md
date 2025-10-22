# Namnge

Free & open-source AI-powered batch file renaming tool for macOS.

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
- AI Smart Rename (Apple Vision)
- Random String
- Custom Pattern

🎯 **Smart Features**
- AI-powered filename suggestions using Apple Vision
- Batch rename unlimited files at once
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
- 8 beautiful accent colors

📊 **Additional Features**
- Usage statistics
- Export/Import presets
- Automatic update notifications
- First-time onboarding tutorial

## Installation

### Download
Download the latest release from [GitHub Releases](https://github.com/IK235/Namnge/releases)

### Requirements
- macOS 14.0 (Sonoma) or later
- Apple Silicon or Intel Mac

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

Namnge can analyze your images and suggest intelligent names:

**Apple Vision**
- Perfect for photos and images
- Uses on-device Vision framework
- Completely private - no data leaves your Mac
- No API key needed - works offline!

## Global Hotkey

Press **⌘⌥R** from anywhere in macOS to quickly open Namnge. Customize the hotkey in Preferences.

## Building from Source

```bash
# Clone the repository
git clone https://github.com/IK235/Namnge.git
cd Namnge

# Open in Xcode
open Namnge.xcodeproj

# Build and run (⌘R)
```

## Configuration

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

- Apple Vision framework for on-device AI image analysis
- SwiftUI community for inspiration

---

Made with ❤️ in Sweden 🇸🇪
