library(shinytest)

test_that("module for plotting works", {
  # Don't run these tests on the CRAN build servers
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  # Use compareImages=FALSE because the expected image screenshots were created
  # on a Mac, and they will differ from screenshots taken on the CI platform,
  # which runs on Linux.
  appdir <- system.file(package = "shinymods", "appdir", "plot_module")
  shinytest::expect_pass(shinytest::testApp(appdir, compareImages = FALSE))
})

