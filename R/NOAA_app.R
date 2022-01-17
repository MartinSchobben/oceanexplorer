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
    # theme = bslib::bs_theme(bootswatch = "slate"),
    shinyjs::useShinyjs(), # use shinyjs
    titlePanel("NOAA WORLD OCEAN ATLAS"),
    sidebarLayout(
      sidebarPanel(
        tabsetPanel(
          id = "tabset",
          tabPanel("parameters", input_ui("NOAA")),
          tabPanel("locations", filter_ui("depth"))
          ),
        citation_ui("NOAA")
        ),
      mainPanel(
        waiter::use_waiter(),
        conditionalPanel(
          condition = "output.citation==null",
          h4("Select variable of interest and click \"Load data\" to display results."),
          ns = NS("NOAA")
        ),
        conditionalPanel(
          condition = "output.citation!=null",
          tabsetPanel(
            tabPanel(
              "Map",
              plot_ui("worldmap")
              ),
            tabPanel(
              "Table",
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
    # thematic::thematic_shiny()

    # original data
    withProgress(message = "Retrieving dataset from NOAA server", {
      NOAA <- input_server("NOAA")
    })

    # show locations selection controls when data loaded
    observeEvent(NOAA$data(), {
      updateTabsetPanel(session, "tabset", selected = "locations")
    })

    # initiate plot click filter with null value
    clicked <- reactiveValues(lon = NULL, lat = NULL, depth = NULL)

    # filter depth
    filter <- filter_server("depth", NOAA$data, clicked)

    # plot data
    output_plot <- plot_server("worldmap", filter$map, filter$coord)

    # update `reactivevalue` if plot click selection has been used
    observe({
      clicked$lon <- output_plot$lon
      clicked$lat <- output_plot$lat
      clicked$depth <- output_plot$depth
    })

    # table
    output_table <- table_server("table", filter$coord, NOAA$variable)

    # download
    output_server("download", filter$coord, NOAA$variable)

    # emit code (RStudio addin)
    if (isFALSE(extended)) {
      # listen for 'done'.
      observeEvent(input$done, {
        req(NOAA$code())

        # code (only loading)
        if (isTruthy(NOAA$code()) & !isTruthy(output_table())) {
          rstudioapi::insertText(paste0("library(oceanexplorer) \nNOAA <-", NOAA$code()))
          invisible(stopApp())
        }
        # code (loading and filter extraction)
        if (isTruthy(NOAA$code()) & isTruthy(output_table())) {
          rstudioapi::insertText(paste0("library(oceanexplorer) \nNOAA <-", NOAA$code(), "\n", output_table()))
          invisible(stopApp())
        }


      })
    }

  }
}

