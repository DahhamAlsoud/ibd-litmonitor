################################################################################
# IBD LitMonitor - Core Functions (Updated)
# PRIVATE - Do not distribute
# © 2026 Dahham Alsoud
################################################################################

library(rentrez)
library(tidyverse)
library(lubridate)
library(jsonlite)
library(xml2)
library(glue)

# Set PubMed API configuration
PUBMED_EMAIL <- Sys.getenv("PUBMED_EMAIL", "")
PUBMED_API_KEY <- Sys.getenv("PUBMED_API_KEY", "")

if (PUBMED_API_KEY != "") {
  set_entrez_key(PUBMED_API_KEY)
}


################################################################################
# PubMed Search Queries
################################################################################

get_search_queries <- function() {
  list(
    therapeutics = c(
      "(inflammatory bowel disease OR Crohn OR ulcerative colitis) AND (vedolizumab OR ustekinumab OR risankizumab OR mirikizumab OR guselkumab)",
      "(inflammatory bowel disease OR IBD) AND (JAK inhibitor OR tofacitinib OR upadacitinib OR filgotinib)",
      "(inflammatory bowel disease OR IBD) AND (S1P OR ozanimod OR etrasimod)",
      "(inflammatory bowel disease OR IBD) AND (anti-TNF OR infliximab OR adalimumab OR golimumab)"
    ),
    biomarkers = c(
      "(inflammatory bowel disease OR IBD) AND (biomarker OR precision medicine)",
      "(inflammatory bowel disease OR IBD) AND (proteomics OR transcriptomics OR metabolomics OR genomics)",
      "(inflammatory bowel disease OR IBD) AND (cfDNA OR cell-free DNA OR liquid biopsy)"
    ),
    imaging = c(
      "(inflammatory bowel disease OR IBD) AND (endoscopy OR colonoscopy) AND mucosal healing",
      "(Crohn disease OR ulcerative colitis) AND (intestinal ultrasound OR bowel ultrasound)",
      "(inflammatory bowel disease OR IBD) AND (MRI OR magnetic resonance OR enterography)",
      "(inflammatory bowel disease OR IBD) AND (histology OR histopathology)"
    ),
    ai_digital = c(
      "(inflammatory bowel disease OR IBD) AND (machine learning OR deep learning OR artificial intelligence)",
      "(inflammatory bowel disease OR IBD) AND (digital health OR telemedicine OR remote monitoring)"
    ),
    pediatric = c(
      # Use specific disease names (not just "IBD") to avoid broad-context matches
      # that pick up animal models or review papers mentioning "children" in passing
      "(Crohn disease OR ulcerative colitis) AND (pediatric OR paediatric OR children OR adolescent) AND humans[MH]",
      "(Crohn disease OR ulcerative colitis) AND (very early onset OR VEO-IBD OR infantile OR childhood-onset)"
    ),
    surgery = c(
      "(Crohn disease) AND (surgery OR surgical OR postoperative OR resection)",
      "(inflammatory bowel disease OR IBD) AND (fistula OR perianal OR enterocutaneous)",
      "(ulcerative colitis) AND (colectomy OR pouch OR pouchitis OR IPAA)"
    ),
    epidemiology = c(
      "(inflammatory bowel disease OR IBD) AND (epidemiology OR incidence OR prevalence)",
      "(inflammatory bowel disease OR IBD) AND (real-world OR registry OR population-based)",
      "(inflammatory bowel disease OR IBD) AND (outcomes OR prognosis OR natural history)"
    ),
    guidelines = c(
      "(inflammatory bowel disease OR IBD OR Crohn OR ulcerative colitis) AND (guideline OR consensus OR recommendation)"
    ),
    microbiome = c(
      "(inflammatory bowel disease OR IBD) AND (microbiome OR microbiota OR dysbiosis)",
      "(inflammatory bowel disease OR IBD) AND (mucosal immunology OR immune response)"
    ),
    nutrition = c(
      # Require explicit nutritional therapy terms; omit bare "diet" or "nutrition"
      # which are too broad and pick up pharmacology/animal studies
      "(inflammatory bowel disease OR IBD) AND (exclusive enteral nutrition OR EEN)",
      "(inflammatory bowel disease OR IBD) AND (nutritional therapy OR dietary therapy OR specific carbohydrate diet OR mediterranean diet)",
      "(inflammatory bowel disease OR IBD) AND (enteral nutrition OR parenteral nutrition)"
    ),
    extraintestinal = c(
      # Split into sub-queries covering distinct EIM domains — avoids papers that
      # happen to mention "extraintestinal" in passing being the only catch-all
      "(inflammatory bowel disease OR IBD) AND (uveitis OR episcleritis OR iritis OR ocular manifestation)",
      "(inflammatory bowel disease OR IBD) AND (pyoderma gangrenosum OR erythema nodosum OR cutaneous manifestation OR skin manifestation)",
      "(inflammatory bowel disease OR IBD) AND (primary sclerosing cholangitis OR PSC-IBD OR hepatobiliary manifestation)",
      "(inflammatory bowel disease OR IBD) AND (spondyloarthropathy OR sacroiliitis OR ankylosing spondylitis OR axial spondyloarthritis OR peripheral arthritis) AND extraintestinal"
    ),
    genetics = c(
      "(inflammatory bowel disease OR IBD) AND (genome-wide association OR GWAS OR genetic variant OR SNP OR polymorphism)",
      "(inflammatory bowel disease OR IBD) AND (NOD2 OR IL23R OR ATG16L1 OR CARD9 OR genetic susceptibility OR susceptibility locus)",
      "(inflammatory bowel disease OR IBD) AND (polygenic risk score OR pharmacogenomics OR genetic architecture OR heritability OR Mendelian randomization)"
    ),
    quality_of_life = c(
      "(inflammatory bowel disease OR IBD) AND (quality of life OR health-related quality of life OR HRQOL OR IBDQ)",
      "(inflammatory bowel disease OR IBD) AND (patient-reported outcome OR PRO OR fatigue OR disability index OR work impairment)",
      "(inflammatory bowel disease OR IBD) AND (anxiety OR depression OR psychological burden OR mental health)"
    ),
    pregnancy = c(
      "(inflammatory bowel disease OR IBD OR Crohn disease OR ulcerative colitis) AND (pregnancy OR maternal outcome OR obstetric complication)",
      "(inflammatory bowel disease OR IBD) AND (fertility OR conception OR neonatal outcome OR breastfeeding OR lactation OR postpartum)"
    ),
    drug_safety = c(
      "(inflammatory bowel disease OR IBD) AND (adverse event OR adverse effect OR drug toxicity OR drug safety)",
      "(inflammatory bowel disease OR IBD) AND (pharmacovigilance OR post-marketing surveillance OR safety profile)",
      "(inflammatory bowel disease OR IBD) AND (opportunistic infection OR infection risk OR malignancy risk) AND (biologic OR immunosuppressive OR immunomodulator)"
    ),
    neoplasia = c(
      "(inflammatory bowel disease OR IBD OR ulcerative colitis OR Crohn disease) AND (colorectal cancer OR CRC OR colitis-associated cancer OR dysplasia) AND surveillance",
      "(inflammatory bowel disease OR IBD) AND (cancer risk OR neoplasia OR neoplasm OR carcinogenesis) AND (colitis OR intestinal)"
    ),
    pathogenesis = c(
      # Focused on bench/mechanistic research — kept specific to avoid overlap
      # with Microbiome (which covers immune response) and Therapeutics (mechanisms of action)
      "(inflammatory bowel disease OR IBD) AND (epithelial barrier OR tight junction OR intestinal permeability OR mucosal barrier)",
      "(Crohn disease OR ulcerative colitis) AND (experimental colitis OR animal model OR mouse model OR dextran sodium sulfate OR TNBS)",
      "(inflammatory bowel disease OR IBD) AND (T cell OR innate immunity OR dendritic cell OR macrophage OR neutrophil) AND (pathogenesis OR disease mechanism OR gut inflammation)"
    )
  )
}

