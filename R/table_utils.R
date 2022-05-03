# table output formatting
format_table <- function(NOAA, parm, spat, temp) {

  # formatting
  tb <- format_coord(NOAA)

  # rename variable
  tb_nm <- colnames(tb)
  tb_nm[1] <- parm
  colnames(tb) <- tb_nm

  # add spatial and temporal resolution of variable
  tb[["spatial"]] <- spat
  tb[["temporal"]] <- temp

  print(tb, row.names = FALSE)
}

format_coord <- function(NOAA, coord) {

  # split coords in long and lat
  coords <- strsplit(sf::st_as_text(NOAA$geometry), "[^[:alnum:]|.|-]+")
  coords <- do.call(Map, c(f = c, coords)) |>
    stats::setNames(c("geometry", "longitude", "latitude"))

  # remove old geometry
  NOAA <- as.data.frame(NOAA)
  NOAA_sc <- NOAA[,which(colnames(NOAA) != "geometry"), drop = FALSE]

  # combine new
  cbind(NOAA_sc, coords)
}
