#' Ocean explorer addin
#'
#' @return Rstudio gadget
#' @export
NOAA_addin <- function(server = NOAA_server(extended = FALSE)) {

  ui <- miniPage(
    gadgetTitleBar("NOAA WORLD OCEAN ATLAS"),
    miniTabstripPanel(
      miniTabPanel(
        "Parameters",
        icon = icon("sliders-h"),
        miniContentPanel(
          input_ui("NOAA", extended = FALSE)
          )
      ),
      miniTabPanel(
        "Map",
        icon = icon("map-marked-alt"),
        miniContentPanel(
          padding = 0,
          plot_ui("worldmap")
          ),
      miniButtonBlock(filter_ui("depth", extended = FALSE))
      ),
      miniTabPanel(
        "Data",
        icon = icon("table"),
        miniContentPanel(table_ui("table"))
      )
    )
  )

  runGadget(shinyApp(ui, server), viewer = paneViewer())
  }
