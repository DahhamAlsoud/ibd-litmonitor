################################################################################
# IBD LitMonitor - Interactive Dashboard
################################################################################

library(shiny)
library(bslib)
library(tidyverse)
library(DT)
library(plotly)

# Load papers data
if (file.exists("papers.rds")) {
  papers_data <- readRDS("papers.rds")
} else if (file.exists("../data_cache/papers.rds")) {
  papers_data <- readRDS("../data_cache/papers.rds")
} else {
  papers_data <- tibble()
}

ui <- page_sidebar(
  title = "IBD LitMonitor Dashboard",
  theme = bs_theme(
    bg = "#ffffff",
    fg = "#2c3e50",
    primary = "#8b3a1e",
    base_font = font_google("Inter"),
    heading_font = font_google("Fraunces")
  ),

  sidebar = sidebar(
    width = 320,

    h4("Filter Papers"),

    hr(),

    selectInput(
      "category_filter",
      "Category:",
      choices = c("All" = "all", sort(unique(papers_data$category))),
      selected = "all"
    ),


    selectInput(
      "time_window",
      "Time window:",
      choices = c(
        "Past 7 days"  = 7,
        "Past 2 weeks" = 14,
        "Past 3 weeks" = 21,
        "Past 30 days" = 30
      ),
      selected = 7
    ),

    selectInput(
      "drug_filter",
      "Drug / Target:",
      choices = c(
        "All" = "all",
        "Vedolizumab" = "vedolizumab",
        "Ustekinumab" = "ustekinumab",
        "Risankizumab" = "risankizumab",
        "Mirikizumab" = "mirikizumab",
        "Guselkumab" = "guselkumab",
        "JAK inhibitors (tofacitinib / upadacitinib / filgotinib)" = "tofacitinib|upadacitinib|filgotinib|jak inhibitor|jak1|jak2",
        "Anti-TNF (infliximab / adalimumab / golimumab)" = "infliximab|adalimumab|golimumab|certolizumab|anti-tnf",
        "S1P (ozanimod / etrasimod)" = "ozanimod|etrasimod|s1p receptor"
      ),
      selected = "all"
    ),

    textInput(
      "keyword_search",
      "Keywords:",
      placeholder = "Search titles/abstracts..."
    ),

    hr(),

    downloadButton("download_csv", "Download CSV", class = "btn-sm w-100 mb-2"),
    downloadButton("download_bibtex", "Download BibTeX", class = "btn-sm w-100")
  ),

  navset_card_tab(

    nav_panel(
      "Papers",

      layout_columns(
        value_box(
          title = "Filtered Papers",
          value = textOutput("filtered_papers"),
          theme = "primary",
          showcase = icon("filter")
        ),
        value_box(
          title = "Categories",
          value = textOutput("categories_count"),
          theme = "warning",
          showcase = icon("tags")
        )
      ),

      hr(),

      uiOutput("papers_list")
    ),

    nav_panel(
      "Analytics",

      h4("Papers by Category"),
      plotlyOutput("category_plot", height = "350px"),

      hr(),

      card(
        card_header("Publication Timeline"),
        plotlyOutput("timeline_plot", height = "300px")
      ),

      hr(),

      card(
        card_header("Top Journals by Paper Count"),
        plotlyOutput("journal_plot", height = "300px")
      )
    ),

    nav_panel(
      "Table View",
      DTOutput("papers_table")
    ),

    nav_panel(
      "About",

      card(
        card_header("How This Dashboard Works"),

        markdown("
### IBD LitMonitor

Weekly coverage of IBD literature organized into clinical subfields — so you can browse what's relevant to you without wading through everything else.

**Why not just use PubMed alerts?**
PubMed alerts deliver an unordered raw feed with no grouping, no deduplication across overlapping queries, and no weekly overview. IBD LitMonitor runs 27 targeted queries, deduplicates results, and organizes papers into 11 clinical subfields.

---

### Filters Available

**Category:** Browse by clinical subfield (Therapeutics, Biomarkers, Pediatric IBD, etc.)

**Study Design:** Filter by RCT, meta-analysis, cohort study, review, etc.

**Date Range:** Narrow to a specific publication window.

**Keywords:** Search across titles and abstracts.

---

Created by **Dahham Alsoud**
        ")
      )
    )
  )
)

server <- function(input, output, session) {

  filtered_data <- reactive({
    data <- papers_data

    if (nrow(data) == 0) return(data)

    if (input$category_filter != "all") {
      data <- data %>% filter(category == input$category_filter)
    }

    cutoff <- Sys.Date() - as.integer(input$time_window)
    data <- data %>%
      filter(as.Date(publication_date) >= cutoff)

    # Drug / target filter (searches across all categories)
    if (input$drug_filter != "all") {
      pattern <- input$drug_filter
      data <- data %>%
        filter(
          str_detect(tolower(title), pattern) |
          str_detect(tolower(abstract), pattern)
        )
    }

    if (input$keyword_search != "") {
      keyword <- tolower(input$keyword_search)
      data <- data %>%
        filter(
          str_detect(tolower(title), keyword) |
          str_detect(tolower(abstract), keyword)
        )
    }

    data %>% arrange(category, desc(publication_date))
  })

  output$filtered_papers <- renderText({ nrow(filtered_data()) })

  output$categories_count <- renderText({
    filtered_data() %>% distinct(category) %>% nrow()
  })

  output$papers_list <- renderUI({
    papers <- filtered_data() %>% slice_head(n = 50)

    if (nrow(papers) == 0) {
      return(div(
        class = "alert alert-info",
        h5("No papers match your filters"),
        p("Try adjusting the filter criteria above.")
      ))
    }

    paper_cards <- lapply(1:nrow(papers), function(i) {
      paper <- papers[i, ]

      div(
        class = "paper-card",

        h5(paper$title),

        p(strong("Journal:"), " ", paper$journal),
        p(class = "paper-meta",
          paper$authors, br(),
          "Published: ", paper$publication_date, " | ",
          "Category: ", paper$category
        ),

        if (!is.na(paper$doi) && paper$doi != "") {
          p("DOI: ", tags$a(href = glue::glue("https://doi.org/{paper$doi}"),
                           target = "_blank", paper$doi))
        },
        p(tags$a(href = paper$url, target = "_blank", class = "btn btn-sm btn-primary",
                 "View on PubMed →"))
      )
    })

    if (nrow(papers) == 50) {
      paper_cards <- c(
        paper_cards,
        list(div(class = "alert alert-warning", "Showing first 50 results. Use filters to narrow down."))
      )
    }

    div(paper_cards)
  })

  output$category_plot <- renderPlotly({
    filtered_data() %>%
      count(category, sort = TRUE) %>%
      plot_ly(
        x = ~n,
        y = ~reorder(category, n),
        type = "bar",
        orientation = "h",
        marker = list(color = "#8b3a1e"),
        text = ~n,
        textposition = "outside"
      ) %>%
      layout(
        title = "Papers by Category",
        xaxis = list(title = "Number of Papers"),
        yaxis = list(title = ""),
        margin = list(l = 200)
      )
  })

  output$journal_plot <- renderPlotly({
    filtered_data() %>%
      count(journal, sort = TRUE) %>%
      slice_head(n = 10) %>%
      plot_ly(
        labels = ~journal,
        values = ~n,
        type = "pie",
        marker = list(colors = colorRampPalette(c("#8b3a1e", "#e8927c"))(10)),
        textinfo = "label+value"
      ) %>%
      layout(title = "Top 10 Journals")
  })

  output$timeline_plot <- renderPlotly({
    filtered_data() %>%
      mutate(pub_date = as.Date(publication_date)) %>%
      filter(!is.na(pub_date)) %>%
      count(pub_date) %>%
      plot_ly(
        x = ~pub_date,
        y = ~n,
        type = "scatter",
        mode = "lines+markers",
        line = list(color = "#8b3a1e"),
        marker = list(color = "#8b3a1e")
      ) %>%
      layout(
        title = "Publication Timeline",
        xaxis = list(title = ""),
        yaxis = list(title = "Papers per Day")
      )
  })

  output$papers_table <- renderDT({
    filtered_data() %>%
      select(
        Category = category,
        Title = title,
        Journal = journal,
        Date = publication_date,
        Authors = authors
      ) %>%
      datatable(
        options = list(
          pageLength = 25,
          dom = 'Bfrtip',
          order = list(list(0, 'asc'), list(3, 'desc'))
        ),
        filter = "top",
        rownames = FALSE
      )
  })

  output$download_csv <- downloadHandler(
    filename = function() glue::glue("ibd_papers_{Sys.Date()}.csv"),
    content = function(file) write_csv(filtered_data(), file)
  )

  output$download_bibtex <- downloadHandler(
    filename = function() glue::glue("ibd_papers_{Sys.Date()}.bib"),
    content = function(file) {
      bibtex <- filtered_data() %>%
        mutate(
          year = str_extract(publication_date, "^\\d{4}"),
          entry = glue::glue("@article{{{pmid},
  title = {{{title}}},
  author = {{{authors}}},
  journal = {{{journal}}},
  year = {{{year}}},
  doi = {{{doi}}},
  url = {{{url}}}
}}

")
        )
      writeLines(bibtex$entry, file)
    }
  )
}

shinyApp(ui, server)
