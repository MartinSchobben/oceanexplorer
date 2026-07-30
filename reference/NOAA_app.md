# Ocean explorer app

Wrapper function that launches the NOAA app.

## Usage

``` r
NOAA_app(cache = FALSE)

NOAA_server(extended = TRUE, cache)
```

## Arguments

- cache:

  Caching the extracted NOAA file in the package's `extdata` directory
  (default = `FALSE`). Size of individual files is around 12 Mb. Use
  [`list_NOAA()`](https://martinschobben.github.io/oceanexplorer/reference/list_NOAA.md)
  to list cached data resources.

- extended:

  Boolean whether to build the extended module (default = `TRUE`).

## Value

Shiny app

## Examples

``` r

if (interactive()) {

# run app
NOAA_app()

}
```
