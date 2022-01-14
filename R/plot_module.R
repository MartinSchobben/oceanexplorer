#' NOAA plot module
#'
#' @param id Namespace id shiny module.
#' @param NOAA Reactive value of NOAA dataset.
#' @param points Add locations of extracted point geometry.
#' @param back Reactive value for back button.
#' @param reset Reactive value for reset button.
#' @param depth_slider Reactive value for slider for ocean depth.
#'
#' @return Shiny module.
#' @export
plot_ui <- function(id) {
  tagList(
    tags$br(),
    plotOutput(NS(id,  "plot"), click = NS(id, "plot_click")),
    sliderInput(
      NS(id, "depth"),
      h5("depth (meter)"),
      min = 0,
      max = 3000,
      value = 0,
      width = "100%"
    ),
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

    # initiate saved coords
    coord <- reactiveVal(NULL)
    # initiated selected coords
    selected <- reactiveValues(lon = NULL, lat = NULL, depth = NULL)
    observe({selected$depth <- input$depth})

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
      coord(dplyr::add_row(coord(), tail(coord(), 1)))
    })

    # reset
    observeEvent(reset(), {
      req(reset())
      selected$lon <- NULL
      selected$lat <- NULL
      selected$depth <- NULL
      coord(NULL)
    })

    # plot
    output$plot <- renderPlot({
      plot_NOAA(NOAA(), coord())
    })

    # store clicked points
    observeEvent(input$plot_click, {
      if (is.null(selected$lon) & is.null(selected$lon)) {
        selected$lon <- input$plot_click$x
        selected$lat <- input$plot_click$y
      } else {
        selected$lon <- append(reactiveValuesToList(selected)$lon, input$plot_click$x)
        selected$lat <- append(reactiveValuesToList(selected)$lat, input$plot_click$y)
      }
    })

    # if depth slide and coordinate plot selection are changed reset the external input
    # depth is not reset as we need a 2D surface for the plot
    observeEvent(input$slide, {
      selected$lon <- NULL
      selected$lat <- NULL
    })

    # return `reactivevalues`
    selected
  })
}

