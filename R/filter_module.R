#' NOAA filter module
#'
#' @param id Namespace id shiny module.
#' @param NOAA Reactive value of NOAA dataset.
#' @param citation Additional space for citation element.
#' @param variable Reactive value for the selected variable name.
#' @param external Reactive value for filter operation based on plot selection.
#' @param extended Boolean whether to build the extended module
#'  (default = `TRUE`).
#'
#' @return Shiny module.
#' @export
filter_ui <- function(id, citation, extended = TRUE) {

  coords <- tagList(
    textInput(
      NS(id, "depth"),
      h5("Depth"),
      NULL,
      placeholder = "number or comma delimited vector"
    ),
    textInput(
      NS(id, "lon"),
      h5("Longitude"),
      NULL,
      placeholder = "number or comma delimited vector"
    ),
    textInput(
      NS(id, "lat"),
      h5("Latitude"),
      NULL,
      placeholder = "number or comma delimited vector"
    ),
    selectizeInput(
      NS(id, "geom"),
      h5("Geometry        "),
      choices = "point"
    )
  )

  buttons <- tagList(
    tags$br(),
    tags$br(),
    actionButton(NS(id, "extract"), label = h5("Extract location(s)")),
    actionButton(NS(id, "reset"), label = h5("Reset")),
    actionButton(NS(id, "back"), label = h5("Back"))
  )

  if (isTRUE(extended)) {
    layout <- tagList(
      fluidRow(
        shinyFeedback::useShinyFeedback(),
        column(6, coords[[1]], coords[[2]]),
        column(6, coords[[3]], coords[[4]])
      )
    )
    tagAppendChildren(layout, buttons)
  } else {
    buttons[-3]
  }
}
#' @rdname filter_ui
#'
#' @export
filter_server <- function(id, NOAA, external, extended = TRUE) {

  stopifnot(is.reactive(NOAA))

  moduleServer(id, function(input, output, session) {

    # store input in custom `reactivalues`
    input2 <- reactiveValues(depth = NULL, lon = NULL, lat = NULL)

    # extract text input + action and validate input
    observeEvent(input$extract, {

      if (isTRUE(extended)) {

      # convert text to numeric values
      purrr::walk(
        c("depth", "lon", "lat"),
        ~{input2[[.x]] <- scan(textConnection(input[[.x]]), sep = ",", quiet = TRUE)}
      )

      # warnings for explicit coord input
      shinyFeedback::feedbackWarning(
        "depth",
        !dplyr::between(input2$depth, 0, 3000),
        "Please choose a number between 0 and 3000"
      )
      shinyFeedback::feedbackWarning(
        "lon",
        !dplyr::between(input2$lon, -179, 180),
        "Please choose a number between -179.00 and 180.00"
      )
      shinyFeedback::feedbackWarning(
        "lat",
        !dplyr::between(input2$lat, -89, 90),
        "Please choose a number between -89.00 and 90.00"
      )
      }
    })

    # clicked points
    observeEvent(external$lon | external$lat | external$depth, {

      if (isTruthy(external$lon)) input2$lon <- external$lon
      if (isTruthy(external$lat)) input2$lat <-  external$lat
      if (isTruthy(external$depth)) input2$depth <- external$depth

    })


    observe(message(glue::glue("{input2$lat}, {input2$lon}, {input2$depth}")))
    observe(message(glue::glue("{str(coord())}")))

    # slider filter
    map <- reactive({
      req(external$depth)
      filter_NOAA(NOAA(), external$depth)
      })

    # coordinate extraction
    extract <- reactive({
      if (
        dplyr::between(req(input2$depth), 0, 3000) &&
        dplyr::between(req(input2$lon), -179, 180) &&
        dplyr::between(req(input2$lat), -89, 90)
        ) {

        # execute
        filter_NOAA(NOAA(), input2$depth, list(lon = input2$lon, lat = input2$lat))
      }
    })


    # store coordinate points
    coord <- reactiveVal(NULL)
    observeEvent(extract(), {
      if (is.null(extract())) {
        coord(extract())
      } else {
        coord(dplyr::bind_rows(coord(), extract()))
      }
    })

    # delete one coordinate point
    observeEvent(input$back, {
      coord(dplyr::rows_delete(coord(), tail(coord(), 1), by = colnames(coord())))
    })

    # delete all coordinate points
    observeEvent(input$reset, {
      coord(NULL)
    })


    if (isTRUE(extended)) {
      # reset all by button click or reset text input when plot input is selected
      observeEvent(input$reset | external$lon | external$lat | external$depth, {
        updateTextInput(inputId = "lon", value = character(0), placeholder = "number or comma delimited vector")
        updateTextInput(inputId = "lat", value = character(0), placeholder = "number or comma delimited vector")
        updateTextInput(inputId = "depth", value = character(0), placeholder = "number or comma delimited vector")
      })
    }

    # return
    list(map = map, coord = coord, code = code)
  })
}


