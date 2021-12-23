#' NOAA filter module
#'
#' @param id Namespace id shiny module.
#' @param NOAA Reactive value of NOAA dataset.
#'
#' @return Shiny module.
#' @export
filter_ui <- function(id) {

  tagList(
    sliderInput(
      NS(id, "depth"),
      h5("depth (meter below sealevel)"),
      min = 0,
      max = 1000,
      value = 0,
      width = "100%"
    )
  )
}
#' @rdname filter_ui
#'
#' @export
filter_server <- function(id, NOAA) {

  stopifnot(is.reactive(NOAA))

  moduleServer(id, function(input, output, session) {

    reactive({
      start_depth <- stars::st_dimensions(NOAA())$depth$values$start
      dplyr::slice(NOAA(), "depth", findInterval(input$depth, start_depth))
    })

  })
}
