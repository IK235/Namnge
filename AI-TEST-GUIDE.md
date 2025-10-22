# 🧪 AI Testing Guide

Let's test the improved AI accuracy!

---

## 🎯 Test Scenarios

### Test 1: Groq AI with Images (Best Improvement)

**Setup:**
1. Open Namnge
2. Add some test image files (any photos)
3. Select **AI Smart** pattern
4. Choose **Groq (Fast)** provider

**Test Prompts:**

| Prompt | Expected Result |
|--------|----------------|
| `vacation photos Paris summer` | `paris-vacation-[content].jpg` |
| `family dinner christmas 2024` | `family-dinner-christmas.jpg` |
| `wedding ceremony bride groom` | `wedding-ceremony-[details].jpg` |
| `product photos ecommerce` | `product-ecommerce-[item].jpg` |

**What to Check:**
- ✅ Names are consistent (kebab-case)
- ✅ No quotes or weird characters
- ✅ Relevant to your prompt
- ✅ No duplicate extensions (.jpg.jpg)

---

### Test 2: Apple Vision with Images (Local AI)

**Setup:**
1. Add image files
2. Select **AI Smart** pattern
3. Choose **Apple Vision (Local)** provider

**Test Prompts:**

| Prompt | Expected Result |
|--------|----------------|
| `vacation photos` | `vacation-photos-[detected-content].jpg` |
| `food photography` | `food-photography-[detected-item].jpg` |
| `nature landscape` | `nature-landscape-[scene].jpg` |

**What to Check:**
- ✅ AI detects image content (cat, dog, food, etc.)
- ✅ Combines your prompt + detected content
- ✅ Works offline (no internet needed)
- ✅ Faster than Groq (local processing)

---

### Test 3: Documents (Groq Best Use Case)

**Setup:**
1. Add PDF, DOCX, or text files
2. Select **AI Smart** pattern
3. Choose **Groq (Fast)** provider

**Test Prompts:**

| Prompt | Expected Result |
|--------|----------------|
| `quarterly reports Q1 2024` | `quarterly-report-q1-2024.pdf` |
| `invoice client acme corp` | `invoice-acme-corp.pdf` |
| `meeting notes team alpha` | `meeting-notes-team-alpha.docx` |

**What to Check:**
- ✅ Professional naming
- ✅ Includes key context (Q1, client name, etc.)
- ✅ Consistent format

---

### Test 4: Batch Rename (Multiple Files)

**Setup:**
1. Add 10+ similar files
2. Select **AI Smart** pattern
3. Choose **Groq (Fast)** provider

**Test Prompt:**
```
project screenshots dashboard ui
```

**Expected Results:**
- `project-dashboard-ui-1.png`
- `project-dashboard-ui-2.png`
- etc.

**What to Check:**
- ✅ All files get unique names
- ✅ Consistent pattern across all files
- ✅ No naming conflicts

---

## 🔍 Before vs After Comparison

### Before (Old AI):
```
Input: "vacation photos Paris"
Output:
- "Paris Vacation Photo.jpg"
- "vacation photo.jpg"
- "Paris_Photo_2024.jpg"
❌ Inconsistent, has spaces, mixed formats
```

### After (New AI):
```
Input: "vacation photos Paris"
Output:
- "paris-vacation-eiffel-tower.jpg"
- "paris-vacation-louvre.jpg"
- "paris-vacation-seine-river.jpg"
✅ Consistent, kebab-case, descriptive
```

---

## 💡 Pro Tips for Testing

### 1. Be Specific
```
❌ Bad: "photos"
✅ Good: "family vacation beach summer 2024"
```

### 2. Test Different File Types
- Images: .jpg, .png, .heic
- Documents: .pdf, .docx, .txt
- Others: .mp4, .zip, .sketch

### 3. Compare Providers
Same prompt, different providers:
- **Groq**: Better with context, understands descriptions
- **Apple Vision**: Better with unknown images, works offline

### 4. Check Edge Cases
- Very long filenames (should truncate)
- Special characters in original names
- Multiple dots in filename (should handle .tar.gz correctly)

---

## 🐛 What to Look For

### ✅ Good Results:
- Consistent naming pattern
- Lowercase kebab-case
- Descriptive and relevant
- No duplicate extensions
- No special characters

### ❌ Problems to Report:
- Random quotes or brackets
- Inconsistent formatting
- Wrong file extensions
- Duplicate extensions (.jpg.jpg)
- Empty or generic names

---

## 📊 Test Results Template

After testing, note:

**Groq AI:**
- Accuracy: ___/10
- Consistency: ___/10
- Speed: Fast / Medium / Slow
- Best for: (Images / Documents / Both)

**Apple Vision:**
- Accuracy: ___/10
- Detection: ___/10 (how well it identifies content)
- Speed: Fast / Medium / Slow
- Best for: (Photos / All images)

**Overall Improvement:**
- Before: ___/10
- After: ___/10
- Improvement: +___%

---

## 🎯 Real-World Test Scenarios

### Scenario 1: Vacation Photos
```
Files: 50 random photos from trip
Prompt: "italy vacation rome florence venice summer"
Provider: Groq

Expected:
- rome-colosseum-[details].jpg
- florence-duomo-[details].jpg
- venice-canals-[details].jpg
```

### Scenario 2: Work Documents
```
Files: 20 mixed PDFs and DOCX
Prompt: "client reports Q4 2024 financial"
Provider: Groq

Expected:
- client-report-q4-2024-[name].pdf
- financial-report-q4-2024.pdf
```

### Scenario 3: Mixed Media
```
Files: Photos + Videos
Prompt: "birthday party december 2024"
Provider: Apple Vision

Expected:
- birthday-party-[detected-content]-[number].jpg
- birthday-party-video-[number].mp4
```

---

## 🚀 Quick Test (5 minutes)

1. **Open Namnge**
2. **Add 3-5 test photos**
3. **Select AI Smart → Groq**
4. **Prompt:** `"test photos demo"`
5. **Click "Generate AI Names"**
6. **Check results:**
   - ✅ All lowercase?
   - ✅ Kebab-case (hyphens)?
   - ✅ No quotes?
   - ✅ Relevant names?

If all ✅ → **AI is working perfectly!** 🎉

---

## 📝 Notes

While testing:
- AI response time: 1-3 seconds per file
- Groq is faster but needs internet
- Apple Vision works offline
- Both handle 100+ files well

---

## 🎉 Success Criteria

AI improvements are successful if:

✅ **Consistency**: All files follow same pattern
✅ **Accuracy**: Names match your description
✅ **Format**: Clean kebab-case, no special chars
✅ **Speed**: 1-3 seconds per file
✅ **Reliability**: Same prompt → similar results

---

Ready to test? Open Namnge and try it out! 🚀

**Tips:**
1. Start with 3-5 files (quick test)
2. Try both Groq and Apple Vision
3. Compare results
4. Then test with more files

Let me know what results you get!
