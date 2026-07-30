# List cached NOAA data files

List all cached NOAA data files from package's `extdata` directory.

## Usage

``` r
list_NOAA()
```

## Value

A character vector containing the names of the files in the specified
directories (empty if there were no files). If a path does not exist or
is not a directory or is unreadable it is skipped.

## Examples

``` r

# show cached NOAA files
list_NOAA()
#> character(0)
```
