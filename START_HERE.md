# 🚀 START HERE - IBD LitMonitor (Updated)

## ✨ What Changed

**NEW PHILOSOPHY:**
- ❌ **No quality scores** - We don't judge papers subjectively
- ✅ **Categorize** - 12 clinical subfields
- ✅ **Rank by journal metrics** - Impact Factor & quartile (objective)
- ✅ **You decide** - Filter by YOUR criteria

---

## 🎯 The Approach

### **3-Step System:**

**1. Categorize** papers into meaningful subfields:
- Therapeutics & Mechanisms
- Biomarkers & Precision Medicine
- AI & Machine Learning
- Endoscopy & Imaging
- Pediatric IBD
- Surgery & Complications
- Epidemiology & Outcomes
- Guidelines & Consensus
- Microbiome & Immunology
- Nutrition & Lifestyle
- Extraintestinal Manifestations
- General IBD

**2. Rank** within each category by:
- Primary: Journal Impact Factor (highest first)
- Secondary: Journal Quartile (Q1 > Q2 > Q3 > Q4)
- Tertiary: Publication Date (newest first)

**3. Filter** (user choice):
- Journal quartile (Q1, Q2, Q3, Q4)
- Minimum Impact Factor
- Study design (RCT, meta-analysis, etc.)
- Keywords
- Date range

---

## 📦 What You Have

17 files ready to deploy:

### **Core Engine (R)**
- `R/core_functions.R` - PubMed fetching, categorization, IF-based ranking
  - 28 queries across 11 domains
  - 12 category assignments
  - Journal metrics database
  - RSS generation

### **Website (Quarto)**
- `index.qmd` - Weekly report (category tabs, IF-ranked)
- `archive.qmd` - Past reports
- `dashboard.qmd` - Embedded Shiny
- `about.qmd` - About page
- `_quarto.yml` - Config
- `styles.css` - Terracotta branding

### **Dashboard (Shiny)**
- `dashboard/app.R` - Interactive filtering
  - Filter by quartile, IF, design
  - Analytics charts
  - CSV/BibTeX export

### **Automation**
- `.github/workflows/update-reports.yml` - Runs every Friday

### **Deployment**
- `setup.sh` - Automated setup
- `quickstart.R` - R setup script
- `deploy_shiny.R` - Deploy dashboard

---

## ⚡ Quick Start (15 minutes)

### **Step 1: Setup (5 min)**

```bash
cd ibd_litmonitor_final

# macOS/Linux:
./setup.sh

# OR in RStudio:
source("quickstart.R")
```

### **Step 2: Deploy Website (5 min)**

**Netlify (Recommended):**

```bash
# Create private repo
gh repo create ibd-litmonitor --private --source=. --remote=origin
git add .
git commit -m "Initial commit"
git push -u origin main

# Deploy to Netlify:
# 1. Go to netlify.com
# 2. "New site from Git"
# 3. Connect GitHub
# 4. Select repo
# 5. Build: quarto render
# 6. Publish: docs
# 7. Deploy!
```

**Live at:** `https://ibd-litmonitor.netlify.app`

### **Step 3: Deploy Dashboard (5 min)**

```r
source("deploy_shiny.R")
# Follow prompts
```

**Live at:** `https://YOUR-USERNAME.shinyapps.io/ibd-litmonitor-dashboard/`

---

## 🎨 What Users See

### **Main Website:**

```
═══════════════════════════════════════════════
IBD Literature - Week of March 20, 2026
87 papers across 12 categories
═══════════════════════════════════════════════

📊 Top Journals This Week:
1. Gastroenterology (8 papers) - IF: 29.4, Q1
2. Gut (7 papers) - IF: 24.5, Q1
3. IBD (5 papers) - IF: 7.2, Q1

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📚 THERAPEUTICS & MECHANISMS (23 papers)
   Ranked by journal impact factor

   1. Gastroenterology (IF: 29.4, Q1)
      "Efficacy of vedolizumab..."
      RCT | Multi-center | March 18

   2. Gut (IF: 24.5, Q1)
      "Long-term ustekinumab outcomes..."
      Cohort | March 17

   [... all 23 papers, sorted by IF]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[... 11 more categories ...]
```

### **Interactive Dashboard:**

**Filters (User Choice):**
- ☑ Q1 journals only
- ☐ Q1-Q2 journals
- Minimum IF: 5
- ☑ RCTs
- ☑ Meta-analyses
- Keywords: "vedolizumab"

**Result:** "12 papers match your criteria"

---

## 🔒 Code Privacy

**Private Repo Strategy:**

```
Private GitHub Repo (your code)
    ↓
Netlify (builds from private)
    ↓
Public Website (HTML only)
```

**What's Private:**
- ❌ `R/core_functions.R` - Your categorization logic
- ❌ Search queries & algorithms
- ❌ `.Renviron` - API keys

**What's Public:**
- ✅ `docs/` - Rendered HTML
- ✅ Website content

**The `.gitignore` handles this automatically!**

---

## 📊 Journal Metrics Database

Papers are ranked using this database (in `R/core_functions.R`):

```r
Journal                                    IF      Q
─────────────────────────────────────────────────────
Gastroenterology                          29.4    Q1
Gut                                       24.5    Q1
Lancet Gastro & Hepatology                23.2    Q1
Clinical Gastroenterology and Hepatology  11.6    Q1
Inflammatory Bowel Diseases                7.2    Q1
Journal of Crohn's and Colitis             8.3    Q1
```

**Updated annually** - No need for live API

---

## 💡 Philosophy Statement

> **IBD LitMonitor provides comprehensive coverage of IBD literature, organized by clinical subfield and ranked by objective journal metrics.**
> 
> **We don't judge quality.** We categorize papers, rank them by Impact Factor and quartile within each category, and give YOU the filtering tools to decide what matters.
> 
> **All papers are included.** Nothing is hidden. You control what you see.

---

## ✅ Before Going Live

- [ ] Run `./setup.sh` or `source("quickstart.R")`
- [ ] Test locally: `quarto preview`
- [ ] Papers fetch from PubMed successfully
- [ ] Create private GitHub repo
- [ ] Add secrets: `PUBMED_EMAIL`, `PUBMED_API_KEY`
- [ ] Deploy to Netlify
- [ ] Deploy Shiny dashboard
- [ ] Update `about.qmd` with your email
- [ ] Test GitHub Action (manual trigger)
- [ ] Verify RSS feed works

---

## 📚 Documentation

- **PROJECT_OVERVIEW.md** - Complete architecture & features
- **README.md** - Full guide
- **DEPLOYMENT_GUIDE.md** - Privacy setup options

---

## 🎯 Quick Commands

```bash
# Setup (one time)
./setup.sh

# Preview locally
quarto preview

# Deploy website to Netlify
gh repo create ibd-litmonitor --private
git push

# Deploy dashboard
# In R:
source("deploy_shiny.R")

# Manual paper fetch
# In R:
source("R/core_functions.R")
papers <- get_papers(days_back = 7)
```

---

## 🆘 Troubleshooting

**"No papers fetched"**
→ Check `.Renviron` has `PUBMED_EMAIL`  
→ Get API key from https://www.ncbi.nlm.nih.gov/account/

**"Quarto not found"**
→ Install from https://quarto.org

**"Missing journal metrics"**
→ Journals not in database get IF=0, appear last  
→ Add to `get_journal_metrics()` in `R/core_functions.R`

---

## 🎉 You're Ready!

**Total cost: $0/month**  
**Total setup time: 15 minutes**  
**Philosophy: Organize, don't judge**

Launch your platform and let users decide what matters! 🚀
