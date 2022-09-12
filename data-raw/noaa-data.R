## code to prepare `NOAA_data` dataset

library(tibble)

NOAA_data <- tibble(
  variable = c("temperature", "phosphate", "nitrate", "silicate", "oxygen",
  "salinity", "density"),
  unit = c("C", rep("micromol kg-1", 4), "", "kg m-3"),
  citation = c(
    vc_cite["temperature"],
    rep(vc_cite["nutrients"], 3),
    vc_cite["oxygen"],
    vc_cite["salinity"],
    vc_cite["density"]
  )
)

#save(NOAA_data, file = "data/NOAA_data.rda", ascii = TRUE, version = 3)
usethis::use_data(NOAA_data, overwrite = TRUE)
