# run table module stand-alone

library(oceanexplorer)
library(shiny)

# data
NOAA <- get_NOAA("oxygen", 1, "annual")

# coordinates
points <- filter_NOAA(NOAA, 1, list(lon = c(-160, -120), lat =  c(11, 12)))

# gui
ui <- fluidPage(table_ui("table"))

# server
server <-function(input, output, session) {
  # table
  output_table <- table_server(
   "table",
   reactive(points),
   reactiveValues(parm = "temperature", spat = 1, temp = "annual")
 )
}

# run app
shinyApp(ui, server)
