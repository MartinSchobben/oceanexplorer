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
    plotOutput(NS(id,  "plot"), click = NS(id, "plot_click")),
    tags$caption("Variable averaged over a time span ranging from 1955 to 2017.")
  )
}
#' @rdname plot_ui
#'
#' @export
plot_server <- function(id, NOAA, points, back, reset, depth_slider) {

  # check for reactive
  stopifnot(is.reactive(NOAA))
  stopifnot(is.reactive(points))
  stopifnot(is.reactive(back))
  stopifnot(is.reactive(reset))

  moduleServer(id, function(input, output, session) {

    # initiate
    coord <- reactiveVal(NULL)
    selected <- reactiveValues(lon = NULL, lat = NULL)


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
      selected$lon <- NULL
      selected$lat <- NULL
      coord(NULL)
    })

    # plot
    output$plot <- renderPlot({
      plot_NOAA(NOAA(), coord())
    })

    # store clicked points
    observeEvent(input$plot_click, {
      # if selected are null then initiated otherwise append
      if (all(sapply(reactiveValuesToList(selected), is.null))) {
        selected$lon <- input$plot_click$x
        selected$lat <- input$plot_click$y
      } else {
        selected$lon <- append(reactiveValuesToList(selected)$lon, input$plot_click$x)
        selected$lat <- append(reactiveValuesToList(selected)$lat, input$plot_click$y)
      }
    })

    # if depth slides and coords plot selection are changed reset the external input
    observeEvent(depth_slider(), { #{message(glue::glue("{depth_slider()}"))})
      selected$lon <- NULL
      selected$lat <- NULL
    })


    # return
    selected
  })
}

