#' NOAA plot module
#'
#' @param id Namespace id shiny module.
#' @param NOAA Reactive value of NOAA dataset.
#' @param points Add locations of extracted point geometry.
#' @param epsg The coordinate reference system for plotting.
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
plot_server <- function(id, NOAA, points, epsg) {

  # check for reactive
  stopifnot(is.reactive(NOAA))
  stopifnot(is.reactive(points))
  stopifnot(is.reactive(epsg))

  moduleServer(id, function(input, output, session) {

    # initiated selected coordinate
    selected <- reactiveValues(lon = NULL, lat = NULL, depth = NULL)

    # plot
    output$plot <- renderPlot({
      req(NOAA())
      req(epsg())
      plot_NOAA(NOAA(), points = points(), epsg = epsg())
    })

    observe({
      selected$depth <- input$depth
      selected$lon <- input$plot_click$x
      selected$lat <- input$plot_click$y
      })

    # return `reactivevalues`
    selected
  })
}

