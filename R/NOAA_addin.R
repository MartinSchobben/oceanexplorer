#' Ocean explorer addin
#'
#' Wrapper function that launches the NOAA RStudio addin
#'
#' @inheritParams get_NOAA
#'
#' @return Rstudio gadget
#' @export
#'
#' @examples
#'
#' if (interactive()) {
#'
#' # run RStudio addin (can also be launched from `Addins` dropdown menu)
#' NOAA_addin()
#'
#' }
NOAA_addin <- function(cache = FALSE) {

  ui <- miniPage(
    shinyjs::useShinyjs(), # use shinyjs
    gadgetTitleBar("NOAA WORLD OCEAN ATLAS"),
    miniTabstripPanel(
      id = "tabset",
      miniTabPanel(
        "Parameters",
        icon = icon("sliders-h", verify_fa = FALSE),
        miniContentPanel(
          waiter::use_waiter(),
          input_ui("NOAA", citation = citation_ui("NOAA"), extended = FALSE),
          )
      ),
      miniTabPanel(
        "Map",
        icon = icon("map-marked-alt", verify_fa = FALSE),
        miniContentPanel(
          padding = 0,
          plot_ui("worldmap")
          ),
        filter_ui("depth", extended = FALSE)
      ),
      miniTabPanel(
        "Table",
        icon = icon("table", verify_fa = FALSE),
        miniContentPanel(table_ui("table"))
      )
    )
  )

  runGadget(
    shinyApp(ui, NOAA_server(extended = FALSE, cache = cache)),
    viewer = paneViewer()
  )
}
