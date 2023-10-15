test_that("plot of NOAA atlas works", {

  # for CRAN and CI
  skip_on_ci()
  skip_on_cran()
  skip_on_covr()
  skip_if_offline()

  # get data
  try(NOAA <- get_NOAA("oxygen", 1, "annual"), silent = TRUE)

  # skip if not obtained
  skip_if_not(exists("NOAA"))

  # points
  crds <- list(lon = c(-160, -120), lat =  c(11,12))
  points <- filter_NOAA(NOAA, 1, crds)

  # original epsg
  vdiffr::expect_doppelganger(
    "NOAA word map epsg = NULL",
    plot_NOAA(NOAA, depth = 0, points = points, epsg = NULL)
  )
  vdiffr::expect_doppelganger(
    "NOAA word map epsg = 'original'",
    plot_NOAA(NOAA, depth = 0, points = points, epsg = "original")
  )

  # new projections
  vdiffr::expect_doppelganger(
    "NOAA word map epsg = '4326'",
    plot_NOAA(NOAA, depth = 0, points = points, epsg = "4326")
  )
  vdiffr::expect_doppelganger(
    "NOAA arctic map epsg = 3995",
    plot_NOAA(NOAA, depth = 0, epsg = 3995)
  )
  vdiffr::expect_doppelganger(
    "NOAA antarctic map epsg = 3031",
    plot_NOAA(NOAA, depth = 0, epsg = 3031)
  )

  # fuzzy search table
  crds_polygon <- list(lon = c(-52.79878), lat = c(47.72121))
  points_polygon <- filter_NOAA(NOAA, 1, crds_polygon, fuzzy = 100)
  vdiffr::expect_doppelganger(
    "plot polygons",
    plot_NOAA(NOAA, depth = 0, points = points_polygon , epsg = "original")
  )
})

test_that("box clipping works for stars",{

  # for CRAN and CI
  skip_on_ci()
  skip_on_cran()
  skip_on_covr()
  skip_if_offline()

  # get data
  try(NOAA <- get_NOAA("oxygen", 1, "annual"), silent = TRUE)

  # skip if not obtained
  skip_if_not(exists("NOAA"))

  # just depth
  NOAA <- filter_NOAA(NOAA)

  expect_snapshot(
    clip_lat(NOAA, 3031)
  )
})

test_that("box clipping works for sf",{

  # for CRAN and CI
  skip_on_ci()
  skip_on_cran()
  skip_on_covr()
  skip_if_offline()

  # get data
  try(NOAA <- get_NOAA("oxygen", 1, "annual"), silent = TRUE)

  # skip if not obtained
  skip_if_not(exists("NOAA"))

  # sf world map
  wmap <- maps::map("world", wrap = c(-180, 180), plot = FALSE, fill = TRUE) |>
    sf::st_as_sf() |>
    sf::st_transform(crs = sf::st_crs(NOAA))

  expect_snapshot(
    clip_lat(wmap, 3031)
  )
})
