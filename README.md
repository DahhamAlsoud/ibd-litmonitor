# IBD LitMonitor

**Systematic literature monitoring for IBD researchers**

Created by **Dahham Alsoud, MD, MHCM**  
Visiting Instructor, Stanford University School of Medicine

---

## 🎯 What is This?

IBD LitMonitor automatically searches PubMed weekly for the latest IBD research and presents it through:

- 📊 **Quality-filtered reports** - Papers ranked by clinical impact
- 🏷️ **12 Research categories** - From therapeutics to AI/ML
- 📱 **Interactive dashboard** - Filter, search, and explore
- 📡 **RSS feed** - Subscribe for weekly updates
- 💾 **Multiple formats** - CSV, BibTeX, JSON exports

**Live site:** https://dahhamalsoud.github.io/ibd-litmonitor

---

## ✨ Features

### Automated Literature Monitoring
- ✅ Weekly PubMed searches across 11 IBD domains
- ✅ Comprehensive query coverage (28+ search terms)
- ✅ Automatic categorization into 12 research areas
- ✅ Quality-based scoring and ranking

### Interactive Tools
- ✅ Web-based reports (Quarto)
- ✅ Shiny dashboard for advanced filtering
- ✅ RSS feed for subscriptions
- ✅ CSV/BibTeX/JSON exports

### 100% FREE Infrastructure
- ✅ GitHub Pages (hosting)
- ✅ GitHub Actions (automation)
- ✅ shinyapps.io free tier (dashboard)
- ✅ No server costs, ever

---

## 🏗️ Architecture

### Components

```
┌─────────────────────────────────────────────┐
│  GitHub Actions (Runs Weekly)               │
│  ├─ Fetch papers from PubMed                │
│  ├─ Process & categorize                    │
│  ├─ Render Quarto website                   │
│  └─ Deploy to GitHub Pages                  │
└─────────────────────────────────────────────┘
             ↓
┌─────────────────────────────────────────────┐
│  Public Website (GitHub Pages)              │
│  ├─ Weekly reports                          │
│  ├─ Archive                                 │
│  ├─ RSS feed                                │
│  └─ Links to dashboard                      │
└─────────────────────────────────────────────┘
             ↓
┌─────────────────────────────────────────────┐
│  Shiny Dashboard (shinyapps.io)             │
│  ├─ Interactive filtering                   │
│  ├─ Analytics & charts                      │
│  └─ Data exports                            │
└─────────────────────────────────────────────┘
```

### Technology Stack

- **R** - Data processing and analysis
- **Quarto** - Website generation
- **Shiny** - Interactive dashboard
- **GitHub Actions** - Automation
- **GitHub Pages** - Hosting
- **PubMed API** - Data source

---

## 🚀 Quick Start

### Prerequisites

- R (≥ 4.3.0)
- RStudio (recommended)
- Quarto CLI
- GitHub account
- shinyapps.io account (free)

### Installation

1. **Clone this repository**

```bash
git clone https://github.com/YOUR-USERNAME/ibd-litmonitor-private.git
cd ibd-litmonitor-private
```

2. **Install R packages**

```r
# Run in R console
install.packages(c(
  "rentrez", "tidyverse", "lubridate", "jsonlite", 
  "xml2", "glue", "knitr", "rmarkdown", "ggplot2",
  "shiny", "bslib", "DT", "plotly", "rsconnect"
))
```

3. **Set up PubMed API** (optional but recommended)

Get free API key: https://www.ncbi.nlm.nih.gov/account/

Create `.Renviron` file:
```bash
PUBMED_EMAIL=your.email@stanford.edu
PUBMED_API_KEY=your_api_key_here
```

4. **Test locally**

```r
# Fetch papers
source("R/core_functions.R")
papers <- get_papers(days_back = 7)

# Render website
quarto render
```

5. **Deploy**

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for detailed instructions.

---

## 📋 Usage

### Local Development

