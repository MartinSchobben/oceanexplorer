# NOAA table module

This shiny module (`table_ui()` + `table_server()`) visualizes the
loaded and filtered data in a table format.

## Usage

``` r
table_ui(id, download = NULL)

table_server(id, NOAA, variable)
```

## Arguments

- id:

  Namespace id shiny module.

- download:

  Add download button.

- NOAA:

  Reactive value for the dataset containing the locations coordinates.

- variable:

  Reactivevalues for selected variable information.

## Value

Shiny module.

## Examples

``` r

if (interactive()) {
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

}
```
