test_that("module for data works", {

  # for CRAN and CI
  skip_on_cran()
  skip_on_ci()
  skip_on_covr()
  skip_if_offline()
  skip("Use for manual checks")

  appdir <- test_path("apps", "data_module")
  shinytest::expect_pass(shinytest::testApp(appdir, compareImages = FALSE))
})
