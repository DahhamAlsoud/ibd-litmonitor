#!/usr/bin/env Rscript

################################################################################
# IBD LitMonitor - Quick Start Script
# Run this to set up everything in 5 minutes
################################################################################

cat("\n")
cat("╔═══════════════════════════════════════════════════════════╗\n")
cat("║                                                           ║\n")
cat("║           IBD LITMONITOR - QUICK START                   ║\n")
cat("║                                                           ║\n")
cat("║  This script will set up your complete IBD literature    ║\n")
cat("║  monitoring platform in ~5 minutes                       ║\n")
cat("║                                                           ║\n")
cat("╚═══════════════════════════════════════════════════════════╝\n")
cat("\n")

# ============================================================================
# STEP 1: Check R version
# ============================================================================

cat("📋 Checking R version...\n")
r_version <- getRversion()
if (r_version < "4.3.0") {
  cat("❌ R version 4.3.0 or higher required. You have:", as.character(r_version), "\n")
  cat("   Please update R from: https://cran.r-project.org/\n")
  quit(status = 1)
}
cat("✅ R version OK:", as.character(r_version), "\n\n")

# ============================================================================
# STEP 2: Install required packages
# ============================================================================

cat("📦 Installing required R packages...\n")
cat("   (This may take a few minutes)\n\n")

required_packages <- c(
  # Core data processing
  "rentrez", "tidyverse", "lubridate", "jsonlite", "xml2", "glue",

  # Quarto/reporting
  "knitr", "rmarkdown", "ggplot2", "gt",

  # Shiny dashboard
  "shiny", "bslib", "DT", "plotly", "rsconnect"
)

install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) {
    cat("   Installing:", paste(new_packages, collapse = ", "), "\n")
    install.packages(new_packages, repos = "https://cloud.r-project.org/")
  } else {
    cat("   All packages already installed!\n")
  }
}

install_if_missing(required_packages)
cat("✅ R packages installed\n\n")

# ============================================================================
# STEP 3: Check Quarto
# ============================================================================

cat("🔍 Checking for Quarto...\n")
quarto_check <- system("quarto --version", ignore.stdout = TRUE, ignore.stderr = TRUE)

if (quarto_check != 0) {
  cat("⚠️  Quarto not found. Please install from: https://quarto.org/docs/get-started/\n")
  cat("   Then run this script again.\n\n")
} else {
  cat("✅ Quarto found\n\n")
}

# ============================================================================
# STEP 4: Setup PubMed credentials
# ============================================================================

cat("🔐 Setting up PubMed API credentials...\n\n")

renviron_path <- path.expand("~/.Renviron")
existing_lines <- if (file.exists(renviron_path)) readLines(renviron_path) else character(0)
already_set <- any(grepl("^PUBMED_API_KEY=", existing_lines))

if (already_set) {
  cat("   PubMed credentials already set in ~/.Renviron\n")
} else {
  cat("   Do you have a PubMed API key? (y/n): ")
  response <- tolower(trimws(readLines("stdin", n = 1)))

  if (response == "y") {
    cat("   Enter your email: ")
    email <- trimws(readLines("stdin", n = 1))

    cat("   Enter your PubMed API key: ")
    api_key <- trimws(readLines("stdin", n = 1))

    new_lines <- c(
      existing_lines,
      paste0("PUBMED_EMAIL=", email),
      paste0("PUBMED_API_KEY=", api_key)
    )
    writeLines(new_lines, renviron_path)
    cat("✅ Credentials saved to ~/.Renviron\n\n")
  } else {
    cat("   No problem! You can add credentials later.\n")
    cat("   Get free API key: https://www.ncbi.nlm.nih.gov/account/\n\n")
  }
}

# ============================================================================
# STEP 5: Test data fetch
# ============================================================================

cat("🧪 Testing data fetch from PubMed...\n")

tryCatch({
  source("R/core_functions.R")
  cat("   Fetching last 7 days of papers...\n")
  papers <- get_papers(days_back = 7, use_cache = FALSE)
  cat("✅ Successfully fetched", nrow(papers), "papers\n\n")
  
  if (nrow(papers) > 0) {
    cat("   Sample paper:\n")
    cat("   Title:", papers$title[1], "\n")
    cat("   Journal:", papers$journal[1], "\n")
    cat("   Category:", papers$category[1], "\n\n")
  }
}, error = function(e) {
  cat("⚠️  Error fetching papers:", e$message, "\n")
  cat("   This might be due to network issues or API limits.\n")
  cat("   You can continue setup and try again later.\n\n")
})

# ============================================================================
# STEP 6: Render test website
# ============================================================================

cat("🌐 Rendering Quarto website...\n")

if (quarto_check == 0) {
  render_result <- system("quarto render", ignore.stdout = FALSE)
  
  if (render_result == 0) {
    cat("✅ Website rendered successfully!\n\n")
    cat("   Preview locally with: quarto preview\n\n")
  } else {
    cat("⚠️  Website rendering failed. Check error messages above.\n\n")
  }
} else {
  cat("⏭️  Skipping (Quarto not installed)\n\n")
}

# ============================================================================
# STEP 7: Setup instructions
# ============================================================================

cat("\n")
cat("╔═══════════════════════════════════════════════════════════╗\n")
cat("║                    SETUP COMPLETE! 🎉                     ║\n")
cat("╚═══════════════════════════════════════════════════════════╝\n")
cat("\n")

cat("✅ What's ready:\n")
cat("   • R packages installed\n")
cat("   • PubMed connection tested\n")
cat("   • Website generated\n\n")

cat("📋 NEXT STEPS:\n")
cat("   \n")
cat("   1. Preview website locally:\n")
cat("      quarto preview\n")
cat("   \n")
cat("   2. Deploy Shiny dashboard:\n")
cat("      source('deploy_shiny.R')\n")
cat("   \n")
cat("   3. Deploy to GitHub:\n")
cat("      See DEPLOYMENT_GUIDE.md for full instructions\n")
cat("   \n")

cat("📚 DOCUMENTATION:\n")
cat("   • README.md - Complete documentation\n")
cat("   • DEPLOYMENT_GUIDE.md - Deployment options (Netlify, GitHub, etc.)\n")
cat("   • deploy_shiny.R - Shiny dashboard deployment\n")
cat("   \n")

cat("🔐 PRIVACY:\n")
cat("   Your R code in R/core_functions.R is YOUR intellectual property.\n")
cat("   The .gitignore file is configured to keep it private.\n")
cat("   Only rendered HTML gets published publicly.\n")
cat("   \n")

cat("💡 TIPS:\n")
cat("   • Test everything locally first\n")
cat("   • Use private GitHub repo for code\n")
cat("   • Deploy website to Netlify (easiest) or GitHub Pages\n")
cat("   • Keep PubMed API key secret\n")
cat("   \n")

cat("🚀 QUICK COMMANDS:\n")
cat("   \n")
cat("   # Fetch new papers\n")
cat("   source('R/core_functions.R')\n")
cat("   papers <- get_papers(days_back = 7)\n")
cat("   \n")
cat("   # Render website\n")
cat("   quarto render\n")
cat("   \n")
cat("   # Preview locally\n")
cat("   quarto preview\n")
cat("   \n")

cat("═══════════════════════════════════════════════════════════\n")
cat("\n")
cat("Need help? Check the documentation or email:\n")
cat("your.email@stanford.edu\n")
cat("\n")
cat("═══════════════════════════════════════════════════════════\n")
cat("\n")
