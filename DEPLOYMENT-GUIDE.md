# Namnge Deployment Guide 🚀

Complete guide to deploy Namnge from development to production.

## ✅ What's Been Completed

### 1. App Features ✓
- ✅ 9 rename patterns (Find/Replace, Sequential, AI Smart, etc.)
- ✅ 8 customizable accent colors
- ✅ Global hotkey support
- ✅ License & trial system
- ✅ Upgrade prompts for Pro features
- ✅ Export/Import presets
- ✅ Rename history
- ✅ Drag & drop support

### 2. Backend Files ✓
- ✅ `backend/supabase-setup.sql` - Database schema
- ✅ `backend/supabase/functions/validate-license/index.ts` - License API
- ✅ `backend/supabase/functions/stripe-webhook/index.ts` - Payment webhook
- ✅ `backend/SETUP-GUIDE.md` - Complete setup instructions

### 3. Distribution Files ✓
- ✅ `release/Namnge.app` - Ready-to-distribute app
- ✅ `release/Namnge-1.0.0.zip` - ZIP download (941 KB)
- ✅ `release/Namnge-Installer-1.0.0.dmg` - DMG installer (1.3 MB)

---

## 📋 Pre-Launch Checklist

### Step 1: Set Up Backend (Required)

Follow `backend/SETUP-GUIDE.md` to:

1. **Create Supabase Project**
   - Go to https://supabase.com
   - Create new project: `namnge-backend`
   - Run SQL schema from `backend/supabase-setup.sql`

2. **Deploy Edge Functions**
   ```bash
   cd backend
   supabase login
   supabase link --project-ref YOUR_PROJECT_ID

   # Set secrets
   supabase secrets set SUPABASE_URL=https://xxxxx.supabase.co
   supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your-key
   supabase secrets set STRIPE_SECRET_KEY=sk_test_...
   supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_...

   # Deploy
   supabase functions deploy validate-license
   supabase functions deploy stripe-webhook
   ```

3. **Set Up Stripe**
   - Create products (Monthly $9.99, Yearly $49.99)
   - Set up webhook pointing to your Supabase function
   - Create payment links for your website

### Step 2: Update App with Production API

**File:** `QuickRename/Services/LicenseManager.swift`

Change line 21 from:
```swift
private let API_URL = "https://namnge.com/api/validate"
```

To your Supabase function URL:
```swift
private let API_URL = "https://YOUR-PROJECT.supabase.co/functions/v1/validate-license"
```

Then rebuild:
```bash
xcodebuild -project Namnge.xcodeproj -scheme Namnge -configuration Debug clean build
```

### Step 3: Update Website

Add download links to your Lovable website:

**Download Button:**
```html
<a href="https://your-site.com/downloads/Namnge-Installer-1.0.0.dmg"
   class="btn-primary" download>
  Download Namnge for macOS
</a>
<p class="text-sm">Version 1.0.0 • macOS 14+ • Free with Pro upgrade</p>
```

**Pricing Buttons:**
```html
<!-- Monthly -->
<a href="YOUR_STRIPE_PAYMENT_LINK">
  Get Pro Monthly - $9.99/month
</a>

<!-- Yearly -->
<a href="YOUR_STRIPE_PAYMENT_LINK">
  Get Pro Yearly - $49.99/year (Save $70!)
</a>
```

### Step 4: Upload Distribution Files

Upload to your hosting:
```bash
# Example with SCP
scp release/Namnge-Installer-1.0.0.dmg user@server:/var/www/downloads/

# Or use your hosting's file manager
# Upload: Namnge-Installer-1.0.0.dmg (1.3 MB)
# Make publicly accessible
```

### Step 5: Test Complete Flow

**Test 1: Download & Install**
1. Go to your website
2. Click "Download"
3. Open DMG
4. Drag app to Applications
5. Launch Namnge
6. Verify it opens correctly

**Test 2: Free Trial**
1. Open Namnge → Preferences
2. Click "Start 7-Day Free Trial"
3. Verify Pro features work:
   - Unlimited AI renames
   - All 8 colors unlocked
   - No file limit
   - Export presets works

**Test 3: License Purchase (Use Stripe test mode)**
1. Go to website → Click "Buy Pro Monthly"
2. Use test card: `4242 4242 4242 4242`
3. Complete checkout
4. Check Supabase → licenses table for new entry
5. Copy license key from database
6. In Namnge → Preferences → Enter license + email
7. Click "Activate License"
8. Verify Pro badge appears

**Test 4: License Validation**
1. Quit Namnge
2. Relaunch
3. Verify Pro status persists
4. Test Pro features still work

---

## 🔄 Going to Production

### When Ready to Launch:

