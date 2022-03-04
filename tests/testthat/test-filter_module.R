# library(shinytest)
#
# NOAA <- get_NOAA("oxygen", 1, "annual")
#
# ui <- fluidPage(
#   filter_ui("filter")
# )
#
# server <- function(input, output, session) {
#   filter_server("plot", reactive(NOAA),
#                 reactiveValues(lon = NULL, lat = NULL, depth = NULL))
# }
#
# app <- ShinyDriver$new(shinyApp(ui, server))
#

