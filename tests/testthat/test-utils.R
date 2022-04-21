test_that("reprojection works", {

  NOAAatlas <- get_NOAA("oxygen", 1, "annual")
  # points
  points <- filter_NOAA(NOAAatlas, 1, list(lon = c(-160, -120), lat =  c(11,12)))

  wmap <- maps::map("world", wrap = c(-180, 180), plot = FALSE, fill = TRUE) |>
    sf::st_as_sf()

  # return object as is
  expect_equal(
    reproject(NOAAatlas),
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

  # return with new epsg (stars in and stars out)
  expect_equal(
    reproject(NOAAatlas, 4326),
    stars::st_warp(NOAAatlas, crs = 4326)
  )
  expect_equal(
    reproject(NOAAatlas, "4326"),
    stars::st_warp(NOAAatlas, crs = 4326)
  )
  expect_equal(
    reproject(NOAAatlas, 3031),
    stars::st_warp(NOAAatlas, crs = 3031)
  )
  expect_equal(
    reproject(NOAAatlas, 3031),
    stars::st_warp(NOAAatlas, crs = 3031)
  )

  # return with new epsg (sf in and sf out)
  expect_equal(
    reproject(points, 3031),
    sf::st_transform(points, crs = 3031)
  )
  expect_equal(
    reproject(wmap, 3031),
    sf::st_transform(points, crs = 3031)
  )
})
