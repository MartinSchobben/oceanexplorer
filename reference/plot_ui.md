# NOAA plot module

This shiny module (`plot_ui()` + `plot_server()`) visualizes the loaded
data according to the selected epsg projection (`"original"`, `"4326"`,
`"3031"`, or `"3995"`). In addition it provides an interactive plot
interface to select location for data extraction based on a
single-click.

## Usage

``` r
plot_ui(id)

plot_server(id, NOAA, points)
```

## Arguments

- id:

  Namespace id shiny module.

- NOAA:

  Reactive value for the dataset containing the locations coordinates.

- points:

  Add locations of extracted point geometry.

## Value

Shiny module.

## Examples

``` r

# run plot module stand-alone
if (interactive()) {

library(oceanexplorer)
library(shiny)

# data
NOAA <- get_NOAA("oxygen", 1, "annual")

# coordinates
points <- filter_NOAA(NOAA, 1, list(lon = c(-160, -120), lat =  c(11, 12)))

# gui
ui <- fluidPage(plot_ui("plot"))

# server
server <-function(input, output, session) {
 plot_server("plot", reactive(NOAA), reactive(points))
}

# run app
shinyApp(ui, server)

}
```
