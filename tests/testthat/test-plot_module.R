library(shinytest)

NOAA <- get_NOAA("oxygen", 1, "annual")

# base (surface depth)
base <- filter_NOAA(NOAA,  0)

# coordinates
points <- filter_NOAA(NOAA, 1, list(lon = c(-160, -120), lat =  c(11,12)))

ui <- fluidPage(
  plot_ui("plot")
)

server <- function(input, output, session) {
 plot_server("plot", NOAA = reactiveVal(base), points = reactiveVal(points),
             epsg = reactiveVal(4326))
}

app <- ShinyDriver$new(shinyApp(ui, server))


recordTest(app)


