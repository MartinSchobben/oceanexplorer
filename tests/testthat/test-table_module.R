test_that("table is formatted correctly", {

  # filtered data
  fl_NOAA <- get_NOAA("oxygen", 1, "annual") |>
    filter_NOAA(30, list(lon = -120, lat = -10))

  # initiate externals
  NOAA <- reactiveVal(NULL)
  variable <- reactiveValues(parm = NULL, spat = NULL, temp = NULL)
  vars <- list(NOAA = NOAA, variable = variable)
  # launch text server
  testServer(table_server, args = vars, {
    # reactivaluess
    NOAA(fl_NOAA)
    variable$parm <- "oxygen"
    variable$spat<- 1
    variable$temp <- "annual"

    # update reactive graph to enable the externals
    session$flushReact()

    # test
    expect_snapshot(output$table)

  })
})

