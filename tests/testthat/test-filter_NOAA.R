test_that("check output type", {
  NOAAatlas <- get_NOAA("oxygen", 1, "annual")
  expect_s3_class(filter_NOAA(NOAAatlas, 1, list(lon = c(-160, -120), lat =  c(11,12))), "sf")
  expect_s3_class(filter_NOAA(NOAAatlas, c(1,30), list(lon = c(-160, -120), lat =  c(11,12))), "stars")
})
