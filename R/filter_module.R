#' NOAA filter module
#'
#' @param id Namespace id shiny module.
#' @param NOAA Reactive value of NOAA dataset.
#' @param plot Add plot display in UI
#' @param variable Reactive value for the selected variable name.
#'
#' @return Shiny module.
#' @export
filter_ui <- function(id, plot) {

  tagList(
    fluidRow(
      column(
        width = 5,
        shinyFeedback::useShinyFeedback(),
        textInput(
          NS(id, "depth"),
          h5("depth (meter)"),
          "0"
        )
      ),
      column(
        width = 5,
        shinyFeedback::useShinyFeedback(),
        textInput(
          NS(id, "lon"),
          h5("longitude (degrees)"),
          NULL,
          placeholder = "number or comma delimited vector"
        )
      )
    ),
    fluidRow(
      column(
        width = 5,
        shinyFeedback::useShinyFeedback(),
        textInput(
          NS(id, "lat"),
          h5("latitude (degrees)"),
          NULL,
          placeholder = "number or comma delimited vector"
        )
      ),
      column(
        width = 5,
        selectizeInput(
          NS(id, "geom"),
          h5("geometry"),
          choices = "point"
        )
      )
    ),
    actionButton(NS(id, "extract"), label = h5("Extract location(s)")),
    actionButton(NS(id, "reset"), label = h5("Reset")),
    actionButton(NS(id, "back"), label = h5("Back")),
    plot,
    sliderInput(
      NS("depth", "slide"),
      h5("depth (meter)"),
      min = 0,
      max = 3000,
      value = 0,
      width = "80%"
    )
  )
}
#' @rdname filter_ui
#'
#' @export
filter_server <- function(id, NOAA, variable, external) {

  stopifnot(is.reactive(NOAA))

  moduleServer(id, function(input, output, session) {

    # slider filter
    x <- reactive({
      req(input$slide)
      filter_NOAA(NOAA(), input$slide)
      })

    # coordinates
    y <- eventReactive(input$extract, {

      input2 <- purrr::map(
        c("depth", "lon", "lat"),
        ~scan(textConnection(input[[.x]]), sep = ",", quiet = TRUE)
        ) %>%
        rlang::set_names(c("depth", "lon", "lat"))


      # if selected on plot, replace values for lon and lat
      if(isTruthy(external$lon)) input2$lon <- external$lon
      if(isTruthy(external$lat) )input2$lat <- external$lat

      # update slider
      updateSliderInput(inputId = "slide", value = isolate(tail(input2$depth, 1)))

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

      if (
        dplyr::between(req(input2$depth), 0, 3000) &&
        dplyr::between(req(input2$lon), -179, 180) &&
        dplyr::between(req(input2$lat), -89, 90)
        ) {
        filter_NOAA(NOAA(), input2$depth,
                    list(lon = input2$lon, lat = input2$lat))
      }

    })

    # table
    z <- reactive({
      req(y())
      tb <- tibble::as_tibble(y()) %>%
        dplyr::mutate(coordinates = sf::st_as_text(.data$geometry), .keep = "unused")
      # rename variable
      tb_nm <- colnames(tb)
      tb_nm[1] <- variable()
      colnames(tb) <- tb_nm
      tb
      })

    # reset all
    observeEvent(input$reset, {
      updateTextInput(inputId = "lon", value = NA_character_, placeholder = "number or comma delimited vector")
      updateTextInput(inputId = "lat", value = NA_character_, placeholder = "number or comma delimited vector")
      updateSliderInput(inputId = "slide", value = 0)
    })

    # reset text input when plot input is selected
    observeEvent(external$lon | external$lat, {
      updateTextInput(inputId = "lon", value = NA_character_, placeholder = "number or comma delimited vector")
      updateTextInput(inputId = "lat", value = NA_character_, placeholder = "number or comma delimited vector")
    })

    # slider to depth update
    observeEvent(input$slide, {
      updateSliderInput(inputId = "depth", value = isolate(input$slide))
    },
    ignoreInit = TRUE
    )



    list(map = x, coord = y, table = z, back = reactive(input$back), reset = reactive(input$reset), depth_slider = reactive(input$slide))
  })
}
