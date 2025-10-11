# QuickRename - Product Roadmap 🚀

## Current Version: v1.0 ✅
- ✅ 8 Rename Patterns (Find & Replace, Sequential, Case, etc.)
- ✅ Live Preview
- ✅ Conflict Detection
- ✅ Undo Functionality
- ✅ History Tab
- ✅ Menubar App
- ✅ Finder Extension
- ✅ Drag & Drop

---

## 🤖 AI Features - Future Versions

### Version 2.0 - AI Smart Rename
**Priority: HIGH** 🔥

#### Feature 1: "AI Describe & Rename"
- **What:** AI reads image/document content and suggests descriptive names
- **Examples:**
  - `IMG_1234.jpg` → AI sees photo → `Paris-Eiffel-Tower-Sunset.jpg`
  - `Skärmbild 2024-10-11.png` → AI reads text → `Swift-Code-Editor-Screenshot.png`
  - `scan0001.pdf` → OCR + AI → `Hyreskontrakt-Storgatan-12.pdf`
- **Tech:** OpenAI Vision API or Claude 3.5 Sonnet
- **Use Case:** Organize 100s of vacation photos in seconds

#### Feature 2: "AI Batch Prompt Rename"
- **What:** User writes one prompt, AI names entire batch intelligently
- **Example:**
  - Select 50 wedding photos
  - Prompt: "Wedding photos from Malin & Erik, June 2024, organize by event"
  - AI generates: `Malin-Erik-Wedding-Ceremony-001.jpg`, `Malin-Erik-Wedding-Reception-025.jpg`
- **Tech:** GPT-4 with context understanding
- **Use Case:** Professional photographers, event organizers

#### Feature 3: "Smart Pattern Learning"
- **What:** AI learns from your rename history and suggests patterns
- **Examples:**
  - Notices you always rename invoices: `Faktura-[Company]-[Date].pdf`
  - Next time: Auto-suggests same pattern for new invoices
  - "You usually use Title Case for documents - apply to these 10 files?"
- **Tech:** Local ML model or API-based pattern recognition
- **Use Case:** Power users with consistent naming conventions

---

### Version 2.5 - AI Auto-Organize
**Priority: MEDIUM** 🎯

#### Feature 4: "AI Folder Organization"
- **What:** AI not only renames but also moves files to smart folders
- **Examples:**
  - All `Faktura*.pdf` → `/Documents/Invoices/2024/`
  - All `IMG_*.jpg` with faces → `/Photos/People/`
  - All code screenshots → `/Work/Screenshots/`
  - Creates folders automatically based on content
- **Tech:** File classification ML + folder structure analysis
- **Use Case:** Messy Downloads folder → Organized in 1 click

#### Feature 5: "Duplicate Detection & Smart Merge"
- **What:** AI finds duplicates even if named differently
- **Examples:**
  - `document-final.pdf` and `document_FINAL_v2.pdf` are same content
  - AI suggests: "Keep newest, rename to: Project-Report-Final.pdf"
  - Detects near-duplicates (similar photos) and suggests best one
- **Tech:** Content hashing + similarity detection
- **Use Case:** Clean up duplicate files from email/downloads

---

### Version 3.0 - AI Advanced
**Priority: LOW** (Future exploration) 💡

#### Feature 6: "OCR + Language Detection"
- **What:** Read text in images/PDFs in ANY language, suggest translated names
- **Example:**
  - Japanese restaurant receipt → `Restaurant-Sushi-Tokyo-2024-10-11.jpg`
  - Swedish handwritten note → `Anteckningar-Möte-Projekt-X.jpg`

#### Feature 7: "Voice Command Rename"
- **What:** Speak rename instructions
- **Example:**
  - "Rename all these to vacation dash location dash number"
  - AI executes: `Vacation-Paris-001.jpg`

#### Feature 8: "AI Metadata Enrichment"
- **What:** AI adds smart metadata/tags to files
- **Example:**
  - Photo of beach → Tags: "vacation, summer, beach, 2024"
  - Searchable in Spotlight!

