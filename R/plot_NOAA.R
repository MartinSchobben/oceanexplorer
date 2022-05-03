#' Plotting the global NOAA WORLD OCEAN ATLAS
#'
#' @param NOAA Dataset of the WORLD OCEAN ATLAS.
#' @param depth Depth in meters.
#' @param points Add locations of extracted point geometry.
#' @param epsg The epsg used to project the data (currently supported 4326, 3031
#'  and 3995).
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
plot_NOAA <- function(NOAA, depth = NULL, points = NULL, epsg = NULL,
                      rng = NULL) {

  # epsg_check
  epsg <- epsg_check(NOAA, epsg)
  if (epsg == "original") epsg <- sf::st_crs(NOAA)

  # get total range of environmental parameter in order to fix color scale over
  # different depth slices
  if (is.null(rng)) {
    rng <- range(NOAA[[1]], na.rm = TRUE)
  }

  # filter a specific depth to obtain a 2D representation
  if (!is.null(depth)) {
    NOAA <- filter_NOAA(NOAA, depth = depth, epsg = epsg)
  }

  # get species / parameter names
  var <- substr(attributes(NOAA)$names, 1, 1)

  # defaults
  lim_method <- "cross"

  # world map
  wmap <- maps::map("world", wrap = c(-180, 180), plot = FALSE, fill = TRUE) |>
    sf::st_as_sf()

  # coord transform NOAA, wmap and selected points if different from origin
  NOAA <- reproject(NOAA, epsg)
  wmap <- reproject(wmap, epsg)
  if (!is.null(points)) points <- reproject(points, epsg)

  # base plot
  base <- ggplot2::ggplot() +
    stars::geom_stars(data = NOAA) +
    ggplot2::geom_sf(data = wmap, fill = "grey")

  if (!is.null(points)) {
    base <- base +
      ggplot2::geom_sf(data = points)
  }

  if (epsg == 3031 | epsg == 3995 | epsg == sf::st_crs(3031) |
      epsg == sf::st_crs(3995)) {
    lim_method <- "geometry_bbox"
  }

  base +
    ggplot2::coord_sf(
      lims_method = lim_method,
      default_crs = epsg,
      crs = epsg,
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
