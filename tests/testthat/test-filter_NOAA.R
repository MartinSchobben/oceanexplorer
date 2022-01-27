test_that("check output type", {
  NOAAatlas <- get_NOAA("oxygen", 1, "annual")
  expect_s3_class(
    filter_NOAA(NOAAatlas, 1, list(lon = c(-160, -120), lat =  c(11,12))),
    "sf"
    )
  expect_s3_class(
    filter_NOAA(NOAAatlas, c(1,30), list(lon = c(-160, -120), lat =  c(11,12))),
    "sf"
    )
})


test_that("multiple depth entries of the same index create new data output", {
  NOAA <- get_NOAA("temperature", 1, "annual")
  expect_snapshot(
    filter_NOAA(
      NOAA,
      depth = c(0, 0, 0),
      coord = list(
        lon = c(-116.3041, -40.58253, -9.306224),
        lat = c(-31.98888, 17.39477, -31.98888)
        )
      )
    )
})

test_that("entries other then vectors of 1 or the same length cause an error", {
  NOAA <- get_NOAA("temperature", 1, "annual")
  expect_error(
    filter_NOAA(
      NOAA,
      depth = c(0, 0, 0),
      coord = list(
        lon = c(-116.3041, 117),
        lat = c(-31.98888, 17.39477, -31.98888)
        )
      ),
    "Depth and coordinates must be a vector of length 1 or have consistent lengths."
  )
})

test_that("crs will be transformed with new crs", {
  NOAA <- get_NOAA("temperature", 1, "annual")
  points <- sf::st_point(c(-160.123456789, 12.123456789))
  # apparently NOAA uses 4326 (not specified in NETCDF)
  expect_equal(
    transform_sfc(points, sf::st_crs(NOAA), 4326),
    transform_sfc(points, sf::st_crs(NOAA), NULL)
  )
  expect_false(
    isTRUE(
      all.equal(
      transform_sfc(points, sf::st_crs(NOAA), 4326),
      transform_sfc(points, sf::st_crs(NOAA), 3857)
      )
    )
  )
})

test_that("epsg conversion works", {
  NOAA <- get_NOAA("temperature", 1, "annual")
  expect_snapshot(
    filter_NOAA(
      NOAA,
      depth = 0,
      coord = list(
        lon = c(-116.3041, 117.12998),
        lat = c(-31.98888, 17.39477)
      ),
      epsg = 4326
    )
  )
})
