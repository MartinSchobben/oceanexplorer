# run plot_module stand-alone
library(oceanexplorer)
library(shiny)

# data
NOAA <- get_NOAA("oxygen", 1, "annual")

# coordinates
points <- filter_NOAA(NOAA, 1, list(lon = c(-160, -120), lat =  c(11, 12)))

ui <- fluidPage(plot_ui("plot"))

server <-function(input, output, session) {
  plot_server("plot", reactive(NOAA), reactive(points))
}

# run app
shinyApp(ui, server)
