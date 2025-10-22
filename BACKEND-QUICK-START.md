# 🚀 Backend Quick Start Guide

**Estimated time: 30 minutes**

---

## 📋 What You'll Need

- [ ] Supabase account (free) - https://supabase.com
- [ ] Stripe account (free test mode) - https://stripe.com
- [ ] Terminal access
- [ ] Supabase CLI installed

---

## Step 1: Install Supabase CLI (5 min)

```bash
# macOS
brew install supabase/tap/supabase

# Verify installation
supabase --version
```

---

## Step 2: Create Supabase Project (5 min)

1. **Go to https://app.supabase.com**
2. Click **"New Project"**
3. Settings:
   - Name: `namnge-backend`
   - Database Password: (create strong password - SAVE THIS!)
   - Region: Choose closest to you (e.g., `Europe West`)
4. Click **"Create new project"** (takes 2-3 min)

**✅ Save these values:**
- Project URL: `https://xxxxx.supabase.co`
- `anon` key (public)
- `service_role` key (secret - keep safe!)

---

## Step 3: Set Up Database (3 min)

1. In Supabase Dashboard, go to **SQL Editor**
2. Click **"New Query"**
3. Copy **ALL** content from:
   ```
   /Users/ikbalerdal/Documents/QuickRename/backend/supabase-setup.sql
   ```
4. Paste into SQL Editor
5. Click **"Run"** (or press ⌘+Enter)
6. ✅ You should see "Success. No rows returned"

**What this created:**
- `licenses` table - stores Pro licenses
- `license_activations` table - tracks devices
- Functions for generating license keys
- Security policies

---

## Step 4: Deploy Edge Functions (10 min)

Open Terminal in your project folder:

```bash
cd /Users/ikbalerdal/Documents/QuickRename/backend

# Login to Supabase
supabase login

# Link your project (you'll need project ID from URL: xxxxx.supabase.co)
supabase link --project-ref YOUR_PROJECT_ID

# Set environment secrets
supabase secrets set SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# We'll add Stripe keys after Step 5
```

**Deploy functions:**

```bash
# Deploy license validation API
supabase functions deploy validate-license

# You'll get a URL like:
# https://YOUR_PROJECT_ID.supabase.co/functions/v1/validate-license
# ✅ SAVE THIS URL - you'll need it for the app!
```

Wait on Stripe webhook deployment until Step 6.

---

## Step 5: Set Up Stripe (7 min)

### Create Products

1. **Go to https://dashboard.stripe.com/test/products**
2. Click **"+ Add product"**

**Product 1: Namnge Pro Monthly**
- Name: `Namnge Pro - Monthly`
- Description: `Namnge Pro subscription - monthly billing`
- Pricing model: `Standard pricing`
- Price: `9.99 USD`
- Billing period: `Monthly`
- Click **"Save product"**
- ✅ **Copy the Price ID** (starts with `price_`)

**Product 2: Namnge Pro Yearly**
- Name: `Namnge Pro - Yearly`
- Description: `Namnge Pro subscription - yearly billing (best value!)`
- Pricing model: `Standard pricing`
- Price: `49.99 USD`
- Billing period: `Yearly`
- Click **"Save product"**
- ✅ **Copy the Price ID** (starts with `price_`)

### Create Payment Links

1. **Go to https://dashboard.stripe.com/test/payment-links**
2. Click **"+ New"**

**Monthly Payment Link:**
- Select: `Namnge Pro - Monthly` product
- Payment page options:
  - ✅ Collect customer email
  - ✅ Collect billing address (optional)
- Click **"Create link"**
- ✅ **Copy the payment link URL** → This goes on your website "Buy Monthly" button

**Yearly Payment Link:**
- Repeat for `Namnge Pro - Yearly`
- ✅ **Copy the payment link URL** → This goes on your website "Buy Yearly" button

---

## Step 6: Connect Stripe Webhook (5 min)

### Create Webhook

1. **Go to https://dashboard.stripe.com/test/webhooks**
2. Click **"+ Add endpoint"**
3. Settings:
   - Endpoint URL: `https://YOUR_PROJECT_ID.supabase.co/functions/v1/stripe-webhook`
   - Description: `Namnge License Creation`
   - Events to send:
     - ✅ `checkout.session.completed`
     - ✅ `customer.subscription.updated`
     - ✅ `customer.subscription.deleted`
     - ✅ `charge.refunded`
4. Click **"Add endpoint"**
5. ✅ **Copy the Signing secret** (starts with `whsec_`)

### Update Supabase Secrets

```bash
cd /Users/ikbalerdal/Documents/QuickRename/backend

# Add Stripe keys
supabase secrets set STRIPE_SECRET_KEY=sk_test_YOUR_KEY_HERE
supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_YOUR_SECRET_HERE

# Deploy webhook function
supabase functions deploy stripe-webhook
```

