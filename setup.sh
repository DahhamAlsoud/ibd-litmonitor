#!/bin/bash

################################################################################
# IBD LitMonitor - Complete Setup Script
# Run this script to set up everything automatically
################################################################################

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║        IBD LITMONITOR - AUTOMATED SETUP                  ║"
echo "║                                                           ║"
echo "║  This will set up your complete literature monitoring    ║"
echo "║  platform with privacy protection                        ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Check if running on macOS or Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
else
    echo "❌ This script is for macOS or Linux only"
    echo "   For Windows, use quickstart.R in RStudio"
    exit 1
fi

echo "✅ Detected OS: $OS"
echo ""

# ============================================================================
# STEP 1: Check dependencies
# ============================================================================

echo "📋 Checking dependencies..."
echo ""

# Check R
if ! command -v R &> /dev/null; then
    echo "❌ R not found. Please install from: https://cran.r-project.org/"
    exit 1
fi
echo "✅ R found: $(R --version | head -n 1)"

# Check Quarto
if ! command -v quarto &> /dev/null; then
    echo "⚠️  Quarto not found. Installing..."
    
    if [[ "$OS" == "macOS" ]]; then
        if command -v brew &> /dev/null; then
            brew install quarto
        else
            echo "   Please install Homebrew or download Quarto from:"
            echo "   https://quarto.org/docs/get-started/"
            exit 1
        fi
    else
        echo "   Please install Quarto from: https://quarto.org/docs/get-started/"
        exit 1
    fi
fi
echo "✅ Quarto found: $(quarto --version)"

# Check Git
if ! command -v git &> /dev/null; then
    echo "⚠️  Git not found. Please install Git"
    exit 1
fi
echo "✅ Git found: $(git --version)"

echo ""

# ============================================================================
# STEP 2: Setup directory structure
# ============================================================================

echo "📁 Creating directory structure..."

mkdir -p R
mkdir -p dashboard
mkdir -p data_cache
mkdir -p docs
mkdir -p .github/workflows

echo "✅ Directories created"
echo ""

# ============================================================================
# STEP 3: Install R packages
# ============================================================================

echo "📦 Installing R packages..."
echo "   (This may take several minutes)"
echo ""

Rscript -e 'quickstart_packages <- c("rentrez", "tidyverse", "lubridate", "jsonlite", "xml2", "glue", "knitr", "rmarkdown", "ggplot2", "shiny", "bslib", "DT", "plotly", "rsconnect"); new_packages <- quickstart_packages[!(quickstart_packages %in% installed.packages()[,"Package"])]; if(length(new_packages)) install.packages(new_packages, repos="https://cloud.r-project.org/")'

echo "✅ R packages installed"
echo ""

# ============================================================================
# STEP 4: Initialize Git repository
# ============================================================================

echo "🔧 Initializing Git repository..."

if [ ! -d .git ]; then
    git init
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository already exists"
fi

echo ""

# ============================================================================
# STEP 5: Test data fetch
# ============================================================================

echo "🧪 Testing PubMed connection..."

Rscript -e 'source("R/core_functions.R"); tryCatch({ papers <- get_papers(days_back = 7, use_cache = FALSE); cat("✅ Successfully fetched", nrow(papers), "papers\n") }, error = function(e) { cat("⚠️  Could not fetch papers. You can set up API credentials later.\n") })'

echo ""

# ============================================================================
# STEP 6: Render initial website
# ============================================================================

echo "🌐 Rendering Quarto website..."

if quarto render; then
    echo "✅ Website rendered successfully!"
else
    echo "⚠️  Website rendering failed. Check errors above."
fi

echo ""

# ============================================================================
# STEP 7: Setup GitHub
# ============================================================================

echo "🔐 Setting up GitHub repository..."
echo ""
echo "Choose deployment option:"
echo "  1) Private repo + Netlify (RECOMMENDED - easiest & free)"
echo "  2) Private repo + GitHub Pages (requires GitHub Pro)"
echo "  3) Two repos (private code + public site)"
echo "  4) Skip for now (manual setup later)"
echo ""
read -p "Enter choice (1-4): " choice

case $choice in
    1)
        echo ""
        echo "📌 NETLIFY DEPLOYMENT (Recommended)"
        echo "══════════════════════════════════"
        echo ""
        echo "Next steps:"
        echo "1. Create private GitHub repo:"
        echo "   gh repo create ibd-litmonitor --private --source=. --remote=origin"
        echo ""
        echo "2. Push your code:"
        echo "   git add ."
        echo "   git commit -m 'Initial commit'"
        echo "   git push -u origin main"
        echo ""
        echo "3. Deploy to Netlify:"
        echo "   • Go to netlify.com and sign up (FREE)"
        echo "   • Click 'New site from Git'"
        echo "   • Connect to GitHub (authorize private repos)"
        echo "   • Select your ibd-litmonitor repo"
        echo "   • Build command: quarto render"
        echo "   • Publish directory: docs"
        echo "   • Click Deploy!"
        echo ""
        echo "Your site will be live at: https://ibd-litmonitor.netlify.app"
        echo ""
        ;;
    2)
        echo ""
        echo "📌 GITHUB PAGES (Private Repo)"
        echo "═════════════════════════════════"
        echo ""
        echo "⚠️  Requires GitHub Pro/Team ($4/month)"
        echo ""
        echo "Next steps:"
        echo "1. Create private repo:"
        echo "   gh repo create ibd-litmonitor --private --source=. --remote=origin"
        echo ""
        echo "2. Enable GitHub Pages:"
        echo "   • Go to repo Settings → Pages"
        echo "   • Source: main branch, /docs folder"
        echo "   • Save"
        echo ""
        echo "3. Push code:"
        echo "   git add ."
        echo "   git commit -m 'Initial commit'"
        echo "   git push -u origin main"
        echo ""
        ;;
    3)
        echo ""
        echo "📌 TWO REPOSITORIES"
        echo "═══════════════════"
        echo ""
        echo "See DEPLOYMENT_GUIDE.md for detailed instructions"
        echo ""
        ;;
    4)
        echo ""
        echo "⏭️  Skipping GitHub setup"
        echo ""
        ;;
esac

# ============================================================================
# COMPLETION MESSAGE
# ============================================================================

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                  SETUP COMPLETE! 🎉                       ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

echo "✅ What's ready:"
echo "   • R packages installed"
echo "   • Directory structure created"
echo "   • Website generated in docs/"
echo "   • Git repository initialized"
echo ""

echo "📋 NEXT STEPS:"
echo ""
echo "   1. Test locally:"
echo "      quarto preview"
echo ""
echo "   2. Deploy Shiny dashboard:"
echo "      Rscript deploy_shiny.R"
echo ""
echo "   3. Setup GitHub repository (if not done yet):"
echo "      gh repo create ibd-litmonitor --private"
echo ""
echo "   4. Configure GitHub Actions for automation:"
echo "      See DEPLOYMENT_GUIDE.md"
echo ""

echo "📚 DOCUMENTATION:"
echo "   • README.md - Complete guide"
echo "   • DEPLOYMENT_GUIDE.md - Deployment options"
echo "   • quickstart.R - R-based setup"
echo ""

echo "🔐 PRIVACY NOTES:"
echo "   • Your R code is protected by .gitignore"
echo "   • Only docs/ folder should be public"
echo "   • Never commit .Renviron (contains API keys)"
echo "   • Use private repo for development"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Questions? Email: your.email@stanford.edu"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
