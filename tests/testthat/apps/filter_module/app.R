# run filter module stand-alone

library(oceanexplorer)
library(shiny)

# data
NOAA <- get_NOAA("oxygen", 1, "annual")

# gui
ui <- fluidPage(filter_ui("filter"), plot_ui("worldmap"))

# server
server <-function(input, output, session) {
  # table
  filter <- filter_server(
    "filter",
    reactive(NOAA),
    external = reactiveValues(lon = 190, lat = 33, depth = 20),
    variable = reactiveValues(variable = "temperature")
  )

  # plot data
  output_plot <- plot_server("worldmap", reactive(NOAA), filter$coord)

}

# run app
shinyApp(ui, server)