1. **Stripe: Switch to Live Mode**
   - Activate your account
   - Create live products
   - Update webhook with live secret
   - Update Supabase secret: `STRIPE_SECRET_KEY=sk_live_...`

2. **Supabase: Update Secrets**
   ```bash
   supabase secrets set STRIPE_SECRET_KEY=sk_live_...
   supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_live_...
   ```

3. **App: Remove Debug Mode**

   **File:** `QuickRename/Services/LicenseManager.swift`

   Remove or comment out lines 44-61 (the `#if DEBUG` block):
   ```swift
   // #if DEBUG
   // // Development mode: Accept any key starting with "NAMNGE-PRO-"
   // if cleanKey.hasPrefix("NAMNGE-PRO-") {
   //     ...
   // }
   // #endif
   ```

4. **Rebuild for Production**
   ```bash
   xcodebuild -project Namnge.xcodeproj \
     -scheme Namnge \
     -configuration Release \
     clean build
   ```

5. **Create Final Distribution**
   - Export new app
   - Create new DMG
   - Upload to website

---

## 📊 Post-Launch Monitoring

### Supabase Dashboard
- **Database → licenses**: View all active licenses
- **Database → license_activations**: Track device activations
- **Edge Functions → Logs**: Monitor API calls

### Stripe Dashboard
- **Payments**: Track revenue
- **Customers**: View subscribers
- **Webhooks**: Check for failures

---

## 🐛 Troubleshooting

### "License validation failed"
- Check Supabase URL in LicenseManager.swift
- Verify Edge Function is deployed
- Check Supabase logs for errors

### "Payment succeeded but no license created"
- Check Stripe webhook logs
- Verify webhook secret is correct
- Check Supabase stripe-webhook function logs

### "App won't open on user's Mac"
**Solution:** macOS Gatekeeper blocking unsigned app

Tell users:
1. Right-click Namnge.app → Open
2. Click "Open" in dialog
3. Or: System Settings → Privacy & Security → "Open Anyway"

**Long-term solution:** Sign and notarize the app (requires Apple Developer account $99/year)

---

## 📈 Marketing Tips

### Landing Page Copy
```
🚀 Namnge - Batch File Renaming, Reimagined

Rename hundreds of files in seconds with AI-powered intelligence.

✨ Features:
• AI Smart Renaming - Describe what you want, let AI do the rest
• 9 Powerful Patterns - Find/Replace, Sequential, Date Stamps, Regex, and more
• Beautiful Interface - Customizable with 8 accent colors
• Global Hotkey - Access from anywhere in macOS

💰 Pricing:
• Free: 5 AI renames/month, 50 files, 3 colors
• Pro: $9.99/month or $49.99/year
  - Unlimited AI renames
  - Unlimited files
  - All 8 colors
  - Export presets
  - Unlimited history

🎁 Start with a 7-day free Pro trial!
```

### Social Media
- Post screenshots of the app
- Demo video of AI renaming in action
- Before/after comparisons
- User testimonials

### Product Hunt Launch
- Prepare launch for Product Hunt
- Create demo GIF/video
- Prepare maker comment
- Schedule launch for Tuesday-Thursday

---

## 📞 Support

### User FAQ

**Q: Is there a refund policy?**
A: Yes! 14-day money-back guarantee, no questions asked.

**Q: Does it work on Apple Silicon (M1/M2/M3)?**
A: Yes! Native support for both Apple Silicon and Intel Macs.

**Q: Can I use my license on multiple computers?**
A: Yes, one license works on all your personal Macs.

**Q: What if I cancel my subscription?**
A: You keep Pro access until the end of your billing period, then revert to Free tier.

---

## 🎯 Next Steps

- [ ] Follow backend/SETUP-GUIDE.md
- [ ] Update LicenseManager.swift with production API URL
- [ ] Rebuild app
- [ ] Upload DMG to website
- [ ] Add download links to website
- [ ] Test complete flow (download → install → trial → purchase → activate)
- [ ] Launch! 🚀

---

## 📁 Important File Locations

```
QuickRename/
├── backend/
│   ├── supabase-setup.sql              # Database schema
│   ├── supabase/functions/
│   │   ├── validate-license/index.ts   # License API
│   │   └── stripe-webhook/index.ts     # Payment webhook
│   └── SETUP-GUIDE.md                  # Backend setup
├── release/
│   ├── Namnge.app                      # App bundle
│   ├── Namnge-1.0.0.zip                # ZIP download
│   └── Namnge-Installer-1.0.0.dmg      # DMG installer
├── QuickRename/Services/
│   ├── LicenseManager.swift            # License validation
│   └── TrialManager.swift              # Trial system
└── DEPLOYMENT-GUIDE.md                 # This file
```

---

Good luck with your launch! 🚀
