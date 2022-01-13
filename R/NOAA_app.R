#' Ocean explorer app
#'
#' @param server Server function.
#' @param extended Boolean whether to launch the extended app (default = `TRUE`)
#'  or the limited version for usage as a RStudio gadget.
#'
#' @return Shiny app
#' @export
NOAA_app <- function(server = NOAA_server()) {

  ui <- fluidPage(
    theme = bslib::bs_theme(bootswatch = "slate"),
    titlePanel("NOAA WORLD OCEAN ATLAS"),
    sidebarLayout(
      sidebarPanel(
        input_ui("NOAA")
      ),
      mainPanel(
        conditionalPanel(
          condition = "output.citation==null",
          h4("Select variable of interest and click \"Load data\" to display results."),
          ns = NS("NOAA")
        ),
        conditionalPanel(
          condition = "output.citation!=null",
          fluidRow(
            column(
              width = 8,
              filter_ui("depth", plot_ui("worldmap"))
              ),
            column(
              width = 2,
              table_ui("table", output_ui("download"))
            )
          ),
          ns = NS("NOAA")
        )
      )
    )
  )



  shinyApp(ui, server)
}
#' @rdname NOAA_app
#'
#' @export
NOAA_server <- function(extended = TRUE) {
  function(input, output, session) {

    # plot colors to match shiny ui
    thematic::thematic_shiny()

    # original data
    withProgress(message = "Retrieving dataset from NOAA server", {
      NOAA <- input_server("NOAA")
    })

    # initiate plot click filter with null value
    clicked <- reactiveValues(lon = NULL, lat = NULL)

    # filter depth
    filter <- filter_server("depth", NOAA$data, NOAA$variable, clicked,
                            extended = extended)

    # plot data
    output_clicked <- plot_server("worldmap", filter$map, filter$coord,
                                  filter$back, filter$reset,
                                  filter$depth_slider)

    # update reactivevalue if plot click selection has been used
    observe({
      clicked$lon <- output_clicked$lon
      clicked$lat <- output_clicked$lat
    })

    # table
    table_server("table", filter$table, filter$back, filter$reset)

    # download
    output_server("download", filter$table, NOAA$variable)

    # emit code (RStudio addin)
    if (isFALSE(extended)) {
      # listen for 'done'.
      observeEvent(input$done, {
        req(NOAA$code())

        observe(message(glue::glue("{NOAA$code()}")))
        observe(message(glue::glue("{filter$code()}")))

        # code (only loading)
        if (isTruthy(NOAA$code()) & !isTruthy(filter$code())) {
          rstudioapi::insertText(paste0("library(oceanexplorer) \nNOAA <-", NOAA$code()))
          invisible(stopApp())
        }
        # code (loading and filter extraction)
        if (isTruthy(NOAA$code()) & isTruthy(filter$code())) {
          rstudioapi::insertText(paste0("library(oceanexplorer) \nNOAA <-", NOAA$code(), "\n", filter$code()))
          invisible(stopApp())
        }


      })
    }

  }
}