---

## Step 7: Update App with API URL (2 min)

**File:** `/Users/ikbalerdal/Documents/QuickRename/QuickRename/Services/LicenseManager.swift`

1. Open in Xcode
2. Find line 21:
   ```swift
   private let API_URL = "https://namnge.com/api/validate"
   ```
3. Change to YOUR Supabase function URL:
   ```swift
   private let API_URL = "https://YOUR_PROJECT_ID.supabase.co/functions/v1/validate-license"
   ```
4. Save (⌘+S)
5. Build (⌘+B)

---

## Step 8: Test Everything (5 min)

### Test 1: Database

1. Go to Supabase Dashboard → **Table Editor**
2. Open `licenses` table
3. ✅ Should see columns: id, license_key, email, plan, status, etc.

### Test 2: License API

```bash
# Test validation endpoint
curl -X POST https://YOUR_PROJECT_ID.supabase.co/functions/v1/validate-license \
  -H "Content-Type: application/json" \
  -d '{"license_key":"NAMNGE-PRO-TEST-1234","email":"test@example.com"}'

# Should return:
# {"valid":false,"message":"Invalid license key or email"}
# ✅ This is correct! No license exists yet.
```

### Test 3: App License (Debug Mode)

1. Open Namnge app
2. Go to Preferences
3. Enter:
   - License Key: `NAMNGE-PRO-TEST-1234`
   - Email: `test@example.com`
4. Click "Activate License"
5. ✅ Should activate (debug mode allows this)

### Test 4: Stripe Payment (Test Mode)

1. Go to your payment link (from Step 5)
2. Enter test card: `4242 4242 4242 4242`
3. Expiry: Any future date (e.g., 12/25)
4. CVC: Any 3 digits (e.g., 123)
5. Email: `test@yourdomain.com`
6. Complete checkout
7. ✅ Check Stripe Dashboard → Payments (should see $9.99 or $49.99)
8. ✅ Check Supabase → licenses table (should see new license!)

---

## ✅ Success Checklist

After completing all steps, you should have:

- ✅ Supabase project with database schema
- ✅ License validation API deployed
- ✅ Stripe webhook deployed
- ✅ Stripe products created (Monthly & Yearly)
- ✅ Payment links created
- ✅ App updated with API URL
- ✅ Test payment successful
- ✅ License auto-created in database

---

## 🎯 Next Steps

### Add to Website

Update your Lovable website with:

1. **Download Button**
   ```html
   <a href="https://your-site.com/downloads/Namnge-Installer-1.0.0.dmg">
     Download for macOS
   </a>
   ```

2. **Pricing Buttons**
   ```html
   <a href="YOUR_MONTHLY_PAYMENT_LINK">
     Get Pro Monthly - $9.99/mo
   </a>

   <a href="YOUR_YEARLY_PAYMENT_LINK">
     Get Pro Yearly - $49.99/yr
   </a>
   ```

### Go Live (When Ready)

1. **Stripe:** Switch to live mode
   - Get live API keys
   - Update Supabase secrets with `sk_live_...`
   - Create live products
   - Update payment links

2. **App:** Remove debug mode
   - Comment out `#if DEBUG` block in LicenseManager.swift
   - Build for release

3. **Launch!** 🚀

---

## 🐛 Troubleshooting

### "Could not deploy function"

```bash
# Check you're logged in
supabase login

# Check project is linked
supabase projects list

# Re-link if needed
supabase link --project-ref YOUR_PROJECT_ID
```

### "License validation always fails"

Check:
1. API URL is correct in LicenseManager.swift
2. Edge Function is deployed: `supabase functions list`
3. Secrets are set: `supabase secrets list`

### "Webhook not triggering"

Check:
1. Webhook URL is correct (Stripe Dashboard → Webhooks)
2. Signing secret is correct in Supabase
3. Stripe Dashboard → Webhooks → View logs

---

## 📞 Quick Reference

**Important URLs:**
- Supabase Dashboard: https://app.supabase.com
- Stripe Dashboard: https://dashboard.stripe.com/test
- Stripe Webhooks: https://dashboard.stripe.com/test/webhooks
- Your License API: `https://YOUR_PROJECT_ID.supabase.co/functions/v1/validate-license`

**Important Files:**
- SQL Schema: `/Users/ikbalerdal/Documents/QuickRename/backend/supabase-setup.sql`
- License API: `/Users/ikbalerdal/Documents/QuickRename/backend/supabase/functions/validate-license/index.ts`
- Webhook: `/Users/ikbalerdal/Documents/QuickRename/backend/supabase/functions/stripe-webhook/index.ts`
- App Config: `/Users/ikbalerdal/Documents/QuickRename/QuickRename/Services/LicenseManager.swift`

---

**You're ready to launch!** 🎉

For complete details, see: `DEPLOYMENT-GUIDE.md`
