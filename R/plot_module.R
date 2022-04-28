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
    fluidRow(
      column(
        width = 6,
        selectInput(
          NS(id, "epsg"),
          h5("EPSG"),
          c("original", "4326", "3031", "3995"),
          selected = "original"
        ),
        actionLink(
          NS(id, "epsghelper"),
          "",
          icon = icon('question-circle')
        )
      ),
      column(
        width = 6,

        shinyWidgets::materialSwitch(
          NS(id, "fixed"),
          h5("Fix variable scale")
        ),
        actionLink(
          NS(id, "fixedhelper"),
          "",
          icon = icon('question-circle')
        )
      )
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

      # coordinates (convert to meters for stereographic projections)
      if (req(input$epsg) == "3031" | input$epsg == "3995") {
        pts <- sf::st_transform(points(), crs = as.numeric(input$epsg))
      } else {
        pts <- points()
      }

      # fixed oceanographic variable scale or adapted to depth slice
      if (!isTruthy(input$fixed)) {
        NOAA <- NOAA()
        depth <- input$depth
        rng <- NULL
      } else {
        NOAA <- filter_NOAA(NOAA(), depth = input$depth)
        depth <- NULL
        rng <- range(NOAA[[1]], na.rm = TRUE)
      }

      plot_NOAA(
        NOAA,
        depth = depth,
        points = pts,
        epsg = input$epsg,
        rng = rng
      )

    })


    # convert stereographic coordinates which are returned as meters instead of
    # degrees
    observe({

      req(input$plot_click$x)
      req(input$plot_click$y)

      # depth
      selected$depth <- input$depth

      # coordinates (convert to degrees for stereographic projections)
      if (req(input$epsg) == "3031" | input$epsg == "3995") {
        crd <- convert_stereo(input$plot_click$x, input$plot_click$y,
                              input$epsg)
        selected$lon <- crd[ ,"lon", drop = TRUE]
        selected$lat <- crd[ ,"lat", drop = TRUE]

      } else {

        selected$lon <- input$plot_click$x
        selected$lat <- input$plot_click$y
      }
    })

    # helper modal
    observeEvent(input$epsghelper , {
      showModal(
        modalDialog(
          title = "EPSG Geodetic Parameter Dataset",
          HTML(
            paste0("The \"EPSG\" drop-down menu enables selection some of ",
                   " commonly used projections, such as \"4326\". And, two ",
                   "projections \"3031\" and \"3995\" for stereographic of ",
                   "the Antarctic and Arctic regions, respectively. ",
                   "The option \"original\" refers to the original projection ",
                   "of the NOAA WOC data.")
          )
        )
      )
    })

    observeEvent(input$fixedhelper , {
      showModal(
        modalDialog(
          title = "Fixating the oceanographic variable scale",
          HTML(
            paste0("This toggle switch determines whether the variable scale ",
                   "is fixed for the current depth slice or the whole  ",
                   "dataset. Loosening the variable scale can help highlight ",
                   "nuanced differences in certain variables (e.g. phosphate).")
          )
        )
      )
    })

    # return `reactivevalues`
    selected
  })
}
