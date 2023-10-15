test_that("reprojection works", {

  # for CRAN
  skip_on_cran()
  skip_if_offline()

  # get data
  try(NOAAatlas <- get_NOAA("oxygen", 1, "annual"), silent = TRUE)

  # skip if not obtained
  skip_if_not(exists("NOAAatlas"))

  # points
  points <- filter_NOAA(NOAAatlas, 1, list(lon = c(-160, -120), lat =  c(11,12)))

  wmap <- maps::map("world", wrap = c(-180, 180), plot = FALSE, fill = TRUE) |>
    sf::st_as_sf()

  # return object as is
  expect_equal(
    reproject(NOAAatlas, NULL),
    NOAAatlas
  )
  expect_equal(
    reproject(NOAAatlas, ""),
    NOAAatlas
  )
  expect_equal(
    reproject(NOAAatlas, "original"),
    NOAAatlas
  )
  expect_equal(
    reproject(NOAAatlas, sf::st_crs(NOAAatlas)),
    NOAAatlas
  )

#   # return with new epsg (stars in and stars out)
#   expect_equal(
#     reproject(NOAAatlas, 4326),
#     stars::st_warp(NOAAatlas, crs = 4326)
#   )
#   expect_equal(
#     reproject(NOAAatlas, "4326"),
#     stars::st_warp(NOAAatlas, crs = 4326)
#   )
#   expect_equal(
#     reproject(NOAAatlas, 3031),
#     stars::st_warp(NOAAatlas, crs = 3031)
#   )
#   expect_equal(
#     reproject(NOAAatlas, 3031),
#     stars::st_warp(NOAAatlas, crs = 3031)
#   )
#
#   # return with new epsg (sf in and sf out)
#   expect_equal(
#     reproject(points, 3031),
#     sf::st_transform(points, crs = 3031)
#   )
#   expect_equal(
#     reproject(wmap, 3031),
#     sf::st_transform(points, crs = 3031)
#   )
})


test_that("epsg check is consitent", {

  # for CRAN
  skip_on_cran()
  skip_if_offline()

  # get data
  try(NOAAatlas <- get_NOAA("oxygen", 1, "annual"), silent = TRUE)

  # skip if not obtained
  skip_if_not(exists("NOAAatlas"))

  # points
  crds <- list(lon = c(-160, -120), lat =  c(11,12))
  points <- filter_NOAA(NOAAatlas, 1, crds)

  wmap <- maps::map("world", wrap = c(-180, 180), plot = FALSE, fill = TRUE) |>
    sf::st_as_sf() |>
    sf::st_transform(crs = 4326)

  # original
  expect_equal(
    epsg_check(NOAAatlas, character(1)),
    "original"
  )
  expect_equal(
    epsg_check(NOAAatlas, "original"),
    "original"
  )
  expect_equal(
    epsg_check(NOAAatlas, NULL),
    "original"
  )

  expect_equal(
    epsg_check(wmap, 4326),
    "original"
  )
  expect_equal(
    epsg_check(wmap, "4326"),
    "original"
  )

  # different
  expect_equal(
    epsg_check(NOAAatlas, sf::st_crs(3031)),
    sf::st_crs(3031)
  )
  expect_equal(
    epsg_check(NOAAatlas, "3031"),
    3031
  )
  expect_equal(
    epsg_check(NOAAatlas, 3031),
    3031
  )

  # error
  expect_error(
    epsg_check(NOAAatlas, 303),
    "Unknown format supplied to epsg."
  )
  expect_error(
    epsg_check(NOAAatlas, "303"),
    "Unknown format supplied to epsg."
  )
})

test_that("stereographic projections plot click values can be converted", {
  expect_snapshot(
    convert_stereo(9332793, 7376573, 3031)
  )
})

test_that("point is clipped when re-projected to 3031", {

  # for CRAN
  skip_on_cran()
  skip_if_offline()

  # get data
  try(NOAA <- get_NOAA("temperature", 1, "annual"), silent = TRUE)

  # skip if not obtained
  skip_if_not(exists("NOAA"))

  # coords
  lon <- c(-116.3041, 117.12998)
  lat <- c(-31.98888, 17.39477)

  # filter
  points <- filter_NOAA(NOAA, depth = 0, coord = cbind(lon, lat))
  expect_snapshot(
    clip_lat(points, "3031")
  )
})
