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

  tb
}

format_coord <- function(NOAA, coord) {

  # split coords in long and lat
  coords <- strsplit(sf::st_as_text(NOAA$geometry), "[^[:alnum:]|.|-]+")
  coords <- Map(coords_df, coords)
  coords <- do.call(rbind, coords)

  # remove old geometry
  NOAA <- as.data.frame(NOAA)
  NOAA_sc <- NOAA[,which(colnames(NOAA) != "geometry"), drop = FALSE]

  # combine new
  cbind(NOAA_sc, coords)
}

coords_df <- function(x) {
  subset_x <- x[2:length(x)]
  data.frame(
    geometry = x[1],
    longitude = I(list(subset(subset_x, seq_along(subset_x) %% 2 != 0))),
    latitude = I(list(subset(subset_x, seq_along(subset_x) %% 2 == 0)))
  )
}
