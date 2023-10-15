test_that("table is formatted correctly", {

  # for CRAM
  skip_if_offline()
  skip_on_cran()

  # filtered data
  try(dt_NOAA <- get_NOAA("oxygen", 1, "annual"), silent = TRUE)

  # skip if not obtained
  skip_if_not(exists("dt_NOAA"))

  # filter to 30 meters depth
  fl_NOAA <- filter_NOAA(dt_NOAA, 30, list(lon = -120, lat = -10))

  # initiate externals
  NOAA <- reactiveVal(NULL)
  variable <- reactiveValues(parm = NULL, spat = NULL, temp = NULL)
  vars <- list(NOAA = NOAA, variable = variable)

  # launch text server
  testServer(table_server, args = vars, {

    # reactivalues
    NOAA(fl_NOAA)
    variable$parm <- "oxygen"
    variable$spat <- 1
    variable$temp <- "annual"

    # update reactive graph to enable the externals
    session$flushReact()

    # test
    expect_snapshot(output$table)

  })
})

test_that("module for table works", {

  # for CRAN and CI
  skip_on_cran()
  skip_on_ci()
  skip_on_covr()
  skip_if_offline()
  skip("Use for manual checks")

  appdir <- test_path("apps", "table_module")
  shinytest::expect_pass(shinytest::testApp(appdir, compareImages = FALSE))
})

