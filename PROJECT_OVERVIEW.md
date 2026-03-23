# IBD LitMonitor - Complete Project Overview (UPDATED)

**100% R + Shiny + Quarto | 100% FREE | Code Protected**

---

## 🎯 Core Philosophy

### **We Don't Judge Quality**

Instead, we:
1. **Categorize** - 12 clinical subfields
2. **Rank** - By Impact Factor & quartile (objective)
3. **Filter** - User choice (YOU decide)

**NOT like PubMed emails** (unfiltered chaos)  
**NOT subjective scoring** (we don't judge science)

---

## 📁 Complete File Structure

```
ibd_litmonitor_final/ (17 files)
│
├── 📄 START_HERE.md              ← READ THIS FIRST!
├── 📊 PROJECT_OVERVIEW.md         ← This file
├── 📖 README.md                   ← Full documentation
├── 🔐 DEPLOYMENT_GUIDE.md         ← Keep code private
│
├── 🔒 R/core_functions.R         ← YOUR SECRET SAUCE
│   • get_journal_metrics()       → IF/quartile database
│   • categorize_papers()         → 12 subfields
│   • rank_by_journal_metrics()   → Sort by IF/Q
│   • get_papers()                → Main function
│
├── 📝 QUARTO PAGES (4 files)
│   ├── index.qmd                 ← Category tabs, IF-ranked
│   ├── archive.qmd               ← Past reports
│   ├── dashboard.qmd             ← Embedded Shiny
│   └── about.qmd                 ← Philosophy
│
├── 📊 dashboard/app.R            ← Filter by IF/quartile
│
├── 🤖 .github/workflows/
│   └── update-reports.yml        ← Runs every Friday
│
├── 🚀 DEPLOYMENT
│   ├── setup.sh                  ← Automated setup
│   ├── quickstart.R              ← R setup
│   └── deploy_shiny.R            ← Deploy dashboard
│
├── ⚙️ CONFIG
│   ├── _quarto.yml               ← Quarto config
│   ├── styles.css                ← Terracotta branding
│   └── .gitignore                ← Code protection
│
└── 📚 README.md                  ← Documentation
```

**Total: 17 files**

---

## 🏗️ How It Works

### **Step 1: Categorize (12 Subfields)**

```r
categories <- list(
  "Therapeutics & Mechanisms" = c(...),
  "Biomarkers & Precision Medicine" = c(...),
  "AI & Machine Learning" = c(...),
  # ... 9 more
)

papers %>%
  mutate(category = assign_to_best_match(title, abstract))
```

### **Step 2: Rank by Journal Metrics**

```r
papers %>%
  left_join(journal_metrics_db) %>%
  group_by(category) %>%
  arrange(
    desc(impact_factor),     # Primary: IF (29.4 > 7.2)
    quartile_rank,            # Secondary: Q1 > Q2
    desc(publication_date)    # Tertiary: Newest
  )
```

### **Step 3: Present to Users**

**Category-first tabs:**
```
THERAPEUTICS & MECHANISMS (23 papers)
Ranked by journal impact factor

1. Gastroenterology (IF: 29.4, Q1)
2. Gut (IF: 24.5, Q1)
3. Lancet Gastro (IF: 23.2, Q1)
...
```

---

## 📊 Journal Metrics Database

Built into `R/core_functions.R`:

```r
get_journal_metrics <- function() {
  tribble(
    ~journal, ~impact_factor, ~quartile,
    "Gastroenterology", 29.4, "Q1",
    "Gut", 24.5, "Q1",
    "Lancet Gastroenterology & Hepatology", 23.2, "Q1",
    "Clinical Gastroenterology and Hepatology", 11.6, "Q1",
    "Journal of Crohn's and Colitis", 8.3, "Q1",
    "Inflammatory Bowel Diseases", 7.2, "Q1",
    # 20+ journals total
  )
}
```

**Update annually** - No API needed

**Unknown journals:** IF = 0, appear last

---

## 🎨 User Experience

### **Main Website (Quarto)**

**URL:** `https://ibd-litmonitor.netlify.app`

**What users see:**
- Overview stats (total papers, RCTs, Q1 journals)
- Top journals this week (by paper count)
- 12 category tabs
  - Papers within each tab ranked by IF
  - Journal name + IF + quartile shown
  - Study design badges (RCT, Meta-analysis)
- Category distribution chart
- IF distribution chart
- RSS subscription button

### **Interactive Dashboard (Shiny)**

**URL:** `https://YOUR-USERNAME.shinyapps.io/ibd-litmonitor-dashboard`

**Filters (User Choice):**
- Category dropdown
- Journal quartile checkboxes (Q1, Q2, Q3, Q4)
- Minimum IF slider (0-50)
- Study design checkboxes
- Date range picker
- Keyword search

**Analytics:**
- Papers by category (bar chart)
- IF distribution (box plot)
- Top journals (pie chart)
- Publication timeline (line chart)

**Exports:**
- CSV download
- BibTeX download

**Special Tab:**
- "About Filtering" - Explains philosophy

---

## 🔄 Weekly Automation

**GitHub Action runs every Friday 7 AM:**

```yaml
1. Fetch papers from PubMed (28 queries)
2. Categorize into 12 subfields
3. Rank by IF/quartile within category
4. Generate RSS feed
5. Render Quarto website
6. Archive current report
7. Commit & push
8. Deploy to Netlify/GitHub Pages
```

**Users see fresh data every week, zero maintenance**

---

## 🎯 Value Proposition

### **For Busy Clinicians:**
- Organized by clinical area (not chaos)
- High-IF journals first (trusted sources)
- Quick Friday scan

### **For Researchers:**
- Complete coverage (28 queries)
- Objective ranking (IF/quartile)
- Filter to YOUR criteria

### **For Fellows/Trainees:**
- Learn what journals matter (IF shown)
- See study designs
- Discover across subfields

### **vs PubMed Emails:**
✅ Organized (12 categories)  
✅ Ranked (by IF)  
✅ Filterable (by quartile/design)

### **vs Subjective Curation:**
✅ Transparent (IF is objective)  
✅ Complete (all papers shown)  
✅ User-controlled (you filter)

---

## 💰 Cost: $0/month

| Service | What | Cost |
|---------|------|------|
| GitHub Pages/Netlify | Website hosting | $0 |
| GitHub Actions | Weekly automation | $0 |
| shinyapps.io | Dashboard (25 hrs/mo) | $0 |
| PubMed API | Data source | $0 |

**Scales to 10,000+ users for FREE**

---

## 🔒 Privacy & Code Protection

**Two-repo strategy (recommended):**

```
Private Repo (GitHub)
  ├─ R/core_functions.R (SECRET)
  ├─ *.qmd files
  └─ All code
      ↓
  Netlify builds
      ↓
Public Website (HTML only)
```

**Nobody sees your code!**

**Alternative:** Single private repo + Netlify (easiest)

---

## ✅ Ready to Deploy

```bash
# 1. Extract
tar -xzf ibd_litmonitor_UPDATED.tar.gz
cd ibd_litmonitor_final

# 2. Setup
./setup.sh  # or source("quickstart.R")

# 3. Deploy website
gh repo create ibd-litmonitor --private
git push
# Then connect to Netlify

# 4. Deploy dashboard
source("deploy_shiny.R")

# 5. You're live!
```

**Time: 15 minutes**

---

## 📚 Documentation

- **START_HERE.md** - Quick start guide
- **README.md** - Complete features & usage
- **DEPLOYMENT_GUIDE.md** - Privacy setup
- **This file** - Architecture overview

---

**Last updated:** March 2026 (Updated approach - no quality scores)
