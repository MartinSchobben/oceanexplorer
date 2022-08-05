# run data module stand-alone

library(oceanexplorer)
library(shiny)

# data
NOAA <- get_NOAA("oxygen", 1, "annual")

# gui
ui <- fluidPage(input_ui("NOAA"), plot_ui("worldmap"))

# server
server <-function(input, output, session) {
  # table
  NOAA <- input_server("NOAA")
  # plot data
  output_plot <- plot_server("worldmap", NOAA$data, reactive(NULL))
}

# run app
shinyApp(ui, server)