```r
# 1. Fetch latest papers
source("R/core_functions.R")
papers <- get_papers(days_back = 7, use_cache = FALSE)

# 2. Render Quarto site
quarto render

# 3. Preview locally
quarto preview
```

### Deploy to GitHub Pages

```bash
# 1. Commit changes
git add .
git commit -m "Update content"
git push

# 2. GitHub Actions runs automatically
# 3. Site updates at https://YOUR-USERNAME.github.io/ibd-litmonitor
```

### Deploy Shiny Dashboard

```r
# Run deployment script
source("deploy_shiny.R")

# Follow prompts to configure shinyapps.io
```

---

## 🔒 Privacy & Code Protection

### Two-Repository Strategy

To keep your **code private** while the **website is public**:

**Option 1: Private repo + Netlify (Recommended)**
- Keep everything in ONE private repo
- Deploy to Netlify (free)
- Code stays private, website is public

**Option 2: Two repositories**
- Private repo: Code + Quarto files
- Public repo: Rendered HTML only
- GitHub Action pushes HTML to public repo

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for complete instructions.

### What's Private

Never commit to public repo:
- ❌ `R/core_functions.R` (your secret sauce)
- ❌ Search query strategies
- ❌ API credentials
- ❌ Proprietary algorithms

### What's Public

Safe to share:
- ✅ Rendered HTML (in `docs/`)
- ✅ About page
- ✅ Styles (CSS)
- ✅ Quarto source files (optional)

---

## 📊 Data Structure

### Paper Object

```r
tibble(
  pmid = "12345678",
  title = "Paper title",
  authors = "Smith J, Doe A",
  journal = "Gastroenterology",
  publication_date = "2026-03-15",
  doi = "10.1111/example",
  abstract = "Full abstract text...",
  study_design = "Randomized controlled trial",
  category = "Therapeutics & mechanisms",
  journal_quartile = "Q1",
  score = 9.2,
  url = "https://pubmed.ncbi.nlm.nih.gov/12345678/"
)
```

### Categories (12 total)

1. Therapeutics & mechanisms
2. Biomarkers & precision medicine
3. AI & machine learning
4. Endoscopy & imaging
5. Pediatric IBD
6. Surgery & complications
7. Epidemiology & outcomes
8. Guidelines & consensus
9. Microbiome & immunology
10. Nutrition & lifestyle
11. Extraintestinal manifestations
12. General IBD

---

## 🤝 Contributing

This is a personal research tool. The codebase is proprietary, but feedback and suggestions are welcome!

**To suggest improvements:**
- Open an issue
- Email: your.email@stanford.edu

**Not accepting:**
- Pull requests to core algorithms
- Requests for source code
- Commercial licensing inquiries

---

## 📜 License

**Website content:** CC BY 4.0 (free to use with attribution)  
**Source code:** Proprietary © 2026 Dahham Alsoud

The rendered website and literature summaries are freely accessible. The underlying code and algorithms are proprietary to ensure quality control and prevent unauthorized modifications.

---

## 📧 Contact

**Dahham Alsoud, MD, MHCM**  
Visiting Instructor, Stanford University School of Medicine  
Email: your.email@stanford.edu  
Website: https://dahhamalsoud.github.io

---

## 🙏 Acknowledgments

- **PubMed/NCBI** - Literature database
- **R Community** - Amazing open-source packages
- **Quarto Project** - Beautiful publishing system
- **GitHub** - Free hosting and automation
- **BAEF** - Fellowship support

---

## 📚 Citation

If you use IBD LitMonitor in your research, please cite:

```
Alsoud, D. (2026). IBD LitMonitor: Systematic literature monitoring 
for inflammatory bowel disease research. 
https://dahhamalsoud.github.io/ibd-litmonitor
```

---

## 🎯 Roadmap

- [ ] User-specific email alerts
- [ ] Custom query builder
- [ ] Conference abstract integration
- [ ] Citation tracking
- [ ] Collaborative annotations
- [ ] API for programmatic access

---

**Last updated:** March 2026
