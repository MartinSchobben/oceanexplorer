# NOAA <- reactiveVal(get_NOAA("oxygen", 1, "annual"))
# external <- reactiveValues(lon = NULL, lat = NULL, depth = 0)
# testServer(filter_server, args = list(NOAA = NOAA, external = external), {
#   # simulate text input + action
#   session$setInputs(lon = "-120, -130", lat = "10", depth = "10", extract = 1)
#
#   session$flushReact()
#   print(input2$lon)
#   print(input2$lat)
#   print(input2$depth)
#
#   # back
#   # session$setInputs(back = 1)
#   # print(input2$lon)
#   # print(input2$lat)
#   # print(input2$depth)
#
#   # reset
#   # print(input2$lon)
#   # print(input2$lat)
#   # print(input2$depth)
#
#
#   print(map())
#   print(coord())
#
# })

#
# test_that("text input + action button causes filtering", {
#
#   # initiate externals
#   NOAA <- reactiveVal()
#   external <- reactiveValues(lon = NULL, lat = NULL, depth = 0)
#   # launch text server
#   testServer(filter_server, args = list(NOAA = NOAA, external = external), {
#     NOAA(get_NOAA("oxygen", 1, "annual"))
#     external$depth <- 0
#     # update reactive graph to enable the externals
#     session$flushReact()
#     # simulate text input + action
#     session$setInputs(lon = "-120", lat = "10", depth = "10", extract = 1)
#
#
#     # test
#     expect_equal(input2$lon, -120)
#     expect_equal(input2$lat, 10)
#     expect_equal(input2$depth, 10)
#
#     expect_s3_class(map(), "stars")
#     expect_snapshot(map())
#     # expect_s3_class(coord(), "sf")
#     # expect_snapshot(coord())
#
#     # output
#
#   })
# })
#
#
