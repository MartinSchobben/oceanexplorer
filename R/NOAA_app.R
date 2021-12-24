#' Ocean explorer app
#'
#' @return Shiny app
#' @export
NOAA_app <- function() {

  ui <- fluidPage(
    theme = bslib::bs_theme(bootswatch = "slate"),
    titlePanel("NOAA WORLD OCEAN ATLAS"),
    sidebarLayout(sidebarPanel(input_ui("NOAA")),
    mainPanel(
      filter_ui("depth"),
      plot_ui("worldmap"),
      tags$caption("Variable averaged over a time span ranging from 1955 to 2017.")
      )
    )
  )

  server <- function(input, output, session) {
    thematic::thematic_shiny()
    # original data
    withProgress(message = "Retrieving dataset from NOAA server", {
      NOAA <- input_server("NOAA")
    })

    # filter depth
    filter <- filter_server("depth", NOAA)

    # plot data
    plot_server("worldmap", filter)

  }

  shinyApp(ui, server)
}




