#' Plotting the global NOAA WORLD OCEAN ATLAS
#'
#' @param NOAA Dataset of the WORLD OCEAN ATLAS.
#' @param points Add locations of extracted point geometry.
#'
#' @return Ggplot
#' @export
#'
#' @examples
#' \dontrun{
#' # data
#' NOAA <- get_NOAA("oxygen", 1, "annual")
#'
#' # base (surface depth)
#' base <- filter_NOAA(NOAA,  0)
#'
#' # coordinates
#' points <- filter_NOAA(NOAA, 1, list(lon = c(-160, -120), lat =  c(11,12)))
#'
#' #plot
#' plot_NOAA(base, points)
#' }
plot_NOAA <- function(NOAA, points = NULL) {

  # get species / parameter names
  var <- substr(attributes(NOAA)$names, 1, 1)
  if (var %in% c("i", "p", "o", "n")) {
    element <- c(i = "SiO", p = "PO", o = "O", n = "NO")
    index <- c(i = 2, p = 4, o = 2, n = 3)
    xc <- substitute(a[b]~"("*mu*"mol kg"^{"-"}*")", list(a = element[var], b = index[var]))
  }
  if (var %in% c("t")) {
    xc <- expression('Temp ('*degree~C*')')
  }
  if (var %in% c("s")) {
    xc <- "Salinity"
  }
  if (var %in% c("I")) {
    xc <- expression("Density (kg m"^{"-3"}*")")
  }

  base <- ggplot2::ggplot() +
    stars::geom_stars(data = NOAA)

  if (!is.null(points)) {
    base <- base +
      ggplot2::geom_sf(data = points)
  }
  base + ggplot2::coord_sf(xlim =c(-180, 180), ylim = c(-90, 90)) +
    ggplot2::scale_x_discrete(expand = c(0, 0)) +
    ggplot2::scale_y_discrete(expand = c(0, 0)) +
    ggplot2::scale_fill_viridis_c(xc) +
    ggplot2::labs(x = NULL, y = NULL)
}
