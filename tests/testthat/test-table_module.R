NOAA <- reactiveVal(get_NOAA("oxygen", 1, "annual") %>%
                      filter_NOAA(30, list(lat = 10, lon= -120)))


variable <- reactiveVal("oxygen")
vars <- list(NOAA = NOAA, variable = variable)

testServer(table_server, args = vars, {

  print(variable())
  print(NOAA())

  print(pretty_table())

})


test_that("table is formatted correctly", {

  # filtered data
  fl_NOAA <- get_NOAA("oxygen", 1, "annual") %>%
    filter_NOAA(30, list(lat = 10, lon= -120))

  # initiate externals
  NOAA <- reactiveVal(NULL)
  variable <- reactiveVal(NULL)
  vars <- list(NOAA = NOAA, variable = variable)
  # launch text server
  testServer(table_server, args = vars, {
    # reactivals
    NOAA(fl_NOAA)
    variable("oxygen")

    # update reactive graph to enable the externals
    session$flushReact()

    # test
    expect_snapshot(output$table)

  })
})



