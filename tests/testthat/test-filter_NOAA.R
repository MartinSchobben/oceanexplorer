test_that("check output type", {
  NOAAatlas <- get_NOAA("oxygen", 1, "annual")
  expect_s3_class(filter_NOAA(NOAAatlas, 1, list(lon = c(-160, -120), lat =  c(11,12))), "sf")
  expect_s3_class(filter_NOAA(NOAAatlas, c(1,30), list(lon = c(-160, -120), lat =  c(11,12))), "sf")
})


test_that("multiple depth entries of the same index create new data output", {
  NOAA <- get_NOAA("temperature", 1, "annual")
  expect_snapshot(filter_NOAA(NOAA, depth = c(0, 0, 0), coord = list(lon = c(-116.3041, -40.58253, -9.306224), lat = c(-31.98888, 17.39477, -31.98888))))
})

test_that("entries other then vectors of 1 or the same length cause an error", {
  NOAA <- get_NOAA("temperature", 1, "annual")
  expect_error(
    filter_NOAA(NOAA, depth = c(0, 0, 0), coord = list(lon = c(-116.3041, 117), lat = c(-31.98888, 17.39477, -31.98888))),
    "Depth and coordinates must be a vector of length 1 or have consistent lengths."
  )
})