################################################################################
# Search Functions
################################################################################

search_pubmed <- function(query, days_back = 7, max_results = 50) {
  end_date <- Sys.Date()
  start_date <- end_date - days(days_back)
  
  date_filter <- glue("{format(start_date, '%Y/%m/%d')}:{format(end_date, '%Y/%m/%d')}[dp]")
  full_query <- glue("({query}) AND {date_filter}")
  
  tryCatch({
    search_results <- entrez_search(
      db = "pubmed",
      term = full_query,
      retmax = max_results,
      use_history = FALSE
    )
    return(search_results$ids)
  }, error = function(e) {
    warning(glue("Search error: {e$message}"))
    return(character(0))
  })
}

fetch_paper_details <- function(pmids) {
  if (length(pmids) == 0) return(tibble())
  
  batch_size <- 200
  all_papers <- list()
  
  for (i in seq(1, length(pmids), by = batch_size)) {
    batch_end <- min(i + batch_size - 1, length(pmids))
    batch_pmids <- pmids[i:batch_end]
    
    tryCatch({
      fetch_result <- entrez_fetch(
        db = "pubmed",
        id = batch_pmids,
        rettype = "xml",
        parsed = FALSE
      )

      papers <- parse_pubmed_xml(xml2::read_xml(fetch_result))
      all_papers <- c(all_papers, list(papers))
      Sys.sleep(0.34)
    }, error = function(e) {
      warning(glue("Fetch error for batch {i}-{batch_end}: {e$message}"))
    })
  }
  
  if (length(all_papers) > 0) {
    bind_rows(all_papers)
  } else {
    tibble()
  }
}

