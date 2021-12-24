#' NOAA plot module
#'
#' @param id Namespace id shiny module.
#' @param NOAA Reactive value of NOAA dataset.
#'
#' @return Shiny module.
#' @export
plot_ui <- function(id) {tagList(plotOutput(NS(id,  "plot")))}
#' @rdname plot_ui
#'
#' @export
plot_server <- function(id, NOAA) {

  # check for reactive
  stopifnot(is.reactive(NOAA))

  moduleServer(id, function(input, output, session) {
    output$plot <- renderPlot(plot_NOAA(NOAA()))
  })
}
