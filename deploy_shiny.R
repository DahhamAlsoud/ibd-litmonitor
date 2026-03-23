################################################################################
# Deploy Shiny Dashboard to shinyapps.io (FREE)
################################################################################

# This script deploys your Shiny dashboard to shinyapps.io free tier
# Free tier: 25 active hours/month (plenty for a weekly-updated dashboard)

library(rsconnect)

# ============================================================================
# STEP 1: Install required packages
# ============================================================================

required_packages <- c(
  "shiny", "bslib", "tidyverse", "DT", "plotly", 
  "rsconnect", "jsonlite", "glue"
)

install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) {
    install.packages(new_packages)
  }
}

install_if_missing(required_packages)

# ============================================================================
# STEP 2: Setup shinyapps.io account
# ============================================================================

# 1. Go to https://www.shinyapps.io/admin/#/signup
# 2. Sign up for FREE account
# 3. Get your token and secret from: 
#    https://www.shinyapps.io/admin/#/tokens

# Run this ONCE with your credentials:
# rsconnect::setAccountInfo(
#   name = "dahham-alsoud",
#   token = "YOUR_TOKEN_HERE",
#   secret = "YOUR_SECRET_HERE"
# )

# ============================================================================
# STEP 3: Prepare dashboard for deployment
# ============================================================================

# Create deployment folder
if (!dir.exists("dashboard_deploy")) {
  dir.create("dashboard_deploy")
}

# Copy dashboard app
file.copy("dashboard/app.R", "dashboard_deploy/app.R", overwrite = TRUE)

# Copy data (create sample if doesn't exist)
if (file.exists("data_cache/papers.rds")) {
  file.copy("data_cache/papers.rds", "dashboard_deploy/papers.rds", overwrite = TRUE)
} else {
  # Create sample data for initial deployment
  sample_papers <- tibble::tibble(
    pmid = c("12345678", "87654321"),
    title = c("Sample Paper 1", "Sample Paper 2"),
    authors = c("Smith J, Doe A", "Johnson B, Williams C"),
    journal = c("Gastroenterology", "Gut"),
    publication_date = c("2026-03-15", "2026-03-18"),
    doi = c("10.1111/example1", "10.1111/example2"),
    abstract = c("Sample abstract 1", "Sample abstract 2"),
    study_design = c("Randomized controlled trial", "Cohort study"),
    category = c("Therapeutics & mechanisms", "Biomarkers & precision medicine"),
    journal_quartile = c("Q1", "Q1"),
    score = c(9.2, 8.5),
    url = c("https://pubmed.ncbi.nlm.nih.gov/12345678/", 
            "https://pubmed.ncbi.nlm.nih.gov/87654321/")
  )
  saveRDS(sample_papers, "dashboard_deploy/papers.rds")
  message("Created sample data for initial deployment")
}

# Update app.R to use local data
dashboard_code <- readLines("dashboard_deploy/app.R")

# Replace data loading line
dashboard_code <- gsub(
  'if \\(file.exists\\("../data_cache/papers.rds"\\)\\) \\{',
  'if (file.exists("papers.rds")) {',
  dashboard_code
)

dashboard_code <- gsub(
  'papers_data <- readRDS\\("../data_cache/papers.rds"\\)',
  'papers_data <- readRDS("papers.rds")',
  dashboard_code
)

dashboard_code <- gsub(
  'papers_data <- jsonlite::read_json\\("../data_cache/papers.json", simplifyVector = TRUE\\)',
  'papers_data <- readRDS("papers.rds")',
  dashboard_code
)

writeLines(dashboard_code, "dashboard_deploy/app.R")

# ============================================================================
# STEP 4: Deploy to shinyapps.io
# ============================================================================

cat("\n=================================================================\n")
cat("Deploying to shinyapps.io...\n")
cat("=================================================================\n\n")

rsconnect::deployApp(
  appDir = "dashboard_deploy",
  appName = "ibd-litmonitor-dashboard",
  appTitle = "IBD LitMonitor Dashboard",
  account = "dahham-alsoud",
  forceUpdate = TRUE
)

cat("\n=================================================================\n")
cat("✅ Deployment complete!\n")
cat("\nYour dashboard is live at:\n")
cat("https://dahham-alsoud.shinyapps.io/ibd-litmonitor-dashboard/\n")
cat("=================================================================\n\n")

# ============================================================================
# STEP 5: Update Quarto site with dashboard URL
# ============================================================================

# Update dashboard.qmd with your live URL
dashboard_qmd <- readLines("dashboard.qmd")
dashboard_qmd <- gsub(
  'src="https://dahham-alsoud.shinyapps.io/ibd-litmonitor-dashboard/"',
  'src="https://YOUR-USERNAME.shinyapps.io/ibd-litmonitor-dashboard/"',
  dashboard_qmd
)
writeLines(dashboard_qmd, "dashboard.qmd")

cat("\n⚠️  Remember to update dashboard.qmd with your actual shinyapps.io URL!\n\n")

# ============================================================================
# USAGE NOTES
# ============================================================================

cat("\n=================================================================\n")
cat("FREE TIER LIMITS:\n")
cat("=================================================================\n")
cat("- 25 active hours per month (dashboard sleeps when not in use)\n")
cat("- 5 applications max\n")
cat("- 1 GB RAM per app\n")
cat("- For a weekly-updated dashboard, this is MORE than enough!\n\n")

cat("TO UPDATE DATA:\n")
cat("=================================================================\n")
cat("1. Run your R script to fetch new papers\n")
cat("2. Copy data_cache/papers.rds to dashboard_deploy/papers.rds\n")
cat("3. Run this script again to redeploy\n\n")

cat("AUTOMATED UPDATES (Optional):\n")
cat("=================================================================\n")
cat("Add this to your GitHub Action after rendering Quarto:\n\n")
cat("
- name: Update Shiny dashboard
  run: |
    Rscript -e '
      library(rsconnect)
      file.copy(\"data_cache/papers.rds\", \"dashboard_deploy/papers.rds\")
      deployApp(\"dashboard_deploy\", appName = \"ibd-litmonitor-dashboard\")
    '
  env:
    SHINYAPPS_TOKEN: \${{ secrets.SHINYAPPS_TOKEN }}
    SHINYAPPS_SECRET: \${{ secrets.SHINYAPPS_SECRET }}
\n")

cat("=================================================================\n\n")
