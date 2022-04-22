library(shinytest)


test_that("consistent performance of NOAA_app", {

  skip_on_cran()
  skip_on_ci()
  skip_if_offline()
  skip(TRUE)

  appdir <- test_path("apps", "NOAA_app")
  expect_pass(testApp(appdir, compareImages = FALSE))
})

