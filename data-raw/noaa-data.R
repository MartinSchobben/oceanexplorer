## code to prepare `NOAA_data` dataset
library(tibble)
library(units)

NOAA_data <- tibble(
  variable = c("temperature", "phosphate", "nitrate", "silicate", "oxygen",
  "salinity", "density"),
  unit = c(
    paste0(intToUtf8(176), " C"),
    rep(paste0(intToUtf8(956), "mol kg-1"), 4),
    "",
    "kg m-3"
  )
)

usethis::use_data(NOAA_data, overwrite = TRUE)
