#' NOAA plot module
#'
#' @param id Namespace id shiny module.
#' @param NOAA Reactive value of NOAA dataset.
#' @param points Add locations of extracted point geometry.
#' @param back Reactive value for back button.
#' @param reset Reactive value for reset button.
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
plot_server <- function(id, NOAA, points, back, reset) {

  # check for reactive
  stopifnot(is.reactive(NOAA))
  stopifnot(is.reactive(points))
  stopifnot(is.reactive(back))
  stopifnot(is.reactive(reset))

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

    # back
    observeEvent(back(), {
      req(back())
      coord(dplyr::rows_delete(coord(), tail(coord(), 1), by = colnames(coord())))
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

