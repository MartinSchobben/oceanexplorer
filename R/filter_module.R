#' NOAA filter module
#'
#' This shiny module (`filter_ui()` + `filter_server()`) allows filtering of
#' the currently loaded NOAA data via shiny `textInput()` interfaces.
#'
#' @inheritParams input_ui
#' @param external Reactive values for latitude, longitude and depth from plot
#'  module.
#' @param variable Reactivevalues for selected variable information.
#' @param ivars Character vector for the variables for filtering.
#'
#' @return Shiny module.
#' @export
#'
#' @examples
#'
#' # run filter module stand-alone
#' if (curl::has_internet() && interactive()) {
#'
#' library(oceanexplorer)
#' library(shiny)
#'
#' # data
#' NOAA <- get_NOAA("oxygen", 1, "annual")
#'
#' # gui
#' ui <- fluidPage(filter_ui("filter"), plot_ui("worldmap"))
#'
#' # server
#' server <-function(input, output, session) {
#'  # table
#'  filter <- filter_server(
#'   "filter",
#'   reactive(NOAA),
#'   external = reactiveValues(lon = 190, lat = 33, depth = 20),
#'   variable = reactiveValues(variable = "temperature")
#'  )
#'
#'  # plot data
#'  output_plot <- plot_server("worldmap", reactive(NOAA), filter$coord)
#'  }
#'
#'  # run app
#'  shinyApp(ui, server)
#'  }
filter_ui <- function(id, extended = TRUE) {

  coords <- tagList(
    actionLink(
      NS(id, "depthhelper"),
      "",
      icon = icon('question-circle', verify_fa = FALSE)
    ),
    textInput(
      NS(id, "depth"),
      h5("Depth"),
      NULL,
      placeholder = "meters"
    ),
    actionLink(
      NS(id, "lonhelper"),
      "",
      icon = icon('question-circle', verify_fa = FALSE)
    ),
    textInput(
      NS(id, "lon"),
      h5("Longitude"),
      NULL,
      placeholder = "degrees"
    ),
    actionLink(
      NS(id, "lathelper"),
      "",
      icon = icon('question-circle', verify_fa = FALSE)
    ),
    textInput(
      NS(id, "lat"),
      h5("Latitude"),
      NULL,
      placeholder = "degrees"
    ),
    actionLink(
      NS(id, "searchhelper"),
      "",
      icon = icon('question-circle', verify_fa = FALSE)
    ),
    selectInput(
      NS(id, "search"),
      h5("Search"),
      c("point", "fuzzy"),
      selected = "point"
    )
  )

  buttons <- tagList(
    tags$br(),
    tags$br(),
    actionButton(NS(id, "extract"), label = h5("Extract")),
    actionButton(NS(id, "reset"), label = h5("Reset")),
    actionButton(NS(id, "back"), label = h5("Back")),
    actionLink(
      NS(id, "selecthelper"),
      "",
      icon = icon('question-circle', verify_fa = FALSE)
    )
  )

  if (isTRUE(extended)) {
    layout <- tagList(
      fluidRow(
        shinyFeedback::useShinyFeedback(),
        column(6, tags$br(), coords[[1]], coords[[2]], coords[[3]], coords[[4]]),
        column(6, tags$br(), coords[[5]], coords[[6]], coords[[7]], coords[[8]])
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
filter_server <- function(id, NOAA, external, ivars = c("depth", "lon", "lat"),
                          variable, extended = TRUE) {

  stopifnot(is.reactive(NOAA))
  stopifnot(is.reactivevalues(variable))
  stopifnot(is.reactivevalues(external))

  moduleServer(id, function(input, output, session) {

    # store input in custom `reactivalues`
    input2 <- reactiveValues(depth = NULL, lon = NULL, lat = NULL)

    # toggle disable/enable  of `actionbutton` extract/reset/back locations
    observe({
      if (isTRUE(extended)) {
        shinyjs::toggleState(
          "extract",
          all(purrr::map_lgl(ivars, ~{input[[.x]]!=""}))
        )
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
          ~{input2[[.x]] <- scan(textConnection(input[[.x]]), sep = ",",
                                 quiet = TRUE)}
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

    # coordinate extraction
    extract <- reactive({
      if (
        dplyr::between(req(input2$depth), 0, 3000) &&
        dplyr::between(req(input2$lon), -179, 180) &&
        dplyr::between(req(input2$lat), -89, 90)
        ) {

        req(NOAA)
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

    # delete previous extracted coordinate points by first storing the step
    # length
    n_max <- reactiveVal(numeric(0))
    observe({
      # how many steps back? maximum depth of `input2`
      step <- lengths(reactiveValuesToList(input2)) |> max()
      if (step > 0) n_max(c(isolate(n_max()), step))
    })

    # and then deleting the last observations
    observeEvent(input$back, {
      if (length(n_max()) > 1) {
        coord(dplyr::slice_head(coord(), n = nrow(coord()) - rev(n_max())[1]))
        # delete last n_max
        n_max(utils::head(n_max(), -1))
      } else {
        # enable base map plotting (otherwise generates error)
        coord(NULL)
      }
      purrr::walk(ivars, ~{input2[[.x]] <- NULL}) # set input to NULL
    })

    # delete all coordinate points by clicking reset of changing the dataset
    # delete when loading a new variable (listening to reactive: `variable`)
    observeEvent({input$reset; variable$parm; variable$spat; variable$temp},{
      # NOAA()
      coord(NULL) # set stored data to NULL
      purrr::walk(ivars, ~{input2[[.x]] <- NULL}) # set input to NULL
    })

    # reset all by button click or reset text input when plot input is selected
    observeEvent({input$reset | input$back | external$lon | external$lat |
                   external$depth}, {
      if (isTRUE(extended)) {
        updateTextInput(
          inputId = "lon",
          value = character(0),
          placeholder = "degrees"
        )
        updateTextInput(
          inputId = "lat",
          value = character(0),
          placeholder = "degrees"
        )
        updateTextInput(
          inputId = "depth",
          value = character(0),
          placeholder = "meters"
        )
      }
    })

    # helper modals
    observeEvent({input$depthhelper | input$lonhelper| input$lathelper} , {
      showModal(
        modalDialog(
          title = "Location information",
          HTML(
            paste0("The text fields: \"depth\", \"longitude\", and ",
                   "\"latitude\" specify the location to extract ",
                   "oceanographic variables. Alternatively, one can click on ",
                   "the plot to obtain the values. It is possible to extract ",
                   "multiple locations at once by providing a comma separated ",
                   "list (e.g., \"120, 130, 140\"). Note, that depth and ",
                   "coordinate vectors should be of the same length, or one ",
                   "of the two should have length one. The data is extracted ",
                   "only when all three fields have been filled, and by ",
                   "subsequently clicking the button \"Extract\"."),
          )
        )
      )
    }, ignoreInit = TRUE)

    observeEvent(input$searchhelper , {
      showModal(
        modalDialog(
          title = "Selector",
          HTML(
            paste0("Data extraction can be achieved in two modes; \"point\" ",
                   "and \"fuzzy\", where the former results in a very precise ",
                   "search, the latter option searches in an area with a ",
                   "circumference of 50 km around the selected coordinate ",
                   "point. The returned value of a fuzzy search is therefore ",
                   "an average of the search area. Currently, fuzzy search is ",
                   "not yet implemented."),
          )
        )
      )
    })

    observeEvent(input$selecthelper , {
      showModal(
        modalDialog(
          title = "Extractions",
          HTML(
            paste0("The button \"Extract\" uses the information supplied ",
                   " in the text fields: \"depth\", \"longitude\", and ",
                   "\"latitude\" to extract the oceanographic variable. ",
                   "Hence the button is only active when those fields have ",
                   "been filled, and otherwise remains greyed-out. The ",
                   "buttons: \"Reset\" and \"Back\" revert all, or the last ",
                   "extraction, respectively. These two operations can be ","
                   used for data extracted by clicking on the interactive ",
                   "plot and/or obtained by using the text field search.")
          )
        )
      )
    })

    # return
    list(coord = coord, code = code)
  })
}


