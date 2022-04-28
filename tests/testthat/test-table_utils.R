test_that("reformatted table works", {
  NOAA <- get_NOAA("oxygen", 1, "annual") |>
    filter_NOAA(30, list(lat = c(10.12, 12), lon= c(-130, -120.54)))
  expect_snapshot(format_table(NOAA, "oxygen"))
})
