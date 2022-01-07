#' NOAA filter module
#'
#' @param id Namespace id shiny module.
#' @param NOAA Reactive value of NOAA dataset.
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
          NULL,
          placeholder = "number or comma delimited vector"
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
filter_server <- function(id, NOAA, variable) {

  stopifnot(is.reactive(NOAA))

  moduleServer(id, function(input, output, session) {

    # map filter
    x <- reactive({
      req(input$slide)
      filter_NOAA(NOAA(), input$slide)
      })

    # coordinates
    y <- eventReactive(input$extract, {

      input2 <- purrr::map(
        c("depth", "lon", "lat"),
        ~scan(textConnection(input[[.x]]), sep = ",")
        ) %>%
        rlang::set_names(c("depth", "lon", "lat"))

      # update slider
      updateSliderInput(inputId = "slide", value = isolate(tail(input2$depth, 1)))

      shinyFeedback::feedbackWarning(
        "depth",
        !input2$depth %in% 0:3000,
        "Please choose a number between 0 and 3000"
      )
      shinyFeedback::feedbackWarning(
        "lon",
        !input2$lon %in% seq(-179, 180, 1e-2),
        "Please choose a number between -179 and 180"
      )

      shinyFeedback::feedbackWarning(
        "lat",
        !input2$lat %in% seq(-89, 90, 1e-2),
        "Please choose a number between -89 and 90"
      )

      if (
        req(input2$depth) %in% 0:3000 &&
        req(input2$lon) %in% seq(-179, 180, 1e-2) &&
        req(input$lat) %in% seq(-89, 90, 1e-2)
        ) {
        filter_NOAA(NOAA(), input2$depth,
                    list(lon = input2$lon, lat = input2$lat))
      }

    })

    # table
    z <- reactive({
      req(y())
      tb <- tibble::as_tibble(y()) %>%
        dplyr::mutate(coordinates = sf::st_as_text(geometry), .keep = "unused")
      # rename variable
      tb_nm <- colnames(tb)
      tb_nm[1] <- variable()
      colnames(tb) <- tb_nm
      tb
      })

    # reset
    observeEvent(input$reset, {
      updateTextInput(inputId = "depth", value = NULL, placeholder = "number or comma delimited vector")
      updateTextInput(inputId = "lon", value = NULL, placeholder = "number or comma delimited vector")
      updateTextInput(inputId = "lat", value = NULL, placeholder = "number or comma delimited vector")
      updateSliderInput(inputId = "slide", value = 0)
    })

    observeEvent(input$slide, {
      updateSliderInput(inputId = "depth", value = isolate(input$slide))
    },
    ignoreInit = TRUE
    )

    list(map = x, coord = y, table = z)
  })
}
