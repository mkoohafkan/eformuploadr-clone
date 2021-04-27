#' Shiny Server
#'
#' Server for shiny app.
#'
#' @import shiny
#' @importFrom wqpr frm_read frm_format frm_insert frm_check
#' @importFrom autowqp process_form
#' @keywords internal
server = function(input, output, session) {
  database = getOption("wqpr.database")
  program = getOption("wqpr.program")
  if (!is.null(database)) {
    token = getOption("wqpr.token")[[database]]
  } else {
    token = NULL
  }

  # write settings to interface
  if (!is.null(database)) {
    updateRadioButtons(session, "database", selected = database)
  }
  if (!is.null(program)) {
    updateRadioButtons(session, "program", selected = program)
  }
  if (!is.null(token)) {
    updateTextInput(session, "token", value = token)
  }

  observeEvent(input$process, {
    database = isolate(input$database)
    program = isolate(input$program)
    token = isolate(input$token)
    overwrite = isolate(input$overwrite)
    form = isolate(input$form$datapath)
    if (!nzchar(token)) {
      token = NULL
    }
    showModal(modalDialog("Processing form, please wait...",
      footer = NULL))
    tf = tryCatch(
      eval_form(form, overwrite, program, database, token),
      error = catch_error
    )
    removeModal()
    output$console = renderText({
      paste(readLines(tf), collapse = "\n")
    })
  })
  observe({
  if (input$quit)
    stopApp()
  })
}

# catch error
catch_error = function(e) {
  tf = tempfile()
  cat(e$message, file = tf)
  tf
}

# process form
eval_form = function(form.path, overwrite, program, database, token) {
  if (is.null(form.path)) {
    return(NULL)
  }
  tf = tempfile()
  cat("reading form...\n", file = tf, append = TRUE)
  form.data = frm_read(form.path)
  if (!form.data$completed) {
    cat(form.data$log[[1]], sep = "\n", file = tf, append = TRUE)
    return(tf)
  }
  ## TEMP
#  if (form.data$event[[1]]$event_type_name != "Visit") {
#    form.data = autowqp:::translate_metadata(form.data)
#  }
  ## END TEMP
  cat("validating form...\n", file = tf, append = TRUE)
  d.format = frm_format(form.data, na.omit = TRUE,
    program = program, database = database)
  if (!d.format$validated) {
    cat(d.format$log[[1]], sep = "\n", file = tf, append = TRUE)
    return(tf)
  }
  cat("checking form...\n", file = tf, append = TRUE)
  d.checked = frm_check(d.format, program = program,
        database = database)
  if (!(d.checked$unique || overwrite)) {
    cat(d.checked$log[[1]], sep = "\n", file = tf, append = TRUE)
    return(tf)
  }
  if (is.null(token)) {
    cat("Skipping form insert.\n", file = tf, append = TRUE)
    return(tf)
  }
  cat("inserting form...\n", file = tf, append = TRUE)
  d.insert = frm_insert(d.checked, overwrite = overwrite,
    program = program, database = database, token = token)
  if (!d.insert$inserted) {
    cat(d.insert$log[[1]], sep = "\n", file = tf, append = TRUE)
    return(tf)
  }
  cat("Form data inserted successfully. Form can now be archived.\n",
    file = tf, append = TRUE)
  return(tf)
}
