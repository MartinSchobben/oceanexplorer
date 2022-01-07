#' Ocean explorer app
#'
#' @return Shiny app
#' @export
NOAA_app <- function() {

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
          h4("Select your variable of interest and click on load data to display the results."),
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
              table_ui("table")
            )
          ),
          ns = NS("NOAA")
        )
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
    filter <- filter_server("depth", NOAA$data, NOAA$variable)

    # plot data
    plot_server("worldmap", filter$map, filter$coord)

    # table
    table_server("table", filter$table)

  }

  shinyApp(ui, server)
}




