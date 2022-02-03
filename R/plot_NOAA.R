#' Plotting the global NOAA WORLD OCEAN ATLAS
#'
#' @param NOAA Dataset of the WORLD OCEAN ATLAS.
#' @param points Add locations of extracted point geometry.
#' @param epsg The epsg used to project the data.
#' @param limit The limits of the axis.
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
plot_NOAA <- function(NOAA, points = NULL, epsg = NULL, limit = NULL) {

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

  # epsg NULL then use NOAA standard (?9122)
  if (is.null(epsg) || epsg == "original") {
    epsg <- sf::st_crs(NOAA)
  } else {
    epsg <- as.numeric(epsg)
  }

  if (is.null(limit)) limit <- 90

  # standard limits method sf coord
  lim_method <- "cross"
  # world map
  wmap <- maps::map("world", wrap = c(-180, 180), plot = FALSE, fill = TRUE) %>%
    sf::st_as_sfc() %>%
    sf::st_transform(crs = epsg)

  # coord transform NOAA and selected points if different from origin
  if (epsg != sf::st_crs(NOAA)) {

    if (!is.null(points)) points <- sf::st_transform(points, crs = epsg)

    # antarctic (3031) and arctic (3995) projection are clipped at -55 and 55 degree lat
    if (epsg == 3031 | epsg == 3995) {
      if (limit == 90) {
        #message("If epsg is 3031 and 3995, the latitude range is set to 55")
        limit <- 50
        }

      # method for plotting coords
      lim_method <- "geometry_bbox"

      # cropping
      NOAA <- clip_lat(NOAA, epsg, limit)
      wmap <- clip_lat(wmap, epsg, limit)
    }
    NOAA <- sf::st_transform(NOAA, crs = epsg)

  }

  base <- ggplot2::ggplot() +
    stars::geom_stars(data = NOAA) +
    ggplot2::geom_sf(data = wmap, fill = "grey")

  if (!is.null(points)) {
    base <- base +
      ggplot2::geom_sf(data = points)
  }

  base + ggplot2::coord_sf(
    lims_method = lim_method,
    xlim = c(-180, 180),
    ylim = c(-1 * limit, limit),
    default_crs = epsg,
    crs = epsg,
    expand = FALSE
    ) +
    ggplot2::scale_fill_viridis_c(xc, na.value = "transparent") +
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
    sf::st_transform(obj, epsg) # re-projection
  # for sf object we first need re-projection and then cropping
  } else if (inherits(obj, "sfc")) {
    obj <- sf::st_transform(obj, epsg) # re-projection
    circ <- sf::st_bbox(sf::st_point(c(0,0))) %>% # center aroung pole
      sf::st_as_sfc() %>%
      sf::st_as_sf(crs = sf::st_crs(obj)) %>% # albers projection to have an projected crs
      sf::st_buffer(4000000) # draw circle
    sf::st_crop(sf::st_make_valid(obj), circ) # cropping (make valid repairs the world map)

}
}
