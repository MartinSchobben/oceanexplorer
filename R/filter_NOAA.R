#' Filter NOAA
#'
#' @param NOAA Dataset of the WORLD OCEAN ATLAS.
#' @param depth Depth in meters
#' @param coord List with named elements: `lon` for longitude in degrees, and
#'  `lat` for latitude in degrees.
#' @param epsg Coordinate reference number.
#' @param fuzzy If no values are returned, fuzzy uses a buffer area around the
#'  point to extract values from adjacent grid cells. The fuzzy argument is
#'  supplied in units of kilometer(great circle distance).
#'
#' @return Either a stars object or sf dataframe.
#' @export
#'
#' @examples
#' \dontrun{
#' # get atlas
#' NOAAatlas <- get_NOAA("oxygen", 1, "annual")
#' # filter atlas for specific depth an coordinates
#' filter_NOAA(NOAAatlas, 30)
#' }
filter_NOAA <- function(NOAA, depth, coord = NULL, epsg = NULL,
  fuzzy = 0) {

  # add epsg to NOAA standard if none supplied
  NOAA_crs <- sf::st_crs(NOAA)

  if (!is.null(epsg) && epsg == "original") {
    epsg <- NULL
  } else if (!is.null(epsg) && is.character(epsg)) {
    epsg <- as.numeric(epsg)
  }

  # find depth intervals
  start_depth <- stars::st_dimensions(NOAA)$depth$values$start

  # depth
  x <- purrr::map(unique(depth), ~dplyr::slice(NOAA, "depth", findInterval(.x, start_depth)))

  # coordinate selection
  if (!is.null(coord)) {
    # check length of depth vector
    vc_check <- append(vapply(coord, length, numeric(1)), length(depth))
    if (!all(sapply(vc_check,  function(x) {x == 1 | x == max(vc_check)}))) {
     stop("Depth and coordinates must be a vector of length 1 or have consistent lengths.", call. = FALSE)
    }

    pnt <- purrr::map2(coord$lon, coord$lat, ~sf::st_point(c(.x, .y)))
    # transform crs if needed
    pnt <- transform_sfc(pnt, NOAA_crs, epsg)
    ext <- purrr::map2_dfr(x, unique(depth), ~extract_coords(.x, pnt, .y, fuzzy))
    return(ext)
  }
  # for plotting only the last depth slice is returned
  utils::tail(x, 1)[[1]]
}

# extract coordinates from a plane (fuzzy is in units km)
extract_coords <- function(plane, coords, depth, fuzzy = 0) {
  tb <- stars::st_extract(plane, na.rm = TRUE, at = coords)

  # add row numbers
  tb$id <- 1:nrow(tb)

  tb$depth <- rep(depth, nrow(tb))

  if (any(is.na(tb[[1]])) & fuzzy > 0) {

    # filter
    ft <- tb[is.na(tb[[1]]), ]
    # EXTRACT POLYGON
    tb_ft <- suppressWarnings(
      extract_coords(
        plane,
        sf::st_buffer(x = sf::st_geometry(ft), dist = fuzzy * 1e3),
        depth
        )
      )
    tb_ft$id <- ft$id
    # replace NAs
    tb <- rbind(tb, sf::st_as_sf(tb_ft)) %>%
      dplyr::group_by(.data$id) %>%
      dplyr::summarise(
        dplyr::across(- .data$geometry, .fns = ~mean(.x, na.rm = TRUE)),
        .groups = "drop"
        )

  }
  dplyr::select(tb, -.data$id)
}


# make simple feature with or without new crs
transform_sfc <- function(points, epsg_original, epsg_new = NULL) {
  if (is.null(epsg_new)) {
    sf::st_sfc(points, crs = epsg_original)
  } else {
    # if coordinate ref not null than first cast in new crs and transform back to data source
    sf::st_sfc(points, crs = epsg_new) %>%
      sf::st_transform(crs = epsg_original)
  }
}
