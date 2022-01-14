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
    buttons
  }
}
#' @rdname filter_ui
#'
#' @export
filter_server <- function(id, NOAA, variable, external, extended = TRUE) {

  stopifnot(is.reactive(NOAA))

  moduleServer(id, function(input, output, session) {

    # store site (change geom point color)
    store <- reactiveVal(logical(0))
    observeEvent(input$extract, {
      req(y()$out)
      new <- rep(TRUE, nrow(y()$out))
      store(new)
      })
    observeEvent(external$lon | external$lat, {
      store(append(store(), FALSE))
    })


    # slider filter
    x <- reactive({
      req(external$depth)
      filter_NOAA(NOAA(), external$depth)
      })


    # coordinates
    y <- reactive({
      if (isTRUE(extended)) {

        # change text to numeric values for inout coords
        input2 <- purrr::map(
          c("depth", "lon", "lat"),
          ~scan(textConnection(input[[.x]]), sep = ",", quiet = TRUE)
          ) %>%
          rlang::set_names(c("depth", "lon", "lat"))

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
      message(glue::glue("{input2$lat}, {input2$lon}, {input2$depth}"))

      # if selected on plot, replace values for lon and lat
      if (isFALSE(extended)) input2 <- list()
      if (isTruthy(external$lon)) input2$lon <- external$lon
      if (isTruthy(external$lat)) input2$lat <- external$lat
      if (isTruthy(external$depth)) input2$depth <- external$depth

      if (
        dplyr::between(req(input2$depth), 0, 3000) &&
        dplyr::between(req(input2$lon), -179, 180) &&
        dplyr::between(req(input2$lat), -89, 90) ||
        isTRUE(extended)
        ) {

        # filter call
        call_NOAA <- glue::glue("filter_NOAA(NOAA, depth = {input2$depth}, \\
                                coord = list(lon = c({glue::glue_collapse(input2$lon\\
                                , sep = ', ')}), lat = c({glue::glue_collapse(\\
                                input2$lat, sep = ', ')})))")

        # execute
        exec_NOAA <- filter_NOAA(NOAA(), input2$depth, list(lon = input2$lon, lat = input2$lat))

        # add column to identify whether point has been extracted or merely holds the spot
        exec_NOAA <- tibble::add_column(exec_NOAA, stored = store(), .after = .data$geometry)

        list(out = exec_NOAA , code = call_NOAA)
      }
    })

    # table
    z <- eventReactive(input$extract, {
      req(y()$out)
      tb <- tibble::as_tibble(y()$out) %>%
        dplyr::mutate(coordinates = sf::st_as_text(.data$geometry), .keep = "unused")

      # rename variable
      tb_nm <- colnames(tb)
      tb_nm[1] <- variable()
      colnames(tb) <- tb_nm
      tb
      })


    # reset all by button click or reset text input when plot input is selected
    observeEvent(input$reset | external$lon | external$lat | external$depth, {
      if (isTRUE(extended)) {
        updateTextInput(inputId = "lon", value = NA_character_, placeholder = "number or comma delimited vector")
        updateTextInput(inputId = "lat", value = NA_character_, placeholder = "number or comma delimited vector")
        updateTextInput(inputId = "depth", value = NA_character_, placeholder = "number or comma delimited vector")
      }
    })

    list(
      map = x,
      coord = reactive(y()$out),
      code = reactive(y()$code),
      table = z,
      back = reactive(input$back),
      reset = reactive(input$reset)
      )
  })
}
