# Ocean explorer addin

Wrapper function that launches the NOAA RStudio addin

## Usage

``` r
NOAA_addin(cache = FALSE)
```

## Arguments

- cache:

  Caching the extracted NOAA file in the package's `extdata` directory
  (default = `FALSE`). Size of individual files is around 12 Mb. Use
  [`list_NOAA()`](https://martinschobben.github.io/oceanexplorer/reference/list_NOAA.md)
  to list cached data resources.

## Value

Rstudio gadget

## Examples

``` r

if (interactive()) {

# run RStudio addin (can also be launched from `Addins` dropdown menu)
NOAA_addin()

}
```
