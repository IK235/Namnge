# QuickRename 🖊️

Modern batch file renaming tool for macOS with menubar integration and live preview.

## Features ✨

### Current Version: v1.0

- **🎯 8 Rename Patterns:**
  - Find & Replace - Replace text in filenames
  - Sequential Numbers - Add numbered sequences (001, 002, etc.)
  - Add Prefix - Add text to the beginning
  - Add Suffix - Add text to the end
  - Remove Text - Remove specific text
  - Change Case - Uppercase, lowercase, title case, camelCase, snake_case
  - Add Date - Add current date/time with custom format
  - Regex Pattern - Advanced pattern matching

- **👀 Live Preview**
  - See changes before applying
  - Visual arrows showing old → new names
  - Conflict detection (highlights duplicates in red)
  - Shows number of files that will be changed

- **🎨 Modern Interface**
  - Clean SwiftUI design
  - Menubar app (always accessible)
  - Three-panel layout
  - Drag & drop support

- **🛡️ Safety Features**
  - Conflict detection
  - Undo functionality (Cmd+Z)
  - History tab showing all operations
  - Files stay in list after rename

- **⌨️ Keyboard Shortcuts**
  - Cmd+Return - Rename files
  - Cmd+Z - Undo last operation
  - Escape - Close popover

## Installation 🚀

1. Open `QuickRename.xcodeproj` in Xcode
2. Build and run (Cmd+R)
3. App appears in menubar with pencil icon 🖊️

## Usage 📝

### Method 1: Menubar
1. Click pencil icon in menubar
2. Drag & drop files or click "Select Files"
3. Choose rename pattern
4. See live preview
5. Click "Rename X Files" or press Cmd+Return

### Method 2: Finder Extension
1. Right-click files in Finder
2. Services → "Rename with QuickRename"
3. App opens with files loaded

### Method 3: Quick Action
1. Right-click files in Finder
2. Services → "Rename with QuickRename"
3. Opens menubar app automatically

## Use Cases 💡

### 1. Inconsistent Invoice Names
**Before:**
- `FAKTURA MAJ 2024.pdf`
- `Faktura Mars 2024.pdf`
- `faktura_april_2024.pdf`

**Solution:** Change Case → Title Case

**After:**
- `Faktura Maj 2024.pdf`
- `Faktura Mars 2024.pdf`
- `Faktura April 2024.pdf`

### 2. Number Receipts
**Before:**
- `Kvitto 001.jpg`
- `Kvitto 002.jpg`

**Solution:** Sequential Numbers (001, 002, 003)

**After:**
- `Kvitto_001.jpg`
- `Kvitto_002.jpg`
- `Kvitto_003.jpg`

### 3. Clean Up "FINAL" Chaos
**Before:**
- `projekt_presentation_final.pptx`
- `projekt_presentation_FINAL_v2.pptx`
- `projekt_presentation_FINAL_FINAL.pptx`

**Solution:** Remove Text → "_FINAL", "_final", "_v2"

**After:**
- `projekt_presentation.pptx`

## Project Structure 📂

```
QuickRename/
├── QuickRenameApp.swift          # Menubar app entry point
├── Info.plist                    # App configuration
├── QuickRename.entitlements      # File access permissions
├── Models/
│   ├── FileItem.swift           # File model
│   ├── RenamePattern.swift      # 8 rename patterns
│   ├── RenameViewModel.swift    # App logic
│   └── RenameHistory.swift      # History tracking
├── Services/
│   └── RenameService.swift      # Rename engine
└── Views/
    └── ContentView.swift        # Main UI (Rename + History tabs)

QuickRenameExtension/
├── ActionViewController.swift   # Finder extension entry
├── Info.plist                   # Extension configuration
└── QuickRenameExtension.entitlements
```

## Development 🛠️

### Requirements
- macOS 14.0+
- Xcode 15.0+
- Swift 5.0+

### Building
```bash
cd /Users/ikbalerdal/Documents/QuickRename
xcodebuild -project QuickRename.xcodeproj -scheme QuickRename -configuration Debug build
```

### Installing
```bash
cp -R build/Debug/QuickRename.app /Applications/
```

### Git Workflow
```bash
# Current stable version
git checkout main

# Create feature branch
git checkout -b feature/ai-rename

# Commit changes
git add .
git commit -m "Add AI smart rename feature"

# Merge back to main when stable
git checkout main
git merge feature/ai-rename
```

## Backups 💾

**Manual Backup:**
```bash
cp -R QuickRename QuickRename-Backup-$(date +%Y%m%d-%H%M%S)
```

**Latest Backup:**
- `/Users/ikbalerdal/Documents/QuickRename-Backup-20251011-094433/`

## Roadmap 🗺️

See [PRODUCT-ROADMAP.md](PRODUCT-ROADMAP.md) for detailed future plans.

### Upcoming Features:
- **v1.1:** Templates/Presets, Better keyboard shortcuts
- **v2.0:** AI Smart Rename (game changer! 🤖)
- **v2.5:** AI Auto-Organize folders
- **v3.0:** OCR, Voice commands, Metadata enrichment

## Version History 📜

### v1.0 (2024-10-11) - Initial Release
- ✅ 8 rename patterns
- ✅ Live preview with conflict detection
- ✅ Menubar app
- ✅ Finder extension integration
- ✅ History tab
- ✅ Undo functionality
- ✅ Modern SwiftUI design

## Known Issues 🐛

- Extension requires manual registration on first install
- Files must be manually cleared from list (not auto-cleared)
- History limited to 50 items

## License 📄

Private project - All rights reserved.

## Contact 📧

Built by ikbalerdal
- Project: QuickRename
- Started: October 11, 2024
- Location: Sweden 🇸🇪

---

**Pro tip:** Use History tab to review all your rename operations! 📜✨
