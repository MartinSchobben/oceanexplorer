# NOAA data module

These shiny modules control loading of data from the NOAA world ocean
atlas (`input_ui()` + `input_server()`). In addition, the
`output_ui()` + `output_server()` can be used to export the filtered
data in csv format. The `citation_ui()` provides the associated
references of the dataset currently loaded.

## Usage

``` r
input_ui(id, citation = NULL, extended = TRUE)

citation_ui(id)

output_ui(id)

input_server(id, cache = FALSE)

output_server(id, NOAA, variable)
```

## Arguments

- id:

  Namespace id shiny module.

- citation:

  Additional space for citation element.

- extended:

  Boolean whether to build the extended module (default = `TRUE`).

- cache:

  Caching the extracted NOAA file in the package's `extdata` directory
  (default = `FALSE`). Size of individual files is around 12 Mb. Use
  [`list_NOAA()`](https://martinschobben.github.io/oceanexplorer/reference/list_NOAA.md)
  to list cached data resources.

- NOAA:

  Reactive value for the dataset containing the locations coordinates.

- variable:

  Reactivevalues for selected variable information.

## Value

Shiny module.

## Examples

``` r

# run data module stand-alone
if (interactive()) {

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
}
```
