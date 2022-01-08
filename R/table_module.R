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
table_server <- function(id, NOAA, reset) {

  # check for reactive
  stopifnot(is.reactive(NOAA))

  moduleServer(id, function(input, output, session) {

    obs <- reactiveVal(NULL)

    # update output table
    observeEvent(NOAA(), {
      req(NOAA())
      if (is.null(obs())) {
        obs(NOAA())
      } else {
        obs(dplyr::rows_upsert(obs(), NOAA(), by = c("depth", "coordinates")))
      }
    })

    # reset table
    observeEvent(reset(), {
      req(reset())
      obs(NULL)
    })

    output$table <- renderTable({obs()})
  })
}
