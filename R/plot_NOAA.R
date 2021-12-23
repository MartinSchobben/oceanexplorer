#' Plotting the global NOAA WORLD OCEAN ATLAS
#'
#' @param NOAA Dataset of the WORLD OCEAN ATLAS.
#'
#' @return Ggplot
#' @export
#'
#' @examples
#' \dontrun{
#' get_NOAA("oxygen", 1, "annual", 2001) %>% plot_NOAA()
#' }
plot_NOAA <- function(NOAA) {

  # get species / parameter names
  var <- stringr::str_sub(attributes(NOAA)$names, 1, 1)
  element <- c(i = "SiO", p = "PO", o = "O", n = "NO")
  index <- c(i = 2, p = 4, o = 2, n = 3)

  ggplot2::ggplot() +
    stars::geom_stars(data = NOAA [1]) +
    ggplot2::coord_sf(xlim =c(-180, 180), ylim = c(-90, 90)) +
    ggplot2::scale_x_discrete(expand = c(0, 0)) +
    ggplot2::scale_y_discrete(expand = c(0, 0)) +
    ggplot2::scale_fill_viridis_c(substitute(a[b]~"("*mu*"mol kg"^{"-"}*")", list(a = element[var], b = index[var]))) +
    # ggplot2::guides(fill = ggplot2::guide_colourbar(barwidth = 5, barheight = 0.5)) +
    ggplot2::labs(x = NULL, y = NULL)
}
