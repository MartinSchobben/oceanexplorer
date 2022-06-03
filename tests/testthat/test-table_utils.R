test_that("reformatted table works", {

  # get data and filter
  NOAA <- get_NOAA("oxygen", 1, "annual") |>
    filter_NOAA(30, list(lon= c(-130, -120.54), lat = c(10.12, 12)))

  # test table format
  expect_snapshot(
    format_table(NOAA, "oxygen", 1, "annual")
  )
})
