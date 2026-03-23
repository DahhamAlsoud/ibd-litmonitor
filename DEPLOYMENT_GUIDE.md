# IBD LitMonitor - Private Code Repository

## IMPORTANT: Two-Repository Architecture

To keep your code **PRIVATE** while the website is **PUBLIC**, you'll use TWO GitHub repositories:

### 🔒 Repository 1: PRIVATE (Your Code)
**Name:** `ibd-litmonitor-private`  
**Visibility:** Private  
**Contains:**
```
ibd-litmonitor-private/
├── R/
│   └── core_functions.R          ← YOUR SECRET SAUCE
├── .qmd files
├── .github/workflows/
└── scripts/
```

### 🌍 Repository 2: PUBLIC (Website Only)
**Name:** `ibd-litmonitor`  
**Visibility:** Public  
**Contains:**
```
ibd-litmonitor/
├── docs/                          ← Rendered HTML only
│   ├── index.html
│   ├── archive.html
│   ├── dashboard.html
│   └── *.html
├── rss.xml
└── README.md
```

---

## Setup Instructions

### Step 1: Create PRIVATE Repository

```bash
# On your computer
cd /path/to/this/folder

# Initialize git
git init

# Create private repo on GitHub
gh repo create ibd-litmonitor-private --private --source=. --remote=origin

# Add all files
git add .
git commit -m "Initial commit - private code"
git push -u origin main
```

### Step 2: Create PUBLIC Repository (Website Only)

```bash
# Create public repo for website
gh repo create ibd-litmonitor --public --clone

cd ibd-litmonitor

# This will ONLY contain rendered HTML
# (populated automatically by GitHub Actions)
```

### Step 3: Configure GitHub Actions

In your **PRIVATE** repo, the GitHub Action will:

1. Run on private repo (code is safe)
2. Render Quarto → HTML
3. Push HTML to **PUBLIC** repo

#### Update `.github/workflows/update-reports.yml`:

```yaml
- name: Deploy to public repository
  run: |
    # Clone public repo
    git clone https://x-access-token:${{ secrets.PERSONAL_ACCESS_TOKEN }}@github.com/dahhamalsoud/ibd-litmonitor.git public-site
    
    # Copy rendered docs
    cp -r docs/* public-site/
    
    # Push to public repo
    cd public-site
    git config user.name "IBD LitMonitor Bot"
    git config user.email "bot@litmonitor.com"
    git add .
    git commit -m "Update site - $(date)"
    git push
```

### Step 4: Create Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Select scopes: `repo` (all)
4. Copy token
5. Add to private repo secrets:
   - Go to private repo → Settings → Secrets → Actions
   - Add secret: `PERSONAL_ACCESS_TOKEN` = your token

### Step 5: Add PubMed Credentials

In **PRIVATE** repo → Settings → Secrets → Actions:

- `PUBMED_EMAIL` = your email
- `PUBMED_API_KEY` = your PubMed API key (optional but recommended)

---

## How It Works

```
┌─────────────────────────────────────────────┐
│  PRIVATE REPO (Code)                        │
│  ├── R/core_functions.R                     │
│  ├── *.qmd                                  │
│  └── GitHub Actions                         │
│                                             │
│  Every Friday:                              │
│  1. Fetch papers (R code)                   │
│  2. Render Quarto → HTML                    │
│  3. Push HTML to public repo ───────┐       │
└─────────────────────────────────────│───────┘
                                      │
                                      ↓
                      ┌───────────────────────────────┐
                      │  PUBLIC REPO (Website)        │
                      │  ├── docs/                    │
                      │  │   ├── index.html           │
                      │  │   └── *.html               │
                      │  └── README.md                │
                      │                               │
                      │  GitHub Pages serves this!    │
                      │  https://....github.io        │
                      └───────────────────────────────┘
```

**Result:**
- ✅ Your R code = PRIVATE (nobody can copy)
- ✅ Website = PUBLIC (everyone can use)
- ✅ GitHub Actions runs on private repo (secure)
- ✅ FREE (both repos free)

---

## Alternative: Single Private Repo (Simpler)

If you want to keep EVERYTHING private initially:

### Option A: Private Repo + GitHub Pages (requires Pro/Team)

GitHub Pages works on private repos if you have:
- GitHub Pro ($4/month)
- GitHub Team ($4/user/month)

Then you can:
1. Keep everything in ONE private repo
2. Enable GitHub Pages on private repo
3. Website is public, code stays private

### Option B: Private Repo + External Hosting

1. Keep everything in private repo
2. Use GitHub Actions to deploy to:
   - Netlify (FREE)
   - Vercel (FREE)
   - Cloudflare Pages (FREE)

All of these can deploy from private repos for FREE!

---

## Recommended Approach: Netlify + Private Repo

**EASIEST & FREE:**

1. Keep everything in ONE private repo
2. Connect to Netlify
3. Netlify auto-deploys from private repo

### Setup:

```bash
# Keep everything in private repo
gh repo create ibd-litmonitor --private

# Connect to Netlify
# 1. Go to netlify.com
# 2. New site from Git
# 3. Connect GitHub (authorize private repos)
# 4. Select your private repo
# 5. Build command: quarto render
# 6. Publish directory: docs
# 7. Deploy!

# Your site: https://ibd-litmonitor.netlify.app
# (or custom domain)
```

**Benefits:**
- ✅ Code stays private
- ✅ Website is public
- ✅ FREE forever
- ✅ Automatic deployments
- ✅ Custom domain support
- ✅ HTTPS included
- ✅ Faster than GitHub Pages

---

## Which Approach Should You Use?

| Method | Complexity | Cost | Privacy |
|--------|-----------|------|---------|
| **Two repos (private + public)** | Medium | $0 | Perfect |
| **Private repo + Netlify** | Easy | $0 | Perfect |
| **Private repo + GitHub Pro** | Easy | $4/mo | Perfect |

**Recommendation:** **Netlify + Private Repo** (easiest + free)

---

## Files You Can Share Publicly (Optional)

Even with private code, you CAN share these if you want:

- `README.md` - Description of the project
- `about.qmd` - About page
- `styles.css` - Styling (not secret)
- `dashboard/app.R` - Shiny app (if you want to share)

**But keep PRIVATE:**
- `R/core_functions.R` - Your search queries and logic
- PubMed API credentials
- Any proprietary algorithms

---

## Security Checklist

✅ Never commit API keys or passwords  
✅ Use `.gitignore` to exclude sensitive files  
✅ Use GitHub Secrets for credentials  
✅ Keep R/ folder private  
✅ Only share rendered HTML  
✅ Use private repo for development  
✅ Review commits before pushing  

---

## Next Steps

Choose your deployment method:

1. **Easy:** Netlify + private repo (recommended)
2. **Traditional:** Two repos (private code + public site)
3. **Pro:** Single private repo + GitHub Pro

Want me to create setup scripts for your chosen method?
