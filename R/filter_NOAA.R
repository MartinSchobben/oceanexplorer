#' Filter NOAA
#'
#' This function aids filtering of NOAA datasets.
#'
#' This function helps filtering relevant data from NOAA World Ocean Atlas
#' 3D arrays (longitude, latitude, and depth) which have been stored with
#' \code{stars::\link[stars:read_stars]{read_stars()}}. An 2D stars object is
#' returned if only providing a depth. An \code{\link[sf:st_sf]{sf}} is
#' returned, when further providing coordinates, as a list
#' (e.g. \code{list(lon = -120, lat = 12)}), a matrix
#' (e.g. \code{cbind(lon = -120, lat = 12)}), or an
#' \code{\link[sf:st_sf]{sf}} object with POINT geometries. In the
#' latter case it is import to follow the GeoJSON conventions for the order in
#' `sf` vectors with `x` (`lon` = longitude) followed by `y` (`lat` = latitude),
#' see also;
#' \href{https://r-spatial.github.io/sf/articles/sf1.html}{Simple Features for R}.
#'
#'
#' @param NOAA Dataset of the NOAA World Ocean Atlas
#'  (\code{\link[stars:read_stars]{stars}}).
#' @param depth Depth in meters
#' @param coord List with named elements, matrix with dimnames, or simple
#'  feature geometry list column: `lon` for longitude in degrees, and
#'  `lat` for latitude in degrees.
#' @param epsg Coordinate reference number.
#' @param fuzzy If no values are returned, fuzzy uses a buffer area around the
#'  point to extract values from adjacent grid cells. The fuzzy argument is
#'  supplied in units of kilometer (great circle distance).
#'
#' @return Either a \code{\link[stars:read_stars]{stars}} object or
#'  \code{\link[sf:st_sf]{sf}} dataframe.
#' @export
#'
#' @examples
#' \dontrun{
#' # get atlas
#' NOAAatlas <- get_NOAA("oxygen", 1, "annual")
#'
#' # filter atlas for specific depth and coordinate location
#' filter_NOAA(NOAAatlas, 30, list(lon = c(-160, -120), lat =  c(11, 12)))
#' }
filter_NOAA <- function(NOAA, depth = 0, coord = NULL, epsg = NULL,
                        fuzzy = 0) {

  # epsg check
  epsg <- epsg_check(NOAA, epsg)

  # coordinate check (most important in case of coord supplied)
  coord_check(coord, depth)

  # reproject data if supplied epsg is different, otherwise epsg will be set
  # to epsg of data
  if (epsg != "original") {
    NOAA <- reproject(NOAA, epsg)
  } else {
    epsg <- sf::st_crs(NOAA)
  }

  # find depth intervals
  start_depth <- stars::st_dimensions(NOAA)$depth$values$start

  # depth
  plane <- purrr::map(
    unique(depth),
    ~dplyr::slice(NOAA, "depth", findInterval(.x, start_depth))
  )

  # coordinate selection
  if (!is.null(coord)) {

    # get coordinates into right format
    coord <- cast_coords(coord, epsg)

    # extract coordinates from raster data and return sf object
    purrr::map2_dfr(
      plane,
      unique(depth),
      ~extract_coords(.x, coord, .y, epsg = epsg, fuzzy = fuzzy)
    )

  } else {
    # in case of no coordinates the upper depth plane is returned  as a stars
    # object
    plane[[1]]
  }
}

# check the supplied coordinates
coord_check <- function(coord, depth) {

  # check length of depth vector
  if (inherits(coord, c("sf", "sfc"))) {

    # length sf object
    vc_check <- append(nrow(coord), length(depth))

  } else if (!is.null(coord)) {

    # in case of lists or matrices coordinates must have names "lon" and "lat"
    nms <- colnames(coord) # matrix
    if (is.null(nms)) nms <- names(coord) # list

    if (all(nms[1] != "lon", nms[2] != "lat")) {

      stop("When supplying coordinates for the extraction of oceanographic ",
           "parameters, the list or matrix must have the names \"lon\" and ",
           "\"lat\" for the first and second element or column, respectively.",
           call. = FALSE)
    }

    vc_check <- append(vapply(coord, length, numeric(1)), length(depth))

  } else {

    # if default NULL is propagated
    vc_check <- coord

  }

  vc_check <- vapply(
    vc_check,
    function(x) {x == 1 | x == max(vc_check)},
    logical(1)
  )

  if (!all(vc_check)) {
    stop(paste0("Depth and coordinates must be a vector of length 1 or have ",
                "consistent lengths."), call. = FALSE)
  }

}

# cast the coordinates in a unified formats (matrix or sf output)
cast_coords <- function(coord, epsg) {

  # if list class coerce to matrix
  if (inherits(coord, "list")) {

    rlang::inject(cbind(!!! coord, deparse.level = 2))

  } else if (inherits(coord, c("sf", "sfc"))) {

    # transform crs of coordinates if required to original data format
    if (sf::st_crs(coord) != epsg) {

      sf::st_transform(coord, crs = epsg)

    } else {

      coord
    }


  } else if (inherits(coord, "matrix")) {

    coord

  } else {
    stop(paste0("Class supplied to `coord` unsupported."), call. = FALSE)
  }
}

# extract coordinates from a plane (fuzzy is in units km)
extract_coords <- function(plane, coords, depth, epsg, fuzzy = 0) {

  tb <- stars::st_extract(plane, na.rm = TRUE, at = coords)

  # add row numbers
  tb$id <- 1:nrow(tb)

  # add depth
  tb$depth <- rep(depth, nrow(tb))

  # add coordinates in case of matrix
  if (inherits(coords , "matrix")) {

    tb <- sf::st_as_sf(cbind(tb, coords), coords = c("lon", "lat"), crs = epsg)

  # change coordinate system of sfc class if needed
  } else if (inherits(coords, c("sf", "sfc")) & sf::st_crs(tb) != epsg) {

    tb <- sf::st_transform(tb, epsg)

  }

  if (any(is.na(tb[[1]])) & fuzzy > 0) {

    # filter
    ft <- tb[is.na(tb[[1]]), , drop = FALSE]

    # extract polygon
    tb_ft <- suppressWarnings(
      extract_coords(
        plane,
        sf::st_buffer(x = sf::st_geometry(ft), dist = fuzzy * 1e3),
        depth,
        epsg
        )
      )
    tb_ft$id <- ft$id

    # replace NAs
    tb <- rbind(tb, sf::st_as_sf(tb_ft)) |>
      dplyr::group_by(.data$id) |>
      dplyr::summarise(
        dplyr::across(-.data$geometry, .fns = ~mean(.x, na.rm = TRUE)),
        .groups = "drop"
      ) |>
      dplyr::mutate(geometry_search = .data$geometry, geometry = tb$geometry)

  }
  dplyr::select(tb, -.data$id)
}

