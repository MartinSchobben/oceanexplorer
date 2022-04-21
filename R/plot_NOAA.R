#' Plotting the global NOAA WORLD OCEAN ATLAS
#'
#' @param NOAA Dataset of the WORLD OCEAN ATLAS.
#' @param depth Depth in meters.
#' @param points Add locations of extracted point geometry.
#' @param epsg The epsg used to project the data (currently supported 4326, 3031
#'  and 3995).
#' @param limit The limits of the axis.
#' @param rng A vector of two numeric values for the range of the environmental
#'  parameter.
#'
#' @return Ggplot
#' @export
#'
#' @examples
#' \dontrun{
#' # data
#' base <- get_NOAA("oxygen", 1, "annual")
#'
#' # plot
#' plot_NOAA(base)
#'
#' # coordinates
#' points <- filter_NOAA(NOAA, 1, list(lon = c(-160, -120), lat =  c(11,12)))
#'
#' # plot
#' plot_NOAA(base, points)
#' }
plot_NOAA <- function(NOAA, depth = NULL, points = NULL, epsg = NULL, limit = NULL,
                      rng = NULL) {

  # get total range of environmental parameter in order to fix color scale over
  # different depth slices
  if (is.null(rng)) {
    rng <- range(NOAA[[1]], na.rm = TRUE)
  }

  # filter a specific depth to obtain a 2D representation
  if (!is.null(depth)) {
    base <- filter_NOAA(NOAA,  depth)
  } else {
    base <- NOAA
  }

  # get species / parameter names
  var <- substr(attributes(base)$names, 1, 1)

  if (is.null(limit)) limit <- 90

  # standard limits method sf coord
  lim_method <- "cross"

  # world map
  wmap <- maps::map("world", wrap = c(-180, 180), plot = FALSE, fill = TRUE) |>
    sf::st_as_sf()

  # coord transform NOAA and selected points if different from origin
  base <- reproject(base, epsg)
  wmap <- reproject(wmap, epsg)
  if (!is.null(points)) points <- reproject(points, epsg)

  # base plot
  base <- ggplot2::ggplot() +
    stars::geom_stars(data = base) +
    ggplot2::geom_sf(data = wmap, fill = "grey")

  if (!is.null(points)) {
    base <- base +
      ggplot2::geom_sf(data = points)
  }

  base +
    ggplot2::coord_sf(
      lims_method = "cross",
      xlim = c(-180, 180),
      ylim = c(-1 * limit, limit),
      ndiscr = 100,
      # default_crs = epsg,
      expand = FALSE
    ) +
    ggplot2::scale_fill_viridis_c(
      env_parm_labeller(var),
      limits = rng,
      na.value = "transparent"
    ) +
    ggplot2::labs(x = NULL, y = NULL) +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_line(
        color = grDevices::gray(.25),
        linetype = 'dashed',
        size = 0.5
      ),
      panel.ontop = TRUE,
      axis.line = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill = NA)
    )
}

clip_lat <- function(obj, epsg, limit = 55) {

  # for stars object we first need cropping and then re-projection
  if (inherits(obj, "stars")) {
    x <- c(-180, 180)
    y <- c(limit, 90)
    box <- c(xmin = x[1], xmax = x[2])
    # antarctic bounds
    if (epsg == 3031) box <- append(box, c(ymin = - 1 * y[2], ymax = -1 * y[1]))
    # arctic bounds
    if (epsg == 3995) box <- append(box, c(ymin = y[1], ymax = y[2]))
    box <- sf::st_bbox(box) # rectangular box
    sf::st_crs(box) <- sf::st_crs(obj) # original projection
    obj <- sf::st_crop(obj, box) # cropping
    # stars::st_warp(obj, epsg)
    sf::st_transform(obj, epsg) # re-projection
  # for sf object we first need re-projection and then cropping
  } else if (inherits(obj, "sfc")) {
    obj <- sf::st_transform(obj, epsg) # re-projection
    circ <- sf::st_bbox(sf::st_point(c(0,0))) %>% # center around pole
      sf::st_as_sfc() %>%
      sf::st_as_sf(crs = sf::st_crs(obj)) %>% # albers projection to have an projected crs
      sf::st_buffer(4000000) # draw circle
    sf::st_crop(sf::st_make_valid(obj), circ) # cropping (make valid repairs the world map)
 }
}


