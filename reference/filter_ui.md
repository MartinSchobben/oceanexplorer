# NOAA filter module

This shiny module (`filter_ui()` + `filter_server()`) allows filtering
of the currently loaded NOAA data via shiny `textInput()` interfaces.

## Usage

``` r
filter_ui(id, extended = TRUE)

filter_server(
  id,
  NOAA,
  external,
  ivars = c("depth", "lon", "lat"),
  variable,
  extended = TRUE
)
```

## Arguments

- id:

  Namespace id shiny module.

- extended:

  Boolean whether to build the extended module (default = `TRUE`).

- NOAA:

  Reactive value for the dataset containing the locations coordinates.

- external:

  Reactive values for latitude, longitude and depth from plot module.

- ivars:

  Character vector for the variables for filtering.

- variable:

  Reactivevalues for selected variable information.

## Value

Shiny module.

## Examples

``` r

# run filter module stand-alone
if (interactive()) {

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
 }
```
