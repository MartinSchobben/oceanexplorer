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
#' get_NOAA("oxygen", 1, "annual") %>% plot_NOAA()
#' }
plot_NOAA <- function(NOAA, points = NULL) {

  # get species / parameter names
  var <- stringr::str_sub(attributes(NOAA)$names, 1, 1)
  if (var %in% c("i", "p", "o", "n")) {
    element <- c(i = "SiO", p = "PO", o = "O", n = "NO")
    index <- c(i = 2, p = 4, o = 2, n = 3)
    sc <- list(ggplot2::scale_fill_viridis_c(substitute(a[b]~"("*mu*"mol kg"^{"-"}*")", list(a = element[var], b = index[var]))))
  }
  if (var %in% c("t")) {
    sc <- list(ggplot2::scale_fill_viridis_c(expression('Temp ('*degree~C*')')))
  }
  if (var %in% c("s")) {
    sc <- list(ggplot2::scale_fill_viridis_c("Salinity"))
  }
  if (var %in% c("I")) {
    sc <- list(ggplot2::scale_fill_viridis_c(expression("Density (kg m"^{"-3"}*")")))
  }

  base <- ggplot2::ggplot() +
    stars::geom_stars(data = NOAA [1]) +
    ggplot2::coord_sf(xlim =c(-180, 180), ylim = c(-90, 90)) +
    ggplot2::scale_x_discrete(expand = c(0, 0)) +
    ggplot2::scale_y_discrete(expand = c(0, 0)) +
    sc +
    ggplot2::labs(x = NULL, y = NULL)
  if (!is.null(points)) {
    base +
      ggplot2::geom_point(
        data = points,
        ggplot2::aes(geometry = .data$geometry),
        stat = "sf_coordinates",
        color = "black"
      )
  } else {
    base
  }
}
