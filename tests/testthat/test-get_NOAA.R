test_that("parsing urls", {
  expect_equal(
    url_parser("oxygen", 1, "annual"),
    "https://data.nodc.noaa.gov/thredds/dodsC/ncei/woa/oxygen/all/1.00/woa18_all_o00_01.nc"
    )
  expect_equal(
    url_parser("oxygen", 1, "winter"),
    "https://data.nodc.noaa.gov/thredds/dodsC/ncei/woa/oxygen/all/1.00/woa18_all_o13_01.nc"
  )
  expect_equal(
    url_parser("temperature", 1, "August"),
    "https://data.nodc.noaa.gov/thredds/dodsC/ncei/woa/temperature/decav/1.00/woa18_decav_t08_01.nc"
  )
  expect_equal(
    url_parser("salinity", 5, "March"),
    "https://data.nodc.noaa.gov/thredds/dodsC/ncei/woa/salinity/decav/5deg/woa18_decav_s03_5d.nc"
  )
})

