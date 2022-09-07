#' Re-projecting spatial objects to new epsg
#'
#' Easy re-projecting of the epsg of \code{\link[sf:st_as_sf]{sf}} and
#' \code{\link[stars:st_as_stars]{stars}} objects.
#'
#' @param obj The sf or stars object to be re-projected.
#' @param epsg The projection (currently only: `"3031"`, or `"3995"`).
#' @param ... Currently not supported.
#'
#' @return sf or stars object
#' @export
#'
#' @examples
#'
#' if (curl::has_internet() && interactive()) {
#' # get data
#' NOAA <- get_NOAA("temperature", 1, "annual")
#'
#' # reproject data with new epsg
#' reproject(NOAA, 3031)
#' }
reproject <- function(obj, epsg, ...) {

  # check if epsg is different of original
  epsg <- epsg_check(obj, epsg)
  # epsg NULL, "", or "original" then use crs of supplied object
  if (epsg == "original") {
    return(obj)
  }

  UseMethod("reproject")
}
#' @rdname reproject
#'
#' @export
reproject.sf <- function(obj, epsg, ...) {

  if (epsg == 3031 | epsg == 3995 | epsg == sf::st_crs(3031) |
      epsg == sf::st_crs(3995)) {
    # clipping of latitudes for polar/orthographic projections
    clip_lat(obj, epsg)
  } else {
    sf::st_transform(obj, crs = epsg)
  }
}
#' @rdname reproject
#'
#' @export
reproject.stars <- function(obj, epsg, ...) {
  # polar/orthographic projections require sf::st_transform to be able to be plotted
  # with geom_sf
  if (epsg == 3031 | epsg == 3995 | epsg == sf::st_crs(3031) |
      epsg == sf::st_crs(3995)) {
    # clipping of latitudes for polar projection
    clip_lat(obj, epsg)
  } else {
    stars::st_warp(obj, crs = epsg)
  }
}

# check if supplied epsg is in correct format. In case of character string of
# digits, the epsg is converted to numeric
epsg_check <- function(obj, epsg) {

  # correct format and same as original
  if (is.null(epsg) || epsg == "original" || epsg == character(1)) {
    # return early
    "original"
  } else if (inherits(epsg, "crs")) {
    # return early
    if (epsg == sf::st_crs(obj)) {
      "original"
    } else {
      epsg
    }
  } else if (is.character(epsg) & grepl("^[[:digit:]]+$", epsg)) {
    # recast to numeric
    epsg <- as.numeric(epsg)
    # try if crs exist
    tryCatch(
      sf::st_crs(epsg),
      warning = function(cnd) {
        stop("Unknown format supplied to epsg.", call. = FALSE)
        }
      )

    if (sf::st_crs(epsg)  == sf::st_crs(obj)) {
      "original"
    } else {
      epsg
    }
  } else if (is.numeric(epsg)) {
    # try if crs exist
    tryCatch(
      sf::st_crs(epsg),
      warning = function(cnd) {
        stop("Unknown format supplied to epsg.", call. = FALSE)
      }
    )
    if (sf::st_crs(epsg) == sf::st_crs(obj)) {
      "original"
    } else {
      epsg
    }
  }
}

# for 3031 and 3995 we require clipping of latitudes at 50 degrees
clip_lat <- function(obj, epsg, limit = 0) {

  # epsg check
  epsg <- epsg_check(obj, epsg)

  if (inherits(obj, "stars")) {

    # for stars object we first need cropping and then re-projection
    x <- c(-180, 180)
    y <- c(limit, 90)
    box <- c(xmin = x[1], xmax = x[2])

    # antarctic bounds
    if (epsg == 3031) box <- append(box, c(ymin = - 1 * y[2], ymax = -1 * y[1]))
    # arctic bounds
    if (epsg == 3995) box <- append(box, c(ymin = y[1], ymax = y[2]))

    # rectangular box
    box <- sf::st_bbox(box)
    # original projection
    sf::st_crs(box) <- sf::st_crs(obj)
    # cropping
    obj <- sf::st_crop(obj, box)
    # re-projection (only sf_transform seems to work in combination with ggplot)
    stars::st_warp(obj, crs = epsg)

  } else if (inherits(obj, "sf")) {

    # for sf object we first need re-projection and then cropping
    obj <- sf::st_transform(obj, epsg)
    # center around pole
    circ <- sf::st_bbox(sf::st_point(c(0,0))) |>
      sf::st_as_sfc() |>
      # alters projection to have an projected crs
      sf::st_as_sf(crs = sf::st_crs(obj)) |>
      # draw circle
      sf::st_buffer(12500000)

    # cropping (make valid repairs the world map)
    suppressWarnings(
      sf::st_crop(sf::st_make_valid(obj), circ)
    )
  }
}

# for 3031 and 3995 we also require converting of coordinates to cartesian
# coordinates upon graph selection
convert_stereo <- function(lon, lat, epsg) {

  # convert meters to degrees (convert to numeric if needed)
  coord <- sf::st_point(c(as.numeric(lon), as.numeric(lat))) |>
    sf::st_sfc(crs = as.numeric(epsg)) |>
    sf::st_transform(crs = 4326) |>
    sf::st_coordinates()

  colnames(coord) <- c("lon", "lat")
  # return
  coord

}
