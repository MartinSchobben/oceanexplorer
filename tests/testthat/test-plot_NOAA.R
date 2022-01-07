test_that("multiplication works", {
  NOAAatlas <- get_NOAA("oxygen", 1, "annual")
  # just depth
  base <- filter_NOAA(NOAAatlas, 1)
  # points
  points <- filter_NOAA(NOAAatlas, 1, list(lon = c(-160, -120), lat =  c(11,12)))
  plot_NOAA(base, points)
})
