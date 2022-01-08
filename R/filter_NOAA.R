#' Filter NOAA
#'
#' @param NOAA Dataset of the WORLD OCEAN ATLAS.
#' @param depth Depth in meters
#' @param coord List with named elements: `lon` for longitude in degrees, and
#'  `lat` for latitude in degrees.
#' @param output Geometry point (default `"point"`). Additional geometries are
#'  currently not supported.
#'
#' @return Either a stars object or sf dataframe
#' @export
#'
#' @examples
#' \dontrun{
#' # get atlas
#' NOAAatlas <- get_NOAA("oxygen", 1, "annual")
#' # filter atlas for specific depth an coordinates
#' filter_NOAA(NOAAatlas, 30)
#' }
filter_NOAA <- function(NOAA, depth, coord = NULL, output = "point") {


  # drop singular dimension
  NOAA <- NOAA %>% abind::adrop()

  # find depth intervals
  start_depth <- stars::st_dimensions(NOAA)$depth$values$start

  # depth
  x <- purrr::map(depth, ~dplyr::slice(NOAA, "depth", findInterval(.x, start_depth)))

  # coordinate selection
  if (!is.null(coord)) {
    # check length of depth vector
    vc_check <- append(sapply(coord, length), length(depth))
    assertthat::assert_that(
      all(sapply(vc_check,  function(x) {x == 1 | x == max(vc_check)})),
      msg = "Depth and coordinates must be a vector of length 1 or have consistent lengths."
    )

    pnt <- purrr::map2(coord$lon, coord$lat, ~sf::st_point(c(.x, .y))) %>%
      sf::st_sfc(crs = sf::st_crs(x[[1]]))
    ext <- purrr::map2_dfr(x, depth, ~stars::st_extract(.x, pnt) %>%
                             tibble::add_column(depth = .y))
    return(ext)
  }
  # for plotting only the last depth slice is returned
  tail(x, 1)[[1]]
}

