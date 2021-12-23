test_that("parsing urls", {
  expect_equal(
    url_parser("oxygen", 1, 2000),
    "https://data.nodc.noaa.gov/thredds/dodsC/ncei/woa/oxygen/all/1.00/woa18_all_o00_01.nc"
    )
  expect_equal(
    url_parser("oxygen", 5, 2000),
    "https://data.nodc.noaa.gov/thredds/dodsC/ncei/woa/oxygen/all/5deg/woa18_all_o00_5d.nc"
  )
})

test_that("get NOAA data", {
  expect_error(
    get_NOAA("oxygen", 5, "annual", 2001),
    "Annual records do not exist for the 5 degrees lattice."
  )
})