parse_pubmed_xml <- function(xml_doc) {
  articles <- xml_find_all(xml_doc, "//PubmedArticle")
  
  papers_list <- map(articles, function(article) {
    tryCatch({
      pmid <- xml_text(xml_find_first(article, ".//PMID"))
      title <- xml_text(xml_find_first(article, ".//ArticleTitle"))
      if (is.na(title)) title <- "No title"
      
      author_nodes <- xml_find_all(article, ".//Author")
      authors <- map_chr(author_nodes, function(author) {
        last_name <- xml_text(xml_find_first(author, "LastName"))
        initials <- xml_text(xml_find_first(author, "Initials"))
        if (!is.na(last_name)) {
          if (!is.na(initials)) paste(last_name, initials) else last_name
        } else NA_character_
      })
      authors <- authors[!is.na(authors)]
      authors_str <- paste(head(authors, 10), collapse = ", ")
      
      journal <- xml_text(xml_find_first(article, ".//Journal/Title"))
      if (is.na(journal)) journal <- "Unknown journal"
      
      pub_date <- extract_publication_date(article)
      
      doi_nodes <- xml_find_all(article, ".//ArticleId[@IdType='doi']")
      doi <- if (length(doi_nodes) > 0) xml_text(doi_nodes[[1]]) else ""
      
      abstract_nodes <- xml_find_all(article, ".//AbstractText")
      abstract <- paste(xml_text(abstract_nodes), collapse = " ")
      
      pub_types <- xml_text(xml_find_all(article, ".//PublicationType"))
      study_design <- infer_study_design(pub_types, title, abstract)

      # Flag papers from high-impact IBD/GI journals
      flagship_journals <- c(
        "gut", "gastroenterology",
        "the lancet", "lancet", "lancet gastroenterology", "lancet gastroenterology & hepatology",
        "new england journal of medicine", "the new england journal of medicine",
        "journal of crohn's and colitis", "journal of crohn's & colitis",
        "inflammatory bowel diseases",
        "clinical gastroenterology and hepatology",
        "alimentary pharmacology & therapeutics", "alimentary pharmacology and therapeutics",
        "nature medicine", "nature",
        "jama", "jama internal medicine",
        "annals of internal medicine",
        "united european gastroenterology journal"
      )
      flagship <- tolower(journal) %in% flagship_journals

      tibble(
        pmid = pmid,
        title = title,
        authors = authors_str,
        journal = journal,
        publication_date = pub_date,
        doi = doi,
        abstract = abstract,
        study_design = study_design,
        flagship = flagship,
        url = glue("https://pubmed.ncbi.nlm.nih.gov/{pmid}/")
      )
    }, error = function(e) NULL)
  })
  
  papers_list <- compact(papers_list)
  if (length(papers_list) > 0) bind_rows(papers_list) else tibble()
}

extract_publication_date <- function(article) {
  epub_date <- xml_find_first(article, ".//ArticleDate[@DateType='Electronic']")
  if (!is.na(epub_date)) {
    year <- xml_text(xml_find_first(epub_date, "Year"))
    month <- xml_text(xml_find_first(epub_date, "Month"))
    day <- xml_text(xml_find_first(epub_date, "Day"))
    if (!is.na(year)) {
      date_str <- year
      if (!is.na(month)) {
        date_str <- paste(date_str, str_pad(month, 2, pad = "0"), sep = "-")
        if (!is.na(day)) date_str <- paste(date_str, str_pad(day, 2, pad = "0"), sep = "-")
      }
      return(date_str)
    }
  }
  
  pub_date <- xml_find_first(article, ".//PubDate")
  if (!is.na(pub_date)) {
    year <- xml_text(xml_find_first(pub_date, "Year"))
    month <- xml_text(xml_find_first(pub_date, "Month"))
    if (!is.na(year)) {
      date_str <- year
      if (!is.na(month)) {
        month_map <- c(Jan="01", Feb="02", Mar="03", Apr="04", May="05", Jun="06",
                      Jul="07", Aug="08", Sep="09", Oct="10", Nov="11", Dec="12")
        month_num <- month_map[month]
        if (is.na(month_num)) month_num <- month
        date_str <- paste(date_str, month_num, sep = "-")
      }
      return(date_str)
    }
  }
  return("Date unknown")
}

infer_study_design <- function(pub_types, title, abstract) {
  # Only return a study design when PubMed has *explicitly* assigned a
  # publication type — no title-based inference. If PubMed hasn't tagged
  # the paper yet (common for brand-new publications), return NA so the
  # display can show a "Not yet tagged" badge rather than a guess.
  pub_types_lower <- tolower(pub_types)

  if ("randomized controlled trial" %in% pub_types_lower) return("RCT")
  if ("meta-analysis" %in% pub_types_lower)               return("Meta-analysis")
  if ("systematic review" %in% pub_types_lower)           return("Systematic review")
  if ("clinical trial" %in% pub_types_lower)              return("Clinical trial")
  if ("multicenter study" %in% pub_types_lower)           return("Multicenter study")
  if ("cohort studies" %in% pub_types_lower)              return("Cohort study")
  if ("observational study" %in% pub_types_lower)         return("Observational study")
  if ("case reports" %in% pub_types_lower)                return("Case report")
  if ("review" %in% pub_types_lower)                      return("Review")
  if ("editorial" %in% pub_types_lower)                   return("Editorial")
  if ("letter" %in% pub_types_lower)                      return("Letter")
  if ("comment" %in% pub_types_lower)                     return("Comment")

  return(NA_character_)   # PubMed hasn't tagged it yet
}