---

## 💰 Monetization Strategy (with AI)

### Free Tier
- All basic patterns (Find & Replace, Sequential, Case, etc.)
- 50 files per batch
- No AI features

### Pro - $9.99/month
- Unlimited files
- **10 AI Smart Renames per month**
- Priority updates

### Pro+ - $19.99/month
- Everything in Pro
- **Unlimited AI Smart Renames**
- **AI Auto-Organize folders**
- **AI Pattern Learning**
- Early access to new AI features

### Lifetime - $49.99 one-time
- All Pro+ features forever
- Support indie development

---

## 🎨 Design Improvements (Non-AI)

### Version 1.5
- **Templates/Presets:**
  - Save favorite rename patterns
  - "Photography Workflow", "Invoice Organizer", "Screenshot Cleanup"
  - One-click apply

- **Keyboard Shortcuts:**
  - Cmd+1/2/3 to switch patterns quickly
  - Cmd+Shift+R to quick rename
  - Cmd+/ to search patterns

- **Dark Mode Optimization:**
  - Better contrast for live preview
  - Prettier colors for changed files

- **Multi-Window Support:**
  - Work on multiple rename jobs simultaneously
  - Compare different pattern results side-by-side

---

## 🚀 Marketing Angle

### With AI Features:
**"The ONLY file renamer with AI superpowers"**

**Tagline Ideas:**
- "Stop typing. Start describing. AI does the rest."
- "1000 files. 1 prompt. Perfectly organized."
- "Your messy Downloads folder's worst nightmare."
- "File organization, but make it intelligent."

**Target Users:**
1. **Photographers:** Organize 1000s of photos with AI descriptions
2. **Designers:** Smart naming of project files
3. **Researchers:** Auto-organize papers, PDFs by content
4. **Regular Users:** Clean up chaotic Downloads folder

---

## 🎯 Next Steps

### Immediate (v1.1):
- [ ] Add Templates/Presets
- [ ] Keyboard shortcuts
- [ ] Export/Import rename history
- [ ] Better error messages

### Short-term (v2.0 - Q1 2025):
- [ ] Implement AI Smart Rename (Priority 1)
- [ ] API integration (OpenAI/Claude)
- [ ] Pricing tiers in app
- [ ] App Store submission

### Long-term (v3.0 - Q2 2025):
- [ ] AI Auto-Organize
- [ ] Pattern learning ML model
- [ ] Browser extension (rename downloads)
- [ ] iOS/iPadOS version

---

## 💡 Competitive Advantage

**Why QuickRename will win:**
1. ✅ **Modern SwiftUI design** (competitors look outdated)
2. ✅ **Live preview** (instant feedback)
3. ✅ **Menubar + Finder integration** (always accessible)
4. 🤖 **AI features** (NO competitor has this!)
5. 💰 **Better pricing** ($9.99 vs $20-100 from competitors)
6. ⚡ **Fast & native** (not Electron bloat)

**With AI:** We go from "rename tool" to "intelligent file organization assistant"

---

## 📊 Success Metrics

**v1.0 (Current):**
- Goal: 100 users in first month
- Revenue: $500/month from Pro subscriptions

**v2.0 (With AI):**
- Goal: 1,000 users
- Revenue: $5,000/month
- 30% conversion to Pro+ (for AI features)

**v3.0:**
- Goal: 10,000+ users
- Revenue: $25,000+/month
- Featured on Product Hunt, Hacker News

---

## 🎨 Branding Ideas

**App Icon:**
- Robot + pen/pencil combo
- AI brain organizing files
- Sparkle effect (AI magic!)

**Website copy:**
"Your files deserve better names. Let AI handle it."

**Demo video showing:**
1. Messy folder with `IMG_1234.jpg` x100
2. User types: "Organize my Italy vacation photos"
3. AI renames: `Rome-Colosseum-01.jpg`, `Venice-Canals-15.jpg`
4. Mind = blown 🤯

---

Built with ❤️ in Sweden 🇸🇪
