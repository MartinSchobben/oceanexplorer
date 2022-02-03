test_that("plot of NOAA atlas works", {
  NOAAatlas <- get_NOAA("oxygen", 1, "annual")
  # just depth
  base <- filter_NOAA(NOAAatlas, 1)
  # points
  points <- filter_NOAA(NOAAatlas, 1, list(lon = c(-160, -120), lat =  c(11,12)))
  vdiffr::expect_doppelganger("NOAA word map", plot_NOAA(base, points))
  vdiffr::expect_doppelganger("NOAA arctic map", plot_NOAA(base, points, epsg = 3995))
  vdiffr::expect_doppelganger("NOAA antarctic map", plot_NOAA(base, points, epsg = 3031))
})

test_that("box clipping works for stars",{
  NOAAatlas <- get_NOAA("oxygen", 1, "annual")
  # just depth
  base <- filter_NOAA(NOAAatlas, 1)
  expect_snapshot(clip_lat(base, 3031))
})

test_that("box clipping works for sf",{
  # sf world map
  wmap <- maps::map("world", wrap = c(-180, 180), plot = FALSE, fill = TRUE) %>%
    sf::st_as_sfc() %>%
    sf::st_transform(crs = sf::st_crs(NOAA)) %>%
    sf::st_wrap_dateline(options = c("WRAPDATELINE=YES", "DATELINEOFFSET=180"))
  clip_lat(wmap, 3031)
})