################################################################################
# Category keyword definitions (shared helper)
################################################################################

get_category_keywords <- function() {
  list(
    "Therapeutics & Mechanisms" = c(
      "vedolizumab", "ustekinumab", "risankizumab", "mirikizumab", "guselkumab",
      "tofacitinib", "upadacitinib", "filgotinib", "jak inhibitor", "jak1", "jak2",
      "infliximab", "adalimumab", "golimumab", "certolizumab", "anti-tnf",
      "ozanimod", "etrasimod", "s1p receptor",
      "biologic therapy", "biologic treatment", "biologic agent",
      "induction therapy", "maintenance therapy", "mechanism of action",
      "therapeutic target", "treatment response", "clinical remission"
    ),
    "Biomarkers & Precision Medicine" = c(
      "biomarker", "precision medicine", "personalized medicine",
      "proteomics", "transcriptomics", "metabolomics", "genomics", "multi-omics",
      "cell-free dna", "cfdna", "liquid biopsy",
      "gene expression", "epigenetic", "snp", "polygenic",
      "fecal calprotectin", "crp", "fecal lactoferrin",
      "treat-to-target", "therapeutic drug monitoring"
    ),
    "AI & Machine Learning" = c(
      "machine learning", "deep learning", "neural network", "artificial intelligence",
      "convolutional", "random forest", "natural language processing",
      "computer-aided detection", "automated classification",
      "predictive model", "ai-based", "ai-assisted"
    ),
    "Endoscopy & Imaging" = c(
      "endoscopy", "colonoscopy", "endoscopic remission", "endoscopic healing",
      "mucosal healing", "endoscopic score", "mayo endoscopic",
      "intestinal ultrasound", "bowel ultrasound", "transmural healing",
      "ultrasound", "bowel wall", "echogenicity", "sonographic",
      "mri enterography", "magnetic resonance enterography", "mr enterography",
      "capsule endoscopy", "balloon enteroscopy",
      "histologic remission", "histological remission", "geboes", "nancy index"
    ),
    "Pediatric IBD" = c(
      "pediatric", "paediatric", "children with", "adolescent",
      "very early onset", "veo-ibd", "infantile ibd",
      "childhood-onset", "juvenile", "neonatal",
      "pediatric crohn", "pediatric colitis", "pediatric ibd"
    ),
    "Surgery & Complications" = c(
      "colectomy", "ileostomy", "pouch", "pouchitis", "ipaa",
      "ileal pouch", "resection", "strictureplasty",
      "perianal fistula", "perianal disease", "fistulotomy",
      "surgical resection", "postoperative recurrence",
      "enterocutaneous fistula", "abdominal abscess"
    ),
    "Epidemiology & Outcomes" = c(
      "epidemiology", "incidence", "prevalence",
      "population-based", "registry", "cohort study",
      "real-world evidence", "claims data", "administrative data",
      "natural history", "disease course", "long-term outcomes",
      "hospitalization", "surgery rate", "disability",
      # Healthcare access / disparities
      "health disparit", "disparities", "access to care", "healthcare utilization",
      "socioeconomic", "racial disparit", "ethnic disparit"
    ),
    "Guidelines & Consensus" = c(
      "guideline", "clinical guideline", "consensus statement",
      "position statement", "practice recommendation",
      "expert consensus", "best practice", "ecco guideline",
      "aga guideline", "bsg guideline"
    ),
    "Microbiome & Immunology" = c(
      "microbiome", "microbiota", "dysbiosis", "gut microbiota",
      "fecal transplant", "fmt", "bacteriome", "virome",
      # Probiotic/bacterial species — important so Lactobacillus/probiotic papers
      # that come in via the nutrition query are re-routed here by Fix 2
      "lactobacillus", "bifidobacterium", "bacteroides", "faecalibacterium",
      "probiotic", "prebiotic", "synbiotic",
      "mucosal immunity", "intestinal barrier", "epithelial barrier",
      "innate immunity", "adaptive immunity", "regulatory t cell",
      "th17", "interleukin-", "tnf-alpha", "ifn-gamma"
    ),
    "Nutrition & Lifestyle" = c(
      "exclusive enteral nutrition", "enteral nutrition", "parenteral nutrition",
      "dietary intervention", "nutritional therapy",
      "food intake", "dietary pattern", "mediterranean diet",
      "malnutrition", "nutritional status", "specific carbohydrate diet"
    ),
    "Pregnancy & Reproductive Health" = c(
      "pregnancy", "pregnant", "maternal", "obstetric", "gestational",
      "neonatal outcome", "birth outcome", "preterm", "preeclampsia",
      "fertility", "conception", "miscarriage", "stillbirth",
      "breastfeeding", "lactation", "postpartum",
      "congenital", "fetal", "infant exposure"
    ),
    "Drug Safety & Pharmacovigilance" = c(
      "adverse event", "adverse effect", "side effect", "drug toxicity",
      "safety profile", "tolerability", "pharmacovigilance",
      "post-marketing", "real-world safety",
      "opportunistic infection", "serious infection", "tuberculosis reactivation",
      "malignancy risk", "lymphoma", "non-melanoma skin cancer",
      "hepatotoxicity", "nephrotoxicity", "cardiotoxicity",
      "drug-induced", "iatrogenic", "treatment-related"
    ),
    "IBD-associated Neoplasia" = c(
      "colorectal cancer", "crc", "colitis-associated cancer",
      "colitis-associated neoplasia", "dysplasia", "intraepithelial neoplasia",
      "cancer surveillance", "colonoscopic surveillance", "chromoendoscopy",
      "cancer risk", "neoplastic", "carcinogenesis",
      "indefinite for dysplasia", "low-grade dysplasia", "high-grade dysplasia"
    ),
    "Pathogenesis & Basic Science" = c(
      "epithelial barrier", "tight junction", "intestinal permeability",
      "mucosal barrier", "barrier function",
      "experimental colitis", "dextran sodium sulfate", "dss colitis", "tnbs",
      "mouse model", "animal model", "colitis model",
      "disease mechanism", "pathophysiology", "gut inflammation",
      "oxidative stress", "endoplasmic reticulum stress",
      "autophagy", "apoptosis", "necroptosis", "pyroptosis",
      "unfolded protein response", "er stress"
    ),
    "Genetics & Genomics" = c(
      "genome-wide association", "gwas", "genetic variant", "snp", "polymorphism",
      "nod2", "il23r", "atg16l1", "card9", "card15",
      "genetic susceptibility", "susceptibility locus", "risk locus",
      "polygenic risk score", "pharmacogenomics", "genetic architecture",
      "whole exome sequencing", "whole genome sequencing",
      "epigenetics", "dna methylation", "heritability",
      "mendelian randomization", "gene-environment"
    ),
    "Quality of Life & PROs" = c(
      "quality of life", "health-related quality", "hrqol", "ibdq",
      "patient-reported outcome", "pro-2", "pro instrument",
      "fatigue", "ibd fatigue", "work impairment", "work disability",
      "disability index", "disability score",
      "anxiety", "depression", "psychological", "mental health",
      "patient burden", "caregiver burden", "coping", "resilience",
      "patient experience", "patient perspective"
    ),
    "Extraintestinal Manifestations" = c(
      "extraintestinal manifestation", "extraintestinal complication",
      # Hepatobiliary
      "primary sclerosing cholangitis", "psc-ibd", "hepatobiliary",
      # Ocular — added so Fix 2 can re-assign conjunctival/ocular papers from Surgery
      "uveitis", "episcleritis", "iritis", "ocular manifestation",
      "conjunctival", "anterior uveitis",
      # Dermatological
      "erythema nodosum", "pyoderma gangrenosum", "cutaneous manifestation",
      "cutaneous crohn", "metastatic crohn", "skin manifestation",
      # Musculoskeletal
      "ibd-related arthritis", "ibd arthritis", "spondyloarthropathy",
      "sacroiliitis", "ankylosing spondylitis", "axial spondyloarthritis",
      "peripheral arthritis", "enthesitis"
    )
  )
}

