test_that("consistent performance of NOAA_app", {

  # for CRAN and CI
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()
  skip_on_covr()
  skip("Use for manual checks")

  appdir <- test_path("apps", "NOAA_app")
  shinytest::expect_pass(shinytest::testApp(appdir, compareImages = FALSE))
})

