#' NOAA table module
#'
#' @param id Namespace id shiny module.
#' @param NOAA Reactive value of NOAA dataset.
#'
#' @return Shiny module.
#' @export
table_ui <- function(id) {
  tagList(
    tags$br(),
    tags$br(),
    tableOutput(NS(id,  "table"))
  )
}
#' @rdname plot_ui
#'
#' @export
table_server <- function(id, NOAA) {

  # check for reactive
  stopifnot(is.reactive(NOAA))

  moduleServer(id, function(input, output, session) {

    obs <- reactiveVal(tibble(NULL))

    # update output table
    observe({
      req(NOAA())
      if (nrow(obs()) == 0) {
        obs(NOAA())
      } else {
        obs(dplyr::rows_upsert(obs(), NOAA(), by = c("depth", "coordinates")))
      }
    })

    output$table <- renderTable({obs()})
  })
}