################################################################################
# Categorization fallback (used when query source is unavailable)
################################################################################

categorize_papers <- function(papers) {
  categories <- get_category_keywords()

  priority_weights <- c(
    "AI & Machine Learning"           = 4.0,
    "Pediatric IBD"                   = 4.0,
    "Pregnancy & Reproductive Health" = 4.0,
    "Extraintestinal Manifestations"  = 3.5,
    "Surgery & Complications"         = 3.0,
    "Drug Safety & Pharmacovigilance" = 3.0,
    "IBD-associated Neoplasia"        = 3.0,
    "Nutrition & Lifestyle"           = 3.0,
    "Guidelines & Consensus"          = 2.5,
    "Genetics & Genomics"             = 2.5,
    "Endoscopy & Imaging"             = 2.0,
    "Biomarkers & Precision Medicine" = 2.0,
    "Quality of Life & PROs"          = 2.0,
    "Microbiome & Immunology"         = 2.0,
    "Therapeutics & Mechanisms"       = 1.5,
    "Epidemiology & Outcomes"         = 1.0,
    "Pathogenesis & Basic Science"    = 1.0
  )

  papers %>%
    mutate(
      category = map_chr(seq_len(n()), function(i) {
        text <- tolower(paste(title[i], abstract[i]))
        raw_scores <- map_dbl(categories, function(kws) {
          sum(map_lgl(kws, function(kw) str_detect(text, fixed(kw))))
        })
        weighted_scores <- raw_scores * priority_weights[names(raw_scores)]
        if (max(weighted_scores) > 0) names(categories)[which.max(weighted_scores)] else "General IBD"
      })
    )
}


