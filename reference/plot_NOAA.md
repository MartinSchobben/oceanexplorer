# Plotting the global NOAA World Ocean Atlas

Plots the NOAA World Ocean Atlas on worldmap including optional filtered
locations.

## Usage

``` r
plot_NOAA(NOAA, depth = 0, points = NULL, epsg = NULL, rng = NULL)
```

## Arguments

- NOAA:

  Dataset of the NOAA World Ocean Atlas (with
  [`get_NOAA()`](https://martinschobben.github.io/oceanexplorer/reference/get_NOAA.md)).

- depth:

  Depth in meters.

- points:

  Add locations of extracted point geometry
  ([`sf`](https://r-spatial.github.io/sf/reference/sf.html) object).

- epsg:

  The epsg used to project the data (currently supported `4326`,
  `3031`and `3995`).

- rng:

  A vector of two numeric values for the range of the oceanographic
  variable.

## Value

[`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html)

## Details

A worldmap is plotted as an
[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html) object
which by default will plot the surface layer of the selected
oceanographic variable. One can plot different depth slices by selecting
the appropriate depth in meters (e.g., `depth = 100`). It is,
furthermore possible to visualize the locations of data extractions with
[`filter_NOAA()`](https://martinschobben.github.io/oceanexplorer/reference/filter_NOAA.md).
See the examples below for a more detailed overview of this workflow.
Different projections of the worldmap can be selected by supplying an
`epsg`. Currently only three projections are allowed: 4326, 3031, and
3995, besides the original. It is possible to fix the range of the color
scale (for the oceanographic variable) to a custom range. For example,
one can fix the color scale to the total range of the ocean (instead of
the current depth slice).

## Examples

``` r
if (interactive()) {

# data
NOAA <- get_NOAA("oxygen", 1, "annual")

# plot
plot_NOAA(NOAA)

# coordinates
pts <- filter_NOAA(NOAA, 1, list(lon = c(-160, -120), lat =  c(11,12)))

# plot
plot_NOAA(NOAA, points = pts)

}
```
