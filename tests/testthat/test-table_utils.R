test_that("reformatted table works", {

  # for CRAN
  skip_on_cran()
  skip_if_offline()

  # get data and filter
  try(NOAA <- get_NOAA("oxygen", 1, "annual"), silent = TRUE)

  # skip if not obtained
  skip_if_not(exists("NOAA"))

  # point selection
  NOAA_point <- filter_NOAA(NOAA, 30, list(lon = c(-130, -120.54), lat = c(10.12, 12)))

  # test table format
  expect_snapshot(
    format_table(NOAA_point, "oxygen", 1, "annual")
  )

  # fuzzy search table
  NOAA_polygon <- filter_NOAA(NOAA, 0, list(lon = c(-52.79878), lat = c(47.72121)), fuzzy = 100)

  # test table format
  expect_snapshot(
    format_table(NOAA_polygon, "oxygen", 1, "annual")
  )

})
