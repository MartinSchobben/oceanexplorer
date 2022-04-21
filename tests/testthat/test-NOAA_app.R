library(shinytest)

shinytest::recordTest(test_path("apps/NOAA_app/"))

test_that("consistent performance of NOAA_app", {
  # Don't run these tests on the CRAN build servers
  skip_on_cran()

  # Use compareImages=FALSE because the expected image screenshots were created
  # on a Mac, and they will differ from screenshots taken on the CI platform,
  # which runs on Linux.
  expect_pass(testApp(test_path("apps/NOAA_app/"), compareImages = FALSE))
})
