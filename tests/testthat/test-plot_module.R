# NOAA <- get_NOAA("oxygen", 1, "annual")
#
# # base (surface depth)
# base <- filter_NOAA(NOAA,  0)
#
# # coordinates
# points <- filter_NOAA(NOAA, 1, list(lon = c(-160, -120), lat =  c(11,12)))
#
# #plot
# plot_NOAA(base, points)
#
# ui <- fluidPage(
#   plot_ui("plot")
# )
#
# server <- function(input, output, session) {
#  plot_server("plot", NOAA = reactive(base), points = reactive(NULL))
# }
#
# shinyApp(ui, server)
