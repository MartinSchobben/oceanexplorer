# Obtain NOAA World Ocean Atlas dataset

Retrieves data from the NOAA World Ocean Atlas.

## Usage

``` r
get_NOAA(var, spat_res, av_period, cache = FALSE)

url_parser(var, spat_res, av_period, cache = FALSE)
```

## Arguments

- var:

  The chemical or physical variable of interest (possible choices:
  `"temperature"`, `"phosphate"`, `"nitrate"`, `"silicate"`, `"oxygen"`,
  `"salinity"`, `"density"`).

- spat_res:

  Spatial resolution, either 1 or 5 degree grid-cells (numeric) .

- av_period:

  Temporal resolution, either `"annual"`, specific seasons (e.g.
  `"winter"`), or month (e.g. `"August"`).

- cache:

  Caching the extracted NOAA file in the package's `extdata` directory
  (default = `FALSE`). Size of individual files is around 12 Mb. Use
  [`list_NOAA()`](https://martinschobben.github.io/oceanexplorer/reference/list_NOAA.md)
  to list cached data resources.

## Value

[`stars`](https://r-spatial.github.io/stars/reference/st_as_stars.html)
object or path.

## Details

Functions to retrieve data from the [NOAA World Ocean
Atlas](https://www.ncei.noaa.gov/products/world-ocean-atlas) . Data is
an 3D array (longitude, latitude, and depth) and is loaded as a
[`stars`](https://r-spatial.github.io/stars/reference/st_as_stars.html)
object. Check
[`NOAA_data`](https://martinschobben.github.io/oceanexplorer/reference/NOAA_data.md)
for available variables, respective units and their citations. The
function can automatically cache the extracted files (default:
`cache = FALSE`). The cached file will then reside in the package's
`extdata` directory.

## See also

[Introduction to the stars
package](https://r-spatial.github.io/stars/articles/stars1.html)

## Examples

``` r

# path to NOAA server or local data source
url_parser("oxygen", 1, "annual")
#> $external
#> [1] "https://data.nodc.noaa.gov/thredds/dodsC/ncei/woa/oxygen/all/1.00/woa18_all_o00_01.nc"
#> 

if (interactive()) {

# retrieve NOAA data
get_NOAA("oxygen", 1, "annual")

}
```
