#' @include server.r
#' @include ui.r
NULL

#' @keywords internal
shiny_app = shinyApp(ui, server)

#' Electronic Form Uploader
#'
#' Start the form upload application.
#'
#' @import shiny
#' @export
eform_app = function() {
  runApp(shiny_app)
}