################################################################################
# Main Fetch Function
################################################################################

fetch_all_papers <- function(days_back = 7) {
  message("Fetching papers from PubMed...")

  queries <- get_search_queries()

  # Maps query group name -> display category name
  category_map <- c(
    therapeutics   = "Therapeutics & Mechanisms",
    biomarkers     = "Biomarkers & Precision Medicine",
    imaging        = "Endoscopy & Imaging",
    ai_digital     = "AI & Machine Learning",
    pediatric      = "Pediatric IBD",
    surgery        = "Surgery & Complications",
    epidemiology   = "Epidemiology & Outcomes",
    guidelines     = "Guidelines & Consensus",
    microbiome     = "Microbiome & Immunology",
    nutrition      = "Nutrition & Lifestyle",
    extraintestinal= "Extraintestinal Manifestations",
    genetics       = "Genetics & Genomics",
    quality_of_life= "Quality of Life & PROs",
    pregnancy      = "Pregnancy & Reproductive Health",
    drug_safety    = "Drug Safety & Pharmacovigilance",
    neoplasia      = "IBD-associated Neoplasia",
    pathogenesis   = "Pathogenesis & Basic Science"
  )

  # When a paper matches multiple query groups, assign the most specific category.
  # Pathogenesis is intentionally low-priority — it's the broadest scientific
  # category and should only win when nothing more specific applies.
  category_priority <- c(
    "AI & Machine Learning"           = 17,
    "Pediatric IBD"                   = 16,
    "Pregnancy & Reproductive Health" = 15,
    "Extraintestinal Manifestations"  = 14,
    "Surgery & Complications"         = 13,
    "Drug Safety & Pharmacovigilance" = 12,
    "IBD-associated Neoplasia"        = 11,
    "Nutrition & Lifestyle"           = 10,
    "Guidelines & Consensus"          =  9,
    "Genetics & Genomics"             =  8,
    "Endoscopy & Imaging"             =  7,
    "Biomarkers & Precision Medicine" =  6,
    "Quality of Life & PROs"          =  5,
    "Microbiome & Immunology"         =  4,
    "Therapeutics & Mechanisms"       =  3,
    "Epidemiology & Outcomes"         =  2,
    "Pathogenesis & Basic Science"    =  1
  )

  # Collect PMIDs per query group, preserving source
  pmid_categories <- list()   # pmid -> character vector of matched categories
  total_queries   <- sum(lengths(queries))
  query_count     <- 0

  for (group_name in names(queries)) {
    display_cat <- category_map[[group_name]]
    for (query in queries[[group_name]]) {
      query_count <- query_count + 1
      message(glue("  [{query_count}/{total_queries}] Searching ({display_cat})..."))
      pmids <- search_pubmed(query, days_back = days_back, max_results = 50)
      for (pmid in pmids) {
        pmid_categories[[pmid]] <- unique(c(pmid_categories[[pmid]], display_cat))
      }
      Sys.sleep(0.5)
    }
  }

  all_pmids <- names(pmid_categories)
  message(glue("Found {length(all_pmids)} unique papers"))

  if (length(all_pmids) == 0) return(tibble())

  message("Fetching paper details...")
  papers <- fetch_paper_details(all_pmids)

  # Assign category: use the highest-priority query group that found each paper
  message("Assigning categories from query source...")
  source_categories <- map_chr(papers$pmid, function(pmid) {
    cats <- pmid_categories[[pmid]]
    if (is.null(cats) || length(cats) == 0) return("General IBD")
    if (length(cats) == 1) return(cats)
    cats[which.max(category_priority[cats])]
  })

  papers <- papers %>%
    mutate(category = source_categories)

  # ── Fix 1: Soft IBD relevance filter ────────────────────────────────────────
  # Drop papers where neither title nor full abstract contain any IBD term.
  # This removes off-topic papers captured incidentally by broad queries
  # (e.g. a gynaecological cancer paper matched by the nutrition query).
  ibd_terms <- c(
    "inflammatory bowel disease", "ibd", "crohn", "ulcerative colitis",
    "colitis", "ileitis", "ileocolitis"
  )
  n_before <- nrow(papers)
  papers <- papers %>%
    filter(map_lgl(seq_len(n()), function(i) {
      text <- tolower(paste(title[i], abstract[i]))
      any(map_lgl(ibd_terms, ~str_detect(text, fixed(.x))))
    }))
  n_removed <- n_before - nrow(papers)
  if (n_removed > 0) message(glue("Removed {n_removed} off-topic paper(s) after IBD relevance check"))

  # ── Fix 2: Title-based category verification ────────────────────────────────
  # If the assigned category has zero keyword hits in the paper title,
  # re-score using the title alone and reassign if a better match is found.
  # This corrects cases like "mucosal healing" in a basic-science review title
  # landing it in Endoscopy, or "guideline" in a translation methods section
  # landing an EIM paper in Guidelines & Consensus.
  category_kws <- get_category_keywords()

  papers <- papers %>%
    mutate(category = map_chr(seq_len(n()), function(i) {
      assigned  <- category[i]
      title_txt <- tolower(title[i])
      kws       <- category_kws[[assigned]]

      # If any keyword for the assigned category appears in the title, keep it
      if (!is.null(kws) && any(map_lgl(kws, ~str_detect(title_txt, fixed(.x))))) {
        return(assigned)
      }

      # Title doesn't support the assigned category — re-score title only
      title_scores <- map_dbl(category_kws, function(kws2) {
        sum(map_lgl(kws2, ~str_detect(title_txt, fixed(.x))))
      })

      if (max(title_scores) > 0) {
        names(category_kws)[which.max(title_scores)]
      } else {
        assigned  # no title signal at all — keep query-source assignment
      }
    }))

  # ── Fix 3: Strong-signal drug-name override → Therapeutics ──────────────────
  # If a paper's title contains a specific biologic, small-molecule, or
  # immunomodulator name it should always land in Therapeutics regardless of
  # which query originally retrieved it (e.g. a JAK inhibitor trial retrieved by
  # the EIM query because arthritis was mentioned).
  strong_therapeutic_drugs <- c(
    "vedolizumab", "ustekinumab", "risankizumab", "mirikizumab", "guselkumab",
    "tofacitinib", "upadacitinib", "filgotinib",
    "infliximab", "adalimumab", "golimumab", "certolizumab",
    "ozanimod", "etrasimod",
    "thiopurine", "azathioprine", "mercaptopurine", "6-thioguanine", "6-mp",
    "methotrexate", "ciclosporin", "tacrolimus",
    "jak inhibitor", "jak1", "jak2",
    "anti-tnf", "tnf inhibitor",
    # Non-biologic drugs that belong in Therapeutics when used in IBD context
    "metformin", "mesalamine", "mesalazine", "budesonide", "prednisolone",
    "prednisone", "corticosteroid", "5-aminosalicylate"
  )

  papers <- papers %>%
    mutate(category = map_chr(seq_len(n()), function(i) {
      title_lower <- tolower(title[i])
      if (any(map_lgl(strong_therapeutic_drugs, ~str_detect(title_lower, fixed(.x))))) {
        return("Therapeutics & Mechanisms")
      }
      return(category[i])
    }))

  # ── Fix 4: Strong-signal microbiome override ────────────────────────────────
  # Probiotic / bacterial-species papers retrieved by the nutrition query should
  # land in Microbiome & Immunology, not Nutrition & Lifestyle.
  strong_microbiome_signals <- c(
    "lactobacillus", "bifidobacterium", "bacteroides", "faecalibacterium",
    "akkermansia", "clostridium", "ruminococcus",
    "probiotic", "prebiotic", "synbiotic",
    "fecal transplant", "fmt", "gut microbiome", "gut microbiota"
  )

  papers <- papers %>%
    mutate(category = map_chr(seq_len(n()), function(i) {
      if (category[i] == "Nutrition & Lifestyle") {
        title_lower <- tolower(title[i])
        if (any(map_lgl(strong_microbiome_signals, ~str_detect(title_lower, fixed(.x))))) {
          return("Microbiome & Immunology")
        }
      }
      return(category[i])
    }))

  # ── Fix 5: Manual overrides from CSV ────────────────────────────────────────
  # If data/overrides.csv exists, apply any manual category corrections.
  # This creates a permanent feedback loop: wrong categorisations get fixed once
  # in the CSV and stay fixed in all future runs.
  overrides_file <- "data/overrides.csv"
  if (file.exists(overrides_file)) {
    overrides <- read_csv(overrides_file, show_col_types = FALSE) %>%
      filter(!is.na(pmid), !is.na(correct_category), correct_category != "")
    if (nrow(overrides) > 0) {
      papers <- papers %>%
        left_join(overrides %>% select(pmid, correct_category), by = "pmid") %>%
        mutate(category = if_else(!is.na(correct_category), correct_category, category)) %>%
        select(-correct_category)
      message(glue("Applied {nrow(overrides)} manual override(s) from {overrides_file}"))
    }
  }

  papers <- papers %>%
    arrange(category, desc(publication_date))

  message(glue("Successfully processed {nrow(papers)} papers"))
  return(papers)
}

