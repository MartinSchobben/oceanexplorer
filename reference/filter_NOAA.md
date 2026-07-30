# Filter NOAA

This function aids filtering of NOAA datasets.

## Usage

``` r
filter_NOAA(NOAA, depth = 0, coord = NULL, epsg = NULL, fuzzy = 0)
```

## Arguments

- NOAA:

  Dataset of the NOAA World Ocean Atlas (with
  [`get_NOAA()`](https://martinschobben.github.io/oceanexplorer/reference/get_NOAA.md)).

- depth:

  Depth in meters

- coord:

  List with named elements, matrix with dimnames, or simple feature
  geometry list column: `lon` for longitude in degrees, and `lat` for
  latitude in degrees.

- epsg:

  Coordinate reference number.

- fuzzy:

  If no values are returned, fuzzy uses a buffer area around the point
  to extract values from adjacent grid cells. The fuzzy argument is
  supplied in units of kilometer (great circle distance).

## Value

Either a
[`stars`](https://r-spatial.github.io/stars/reference/st_as_stars.html)
object or [`sf`](https://r-spatial.github.io/sf/reference/sf.html)
dataframe.

## Details

This function helps filtering relevant data from NOAA World Ocean Atlas
3D arrays (longitude, latitude, and depth) which have been stored with
[`get_NOAA()`](https://martinschobben.github.io/oceanexplorer/reference/get_NOAA.md).
An 2D
[`stars`](https://r-spatial.github.io/stars/reference/st_as_stars.html)
object is returned if only providing a depth. An
[`sf`](https://r-spatial.github.io/sf/reference/sf.html) object is
returned, when further providing coordinates, as a list (e.g.
`list(lon = -120, lat = 12)`), a matrix (e.g.
`cbind(lon = -120, lat = 12)`), or an
[`sf`](https://r-spatial.github.io/sf/reference/sf.html) object with
POINT geometries. In the latter case it is import to follow the GeoJSON
conventions for the order in `sf` vectors with `x` (`lon` = longitude)
followed by `y` (`lat` = latitude).

## See also

[Simple Features for
R](https://r-spatial.github.io/sf/articles/sf1.html).

## Examples

``` r
if (interactive()) {

# get atlas
NOAAatlas <- get_NOAA("oxygen", 1, "annual")

# filter atlas for specific depth and coordinate location
filter_NOAA(NOAAatlas, 30, list(lon = c(-160, -120), lat =  c(11, 12)))

}
```
