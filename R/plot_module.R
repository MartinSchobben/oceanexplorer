#' NOAA plot module
#'
#' @param id Namespace id shiny module.
#' @param NOAA Reactive value of NOAA dataset.
#'
#' @return Shiny module.
#' @export
plot_ui <- function(id) {
  tagList(
    plotOutput(NS(id,  "plot")),
    tags$caption("Variable averaged over a time span ranging from 1955 to 2017.")
  )
}
#' @rdname plot_ui
#'
#' @export
plot_server <- function(id, NOAA, points, reset) {

  # check for reactive
  stopifnot(is.reactive(NOAA))
  stopifnot(is.reactive(points))

  moduleServer(id, function(input, output, session) {

    coord <- reactiveVal(NULL)

    # update output coordinates
    observeEvent(points(), {
      req(points())
      if (is.null(coord())) {
        coord(points())
      } else {
        coord(dplyr::rows_upsert(coord(), points(), by = c("depth", "geometry")))
      }
    })

    # reset
    observeEvent(reset(), {
      req(reset())
      coord(NULL)
    })

    output$plot <- renderPlot({

      plot_NOAA(NOAA(), coord())

    })
  })
}

