#' Plotting the global NOAA World Ocean Atlas
#'
#' Plots the NOAA World Ocean Atlas on worldmap including optional
#' filtered locations.
#'
#' A worldmap is plotted as an \code{ggplot2:\link[ggplot2:ggplot]{ggplot}}
#' object which by default will plot the surface layer of the selected
#' oceanographic variable. One can plot different depth slices by selecting
#' the appropriate depth in meters (e.g., \code{code = 100}). It is, furthermore
#' , possible to visualize the locations of data extractions with
#' \code{\link[oceanexplorer:filter_NOAA]{filter_NOAA()}}. See the examples
#' below for a more detailed overview of this workflow. Different projections
#' of the worldmap can be selected by supplying an \code{epsg}. Currently only
#' three projections are allowed: 4326, 3031, and 3995, besides the original.
#' It is possible to fix the range of the color scale (for the oceanographic
#' variable) to a custom range. For example, one can fix the color scale
#' to the total range of the ocean (instead of the current depth slice).
#'
#' @param NOAA Dataset of the NOAA World Ocean Atlas
#'  (\code{\link[stars:read_stars]{stars}}).
#' @param depth Depth in meters.
#' @param points Add locations of extracted point geometry
#'  (\code{\link[sf:st_sf]{sf}} object).
#' @param epsg The epsg used to project the data (currently supported 4326, 3031
#'  and 3995).
#' @param rng A vector of two numeric values for the range of the oceanographic
#'  variable.
#'
#' @return \code{ggplot2:\link[ggplot2:ggplot]{ggplot}}
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
plot_NOAA <- function(NOAA, depth = 0, points = NULL, epsg = NULL, rng = NULL) {

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
