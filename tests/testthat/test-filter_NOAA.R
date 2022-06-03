test_that("check output type", {

  # get data
  NOAAatlas <- get_NOAA("oxygen", 1, "annual")

  # check classes
  expect_s3_class(
    filter_NOAA(NOAAatlas, 1, list(lon = c(-160, -120), lat =  c(11, 12))),
    "sf"
  )
  expect_s3_class(
    filter_NOAA(NOAAatlas, c(1,30), list(lon = c(-160, -120), lat =  c(11,12))),
    "sf"
  )
})

test_that("that different coord classes generate the same results", {

  # coordinates
  lon <- c(-116.3041, -40.58253, -9.306224)
  lat <- c(-31.98888, 17.39477, -31.98888)
  depth <- c(0, 0, 0)

  # coord supplied as sfc of point geometries
  sfc <- sf::st_as_sf(as.data.frame(cbind(lon, lat)), coords = c("lon", "lat"),
                      crs = 4326)

  # tests
  expect_snapshot(cast_coords(list(lon = lon, lat = lat)))
  expect_snapshot(cast_coords(cbind(lon, lat)))
  expect_snapshot(cast_coords(sfc, epsg = 4326))
  expect_snapshot(cast_coords(sfc, epsg = 3031))
})

test_that("entries other then vectors of 1 or the same length cause an error", {
  NOAA <- get_NOAA("temperature", 1, "annual")
  expect_error(
    coord_check(
      depth = c(0, 0, 0),
      coord = list(
        lon = c(-116.3041, 117),
        lat = c(-31.98888, 17.39477, -31.98888)
        )
      ),
    "Depth and coordinates must be a vector of length 1 or have consistent lengths."
  )
})

test_that("entries for class coords besides matrix, list and sfc throws error", {
  NOAA <- get_NOAA("temperature", 1, "annual")
  expect_error(
    filter_NOAA(
      NOAA,
      depth = 0,
      coord = data.frame(
        lon = c(-116.3041, 117),
        lat = c(-31.98888, 17.39477)
      )
    ),
    "Class supplied to `coord` unsupported."
  )
})

test_that("wrong names for matrices or list of coordinates causes an error", {

  # get data
  NOAA <- get_NOAA("temperature", 1, "annual")

  # wrong names for coordinate matrices and lists
  expect_error(
    filter_NOAA(NOAA, depth = 0, coord = list(lat = c(-116), lon = c(-31))),
    NULL
  )
  expect_error(
    filter_NOAA(NOAA, depth = 0, coord = cbind(lat = c(-116), lon = c(-31))),
    NULL
  )
})

test_that("check that epsg of depth plane and coordinates is similar", {

  # data
  NOAA <- get_NOAA("temperature", 1, "annual")

  # coords
  lon <- c(-116.3041, 117.12998)
  lat <- c(-31.98888, 17.39477)

  # for matrix coord
  plane_original <- filter_NOAA(NOAA, depth = 0)
  point_original <- filter_NOAA(NOAA, depth = 0, coord = cbind(lon, lat))
  plane_4326 <- filter_NOAA(NOAA, depth = 0, epsg = 4326)
  point_4326 <- filter_NOAA(NOAA, depth = 0, coord = cbind(lon, lat),
                            epsg = 4326)
  # tests
  expect_true(
    sf::st_crs(plane_original) == sf::st_crs(point_original)
  )
  expect_true(
    sf::st_crs(plane_4326) == sf::st_crs(point_4326)
  )

  # for list coord
  plane_original <- filter_NOAA(NOAA, depth = 0)
  point_original <- filter_NOAA(NOAA, depth = 0, coord = list(lon = lon,
                                                              lat = lat))
  plane_4326 <- filter_NOAA(NOAA, depth = 0, epsg = 4326)
  point_4326 <- filter_NOAA(NOAA, depth = 0, coord = list(lon = lon, lat = lat),
                            epsg = 4326)

  # tests
  expect_true(
    sf::st_crs(plane_original) == sf::st_crs(point_original)
  )
  expect_true(
    sf::st_crs(plane_4326) == sf::st_crs(point_4326)
  )

  # for sfc coord
  sfc_original <- sf::st_as_sf(
    as.data.frame(cbind(lon, lat)),
    coords = c("lon", "lat"),
    crs = sf::st_crs(NOAA)
  )
  sfc_4326 <- sf::st_as_sf(as.data.frame(cbind(lon, lat)),
                           coords = c("lon", "lat"), crs = 4326)
  plane_original <- filter_NOAA(NOAA, depth = 0)
  point_original <- filter_NOAA(NOAA, depth = 0, coord = sfc_original)
  plane_4326 <- filter_NOAA(NOAA, depth = 0, epsg = 4326)
  point_4326 <- filter_NOAA(NOAA, depth = 0, coord = sfc_4326, epsg = 4326)

  # tests
  expect_true(
    sf::st_crs(plane_original) == sf::st_crs(point_original)
  )
  expect_true(
    sf::st_crs(plane_4326) == sf::st_crs(point_4326)
  )
})

test_that("epsg conversion works with character vector", {
  NOAA <- get_NOAA("temperature", 1, "annual")
  expect_snapshot(
    filter_NOAA(
      NOAA,
      depth = 0,
      coord = list(
        lon = c(-116.3041, 117.12998),
        lat = c(-31.98888, 17.39477)
      ),
      epsg = "4326"
    )
  )
})

test_that("epsg conversion works with 'original' keyword", {
  NOAA <- get_NOAA("temperature", 1, "annual")
  expect_snapshot(
    filter_NOAA(
      NOAA,
      depth = 0,
      coord = list(
        lon = c(-116.3041, 117.12998),
        lat = c(-31.98888, 17.39477)
      ),
      epsg = "original"
    )
  )
})

test_that("extraction of coords can use fuzzy search", {

  skip_on_cran()
  skip_on_ci()

  NOAA <- get_NOAA("temperature", 1, "annual")
  plane <- filter_NOAA(NOAA, 0)
  coords1 <- cbind(lon = c(-116.30), lat =c(-31.98))
  coords2 <- cbind(lon = c(-52.79878), lat =c(47.72121))
  # should be just a point geom with value
  expect_snapshot(
    extract_coords(plane, coords1, 0, sf::st_crs(NOAA), 0)
  )
  # should be just a point geom with NA
  expect_snapshot(
    extract_coords(plane, coords2, 0, sf::st_crs(NOAA), 0)
  )
  # should be a polygon
  expect_snapshot(
    extract_coords(plane, coords2, 0, sf::st_crs(NOAA), 100)
  )
  # SHOULD BE BOTH GEOMS WITH VALUES
  expect_snapshot(
    extract_coords(plane, rbind(coords1, coords2), 0, sf::st_crs(NOAA), 100)
  )
})
