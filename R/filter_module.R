#' NOAA filter module
#'
#' @param id Namespace id shiny module.
#' @param NOAA Reactive value of NOAA dataset.
#' @param plot Add plot display in UI
#' @param variable Reactive value for the selected variable name.
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
      "0"
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
    store <- reactiveVal(FALSE)
    observeEvent(input$extract, {
      req(y()$out)
      new <- rep(TRUE, nrow(y()$out))
      store(new)
      })
    # observeEvent(external$lon() ,{
    #   store(append(store(),FALSE))
    # })

    # slider filter
    x <- reactive({
      req(input$slide)
      filter_NOAA(NOAA(), input$slide)
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

        # update slider
        updateSliderInput(inputId = "slide", value = isolate(tail(input2$depth, 1)))

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

      # if selected on plot, replace values for lon and lat
      if (isFALSE(extended)) input2 <- list()
      if (isTruthy(external$lon)) input2$lon <- external$lon
      if (isTruthy(external$lat)) input2$lat <- external$lat


      if (
        dplyr::between(req(input$slide), 0, 3000) &&
        dplyr::between(req(input2$lon), -179, 180) &&
        dplyr::between(req(input2$lat), -89, 90) ||
        isTRUE(extended)
        ) {

        # filter call
        call_NOAA <- glue::glue("filter_NOAA(NOAA, depth = {input$slide}, \\
                                coord = list(lon = c({glue::glue_collapse(input2$lon\\
                                , sep = ', ')}), lat = c({glue::glue_collapse(\\
                                input2$lat, sep = ', ')})))")

        # execute
        exec_NOAA <- filter_NOAA(NOAA(), input$slide, list(lon = input2$lon, lat = input2$lat))

        # add column to identify whether point has been extracted or merely holds the spot
        exec_NOAA <- tibble::add_column(exec_NOAA, stored = store(), .after = .data$geometry)

        list(out = exec_NOAA , code = call_NOAA)
      }
    })

    observe(message(glue::glue("{str(y()$out)}")))

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


    # reset all
    observeEvent(input$reset, {
      if (isTRUE(extended)) {
        updateTextInput(inputId = "lon", value = NA_character_, placeholder = "number or comma delimited vector")
        updateTextInput(inputId = "lat", value = NA_character_, placeholder = "number or comma delimited vector")
      }
      updateSliderInput(inputId = "slide", value = 0)
    })

    # reset text input when plot input is selected
    if (isTRUE(extended)) {
      observeEvent(external$lon | external$lat, {
        updateTextInput(inputId = "lon", value = NA_character_, placeholder = "number or comma delimited vector")
        updateTextInput(inputId = "lat", value = NA_character_, placeholder = "number or comma delimited vector")
      })
    }

    # slider to depth update
    observeEvent(input$slide, {
      updateSliderInput(inputId = "depth", value = isolate(input$slide))
    },
    ignoreInit = TRUE
    )

    list(map = x, coord = reactive(y()$out), code = reactive(y()$code),  table = z, back = reactive(input$back),
         reset = reactive(input$reset), depth_slider = reactive(input$slide))
  })
}