################################################################################
# RSS Feed Generation
################################################################################

make_rss_items <- function(papers_subset) {
  design_str <- if_else(
    !is.na(papers_subset$study_design),
    paste0(papers_subset$study_design, " - "),
    ""
  )
  papers_subset %>%
    mutate(
      item_xml = glue('
    <item>
      <title><![CDATA[{title}]]></title>
      <link>{url}</link>
      <description><![CDATA[{journal} — {design_str}{str_trunc(abstract, 200)}]]></description>
      <pubDate>{format(Sys.Date(), "%a, %d %b %Y 07:00:00 GMT")}</pubDate>
      <category>{category}</category>
    </item>')
    ) %>%
    pull(item_xml) %>%
    paste(collapse = "\n")
}

write_rss <- function(items_xml, title, description, output_file) {
  rss_xml <- glue('<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>{title}</title>
    <link>https://dahhamalsoud.github.io/ibd-litmonitor</link>
    <description>{description}</description>
    <language>en-us</language>
    <lastBuildDate>{format(Sys.Date(), "%a, %d %b %Y 07:00:00 GMT")}</lastBuildDate>

{items_xml}

  </channel>
</rss>')
  dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)
  writeLines(rss_xml, output_file)
}

generate_rss_feed <- function(papers, output_dir = "docs") {
  # ── Main feed: top 3 papers per category, max 20 total ──────────────────────
  top_papers <- papers %>%
    arrange(category, desc(publication_date)) %>%
    group_by(category) %>%
    slice_head(n = 3) %>%
    ungroup() %>%
    slice_head(n = 20)

  write_rss(
    items_xml   = make_rss_items(top_papers),
    title       = "IBD LitMonitor",
    description = "Weekly IBD literature monitoring — organized by clinical subfield",
    output_file = file.path(output_dir, "rss.xml")
  )
  message(glue("RSS feed generated: {output_dir}/rss.xml"))

  # ── Per-category feeds ───────────────────────────────────────────────────────
  # Researchers who only care about one subfield can subscribe to just that feed.
  rss_dir <- file.path(output_dir, "rss")
  dir.create(rss_dir, recursive = TRUE, showWarnings = FALSE)

  categories <- unique(papers$category)
  for (cat in categories) {
    cat_papers <- papers %>%
      filter(category == cat) %>%
      arrange(desc(publication_date))
    # Sanitise category name for use as filename
    cat_slug <- tolower(cat) %>%
      str_replace_all("[^a-z0-9]+", "_") %>%
      str_replace_all("_+$", "")
    write_rss(
      items_xml   = make_rss_items(cat_papers),
      title       = glue("IBD LitMonitor — {cat}"),
      description = glue("Weekly IBD literature: {cat}"),
      output_file = file.path(rss_dir, glue("{cat_slug}.xml"))
    )
  }
  message(glue("Per-category RSS feeds generated: {rss_dir}/"))
}

################################################################################
# Data Caching
################################################################################

save_cache <- function(papers) {
  dir.create("data_cache", showWarnings = FALSE)
  saveRDS(papers, "data_cache/papers.rds")
  saveRDS(list(timestamp = Sys.time()), "data_cache/metadata.rds")
  write_json(papers, "data_cache/papers.json", pretty = TRUE, auto_unbox = TRUE)
}

load_cache <- function(max_age_hours = 24) {
  cache_file <- "data_cache/papers.rds"
  meta_file <- "data_cache/metadata.rds"
  
  if (file.exists(cache_file) && file.exists(meta_file)) {
    meta <- readRDS(meta_file)
    age_hours <- as.numeric(difftime(Sys.time(), meta$timestamp, units = "hours"))
    
    if (age_hours < max_age_hours) {
      message(glue("Using cached data ({round(age_hours, 1)} hours old)"))
      return(readRDS(cache_file))
    }
  }
  
  return(NULL)
}

get_papers <- function(days_back = 7, use_cache = TRUE) {
  if (use_cache) {
    cached <- load_cache()
    if (!is.null(cached)) {
      # ── Cache compatibility: backfill columns added in later versions ──────
      # 'flagship' column — added when flagship journal detection was introduced.
      # Recompute it from the journal column rather than forcing a full re-fetch.
      if (!"flagship" %in% names(cached)) {
        flagship_journals <- c(
          "gut", "gastroenterology",
          "the lancet", "lancet",
          "lancet gastroenterology", "lancet gastroenterology & hepatology",
          "new england journal of medicine", "the new england journal of medicine",
          "journal of crohn's and colitis", "journal of crohn's & colitis",
          "inflammatory bowel diseases",
          "clinical gastroenterology and hepatology",
          "alimentary pharmacology & therapeutics",
          "alimentary pharmacology and therapeutics",
          "nature medicine", "nature",
          "jama", "jama internal medicine",
          "annals of internal medicine",
          "united european gastroenterology journal"
        )
        cached <- cached %>%
          mutate(flagship = tolower(journal) %in% flagship_journals)
        message("Backfilled 'flagship' column from cached journal names")
      }
      return(cached)
    }
  }

  papers <- fetch_all_papers(days_back)
  save_cache(papers)
  return(papers)
}
