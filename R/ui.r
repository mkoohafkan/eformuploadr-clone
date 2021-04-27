#' Shiny UI
#'
#' UI for shiny app.
#'
#' @import shiny
#' @keywords internal
ui = fluidPage(
  titlePanel("Electronic Form Processor"),
  sidebarLayout(
    sidebarPanel(
      radioButtons("database", "Database", c("Production", "Development"),
        inline = TRUE),
      radioButtons("program", "Program", c("Marsh", "EMP"),
        inline = TRUE),
      passwordInput("token", "Token"),
      checkboxInput("overwrite", "Overwrite existing data?", value = FALSE),
      fileInput("form", "Electronic Form", FALSE, ".xlsx"),
      fluidRow(
        column(6,
          actionButton("process", "Process form"),
        ),
        column(6,
          actionButton("quit", "Quit", value = TRUE),
          align = 'right'
        )
      ),
    ),
    mainPanel(
      verbatimTextOutput('console')
    )
  )
)

