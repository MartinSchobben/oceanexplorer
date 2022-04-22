#' NOAA plot module
#'
#' @param id Namespace id shiny module.
#' @param NOAA Reactive value of NOAA dataset.
#' @param points Add locations of extracted point geometry.
#'
#' @return Shiny module.
#' @export
plot_ui <- function(id) {
  tagList(
    selectInput(
      NS(id, "epsg"),
      h5("EPSG"),
      c("original", "4326", "3031", "3995"),
      selected = "original"
    ),
    plotOutput(
      NS(id,  "plot"),
      click = NS(id, "plot_click")
    ),
    sliderInput(
      NS(id, "depth"),
      h5("depth (meter)"),
      min = 0,
      max = 3000,
      value = 0,
      width = "100%"
    ),
    tags$caption(
      "Variable averaged over a time span ranging from 1955 to 2017."
    )
  )
}
#' @rdname plot_ui
#'
#' @export
plot_server <- function(id, NOAA, points) {

  # check for reactive
  stopifnot(is.reactive(NOAA))
  stopifnot(is.reactive(points))

  moduleServer(id, function(input, output, session) {

    # initiated selected coordinate
    selected <- reactiveValues(lon = NULL, lat = NULL, depth = NULL)

    # plot
    output$plot <- renderPlot({

      req(NOAA)
      req(input$epsg)

      plot_NOAA(
        NOAA(),
        depth = input$depth,
        points = points(),
        epsg = input$epsg
      )

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
