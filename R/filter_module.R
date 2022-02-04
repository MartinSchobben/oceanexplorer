#' NOAA filter module
#'
#' @param id Namespace id shiny module.
#' @param NOAA Reactive value of NOAA dataset.
#' @param external Reactive values for latitude, longitude and depth from plot
#'  module.
#' @param ivars Character vector for the variables for filtering.
#' @param extended Boolean whether to build the extended module
#'  (default = `TRUE`).
#'
#' @return Shiny module.
#' @export
filter_ui <- function(id, extended = TRUE) {

  coords <- tagList(
    textInput(NS(id, "depth"), h5("Depth"), NULL, placeholder = plch),
    textInput(NS(id, "lon"), h5("Longitude"),NULL, placeholder = plch),
    textInput(NS(id, "lat"), h5("Latitude"), NULL, placeholder = plch),
    selectInput(NS(id, "search"), h5("Search"), c("point", "fuzzy"), selected = "point")
  )

  buttons <- tagList(
    tags$br(),
    tags$br(),
    actionButton(NS(id, "extract"), label = h5("Extract")),
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

    # return
    tagAppendChildren(layout, buttons)
  } else {
    miniButtonBlock(buttons[[4]], buttons[[5]])
  }
}
#' @rdname filter_ui
#'
#' @export
filter_server <- function(id, NOAA, external, ivars = c("depth","lon", "lat"),
                          extended = TRUE) {

  stopifnot(is.reactive(NOAA))
  stopifnot(is.reactivevalues(external))

  moduleServer(id, function(input, output, session) {

    # store input in custom `reactivalues`
    input2 <- reactiveValues(depth = NULL, lon = NULL, lat = NULL)

    # toggle disable/enable  of `actionbutton` extract/reset/back locations
    observe({
      if (isTRUE(extended)) {
        shinyjs::toggleState("extract",all(purrr::map_lgl(ivars, ~{input[[.x]]!=""})))
      }
      shinyjs::toggleState("back", !is.null(coord()))
      shinyjs::toggleState("reset", !is.null(coord()))
    })

    if (isTRUE(extended)) {
      # extract text input + action and validate input
      observeEvent(input$extract, {

        # convert text to numeric values
        purrr::walk(
          ivars,
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
      })
    }

    # clicked points
    observeEvent(external$lon | external$lat | external$depth, {

      if (isTruthy(external$lon)) input2$lon <- external$lon
      if (isTruthy(external$lat)) input2$lat <-  external$lat
      if (isTruthy(external$depth)) input2$depth <- external$depth

    })

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
        filter_NOAA(
          NOAA(),
          input2$depth,
          list(lon = input2$lon, lat = input2$lat)
          )
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

    # delete previous extracted coordinate points by first storing the step length
    n_max <- reactiveVal(numeric(0))
    observe({
      # how many steps back? maximum depth of `input2`
      step <- lengths(reactiveValuesToList(input2))  %>% max()
      if (step > 0) n_max(c(isolate(n_max()), step))
    })
    # and then deleting the last observations
    observeEvent(input$back, {
      coord(dplyr::slice_head(coord(), n = nrow(coord()) - rev(n_max())[1]))
      # delete last n_max
      n_max(utils::head(n_max(), -1))
      # enable base map plotting (otherwise generates error)
      if (nrow(coord()) == 0) coord(NULL)
      purrr::walk(ivars, ~{input2[[.x]] <- NULL}) # set input to NULL
    })

    # delete all coordinate points by clicking reset of changing the dataset
    observe({
      input$reset
      NOAA()
      coord(NULL) # set stored data to NULL
      purrr::walk(ivars, ~{input2[[.x]] <- NULL}) # set input to NULL
    })

    # reset all by button click or reset text input when plot input is selected
    observeEvent(input$reset | input$back| external$lon | external$lat |
                   external$depth, {
      if (isTRUE(extended)) {
        updateTextInput(inputId = "lon", value = character(0), placeholder = plch)
        updateTextInput(inputId = "lat", value = character(0), placeholder = plch)
        updateTextInput(inputId = "depth", value = character(0), placeholder = plch)
      }
    })

    # return
    list(map = map, coord = coord, code = code)
  })
}

plch <- "number or comma delimited vector"
