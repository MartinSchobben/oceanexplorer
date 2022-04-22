test_that("plot of NOAA atlas works", {

  skip_on_ci()
  skip_on_cran()
  skip_if_offline()

  NOAAatlas <- get_NOAA("oxygen", 1, "annual")
  # points
  crds <- list(lon = c(-160, -120), lat =  c(11,12))
  points <- filter_NOAA(NOAAatlas, 1, crds)

  # original epsg
  vdiffr::expect_doppelganger(
    "NOAA word map epsg = NULL",
    plot_NOAA(NOAAatlas, depth = 0, points = points, epsg = NULL)
  )
  vdiffr::expect_doppelganger(
    "NOAA word map epsg = 'original'",
    plot_NOAA(NOAAatlas, depth = 0, points = points, epsg = "original")
  )

  # new projections
  vdiffr::expect_doppelganger(
    "NOAA word map epsg = '4326'",
    plot_NOAA(NOAAatlas, depth = 0, points = points, epsg = "4326")
  )
  vdiffr::expect_doppelganger(
    "NOAA arctic map epsg = 3995",
    plot_NOAA(NOAAatlas, depth = 0, epsg = 3995)
  )
  vdiffr::expect_doppelganger(
    "NOAA antarctic map epsg = 3031",
    plot_NOAA(NOAAatlas, depth = 0, epsg = 3031)
  )
})

test_that("box clipping works for stars",{
  skip_on_ci()
  NOAAatlas <- get_NOAA("oxygen", 1, "annual")
  # just depth
  NOAAatlas <- filter_NOAA(NOAAatlas, 1)
  expect_snapshot(clip_lat(NOAAatlas, 3031))
})

test_that("box clipping works for sf",{
  skip_on_ci()
  NOAA <- get_NOAA("oxygen", 1, "annual")
  # sf world map
  wmap <- maps::map("world", wrap = c(-180, 180), plot = FALSE, fill = TRUE) %>%
    sf::st_as_sfc() %>%
    sf::st_transform(crs = sf::st_crs(NOAA))
  expect_snapshot(clip_lat(wmap, 3031))
})
