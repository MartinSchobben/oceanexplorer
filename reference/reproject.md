# Re-projecting spatial objects to new epsg

Easy re-projecting of the epsg of
[`sf`](https://r-spatial.github.io/sf/reference/st_as_sf.html) and
[`stars`](https://r-spatial.github.io/stars/reference/st_as_stars.html)
objects.

## Usage

``` r
reproject(obj, epsg, ...)

# S3 method for class 'sf'
reproject(obj, epsg, ...)

# S3 method for class 'stars'
reproject(obj, epsg, ...)
```

## Arguments

- obj:

  The sf or stars object to be re-projected.

- epsg:

  The projection (currently only: `"3031"`, or `"3995"`).

- ...:

  Currently not supported.

## Value

sf or stars object

## Examples

``` r

if (interactive()) {
# get data
NOAA <- get_NOAA("temperature", 1, "annual")

# reproject data with new epsg
reproject(NOAA, 3031)
}
```
