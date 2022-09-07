#' NOAA data module
#'
#' These shiny modules control loading of data from the NOAA world ocean atlas
#' (`input_ui()` + `input_server()`). In addition, the `output_ui()` +
#' `output_server()` can be used to export the filtered data in csv format. The
#' `citation_ui()` provides the associated references of the dataset currently
#' loaded.
#'
#' @param id Namespace id shiny module.
#' @param NOAA Reactive value for the dataset containing the locations
#'  coordinates.
#' @param citation Additional space for citation element.
#' @param variable Reactivevalues for selected variable information.
#' @param extended Boolean whether to build the extended module
#'  (default = `TRUE`).
#' @inheritParams get_NOAA
#'
#' @return Shiny module.
#' @export
#'
#' @examples
#'
#' # run data module stand-alone
#' if (curl::has_internet() && interactive()) {
#'
#' library(oceanexplorer)
#' library(shiny)
#'
#' # data
#' NOAA <- get_NOAA("oxygen", 1, "annual")
#'
#' # gui
#' ui <- fluidPage(input_ui("NOAA"), plot_ui("worldmap"))
#'
#' # server
#'
#' server <-function(input, output, session) {
#'  # table
#'  NOAA <- input_server("NOAA")
#'  # plot data
#'  output_plot <- plot_server("worldmap", NOAA$data, reactive(NULL))
#' }
#'
#' # run app
#' shinyApp(ui, server)
#' }
input_ui <- function(id, citation = NULL, extended = TRUE) {

  vars <- tagList(
    actionLink(
      NS(id, "varhelper"),
      "",
      icon = icon('question-circle', verify_fa = FALSE)
    ),
    selectInput(
      NS(id, "var"),
      h5("Variable"),
      choices = c("temperature", "phosphate", "nitrate", "silicate", "oxygen",
                  "salinity", "density")
    ),
    actionLink(
      NS(id, "spathelper"),
      "",
      icon = icon('question-circle', verify_fa = FALSE)
    ),
    selectInput(
      NS(id, "spat"),
      h5("Resolution"),
      choices = c(1, 5)
    ),
    actionLink(
      NS(id, "temphelper"),
      "",
      icon = icon('question-circle', verify_fa = FALSE)
    ),
    selectInput(
      NS(id, "temp"),
      h5("Averaging"),
      choices = c("annual", month.name, "winter", "spring", "summer", "autumn")
    )
  )

  load <- tagList(
    tags$br(),
    tags$br(),
    actionButton(NS(id, "go"), h5("Load data")),
    tags$br(),
    tags$br(),
    citation,
  )

  if (isTRUE(extended)) {
    layout <- tagList(
      fluidRow(
        column(6,  tags$br(), vars[[1]], vars[[2]], vars[[3]], vars[[4]]),
        column(6,  tags$br(), vars[[5]], vars[[6]])
        )
    )
    tagAppendChildren(layout, load)
  } else {
    fillRow(fillCol(vars), fillCol(load))
  }
}
#' @rdname input_ui
#'
#' @export
citation_ui <- function(id) {
  tagList(tags$br(), tags$br(), uiOutput(NS(id,  "citation")))
}
#' @rdname input_ui
#'
#' @export
output_ui <- function(id) {
  downloadButton(NS(id, "download"), "Download")
}
#' @rdname input_ui
#'
#' @export
input_server <- function(id, cache = FALSE) {

  moduleServer(id, function(input, output, session) {

    # citation
    output$citation <- renderUI({

      if (input$var %in% c("phosphate", "nitrate", "silicate")) {
        citations("nutrients")
      } else {
        citations(input$var)
      }
    }) |>
      bindEvent(input$go)

    # input data
    x <- eventReactive(input$go, {

      # make the waiting more informative with a spinner
      waiter <- waiter::Waiter$new()
      waiter$show()
      on.exit(waiter$hide())

      # call for data retrieval
      call_NOAA <- glue::glue("get_NOAA({glue::double_quote(input$var)}, ",
                              "{input$spat}, {glue::double_quote(input$temp)})")

      # execute
      exec_NOAA <- try(
        get_NOAA(input$var, input$spat, input$temp, cache = cache),
        silent = TRUE
      )

      # notification when data does exist
      exists <- inherits(exec_NOAA, "try-error")
      shinyFeedback::feedbackDanger(
        "var",
        exists,
        "This data is not available. Try another combination of parameters"
      )
      shinyFeedback::feedbackDanger(
        "spat",
        exists,
        "This data is not available. Try another combination of parameters"
      )
      shinyFeedback::feedbackDanger(
        "temp",
        exists,
        "This data is not available. Try another combination of parameters"
      )
      req(!exists, cancelOutput = TRUE)

      # return data and call
      list(data = exec_NOAA, code = call_NOAA)
    })

    # helper modals
    observeEvent(input$varhelper, {
      showModal(
        modalDialog(
          title = "Oceanographic variables",
          HTML(
            paste0("Select the oceanographic variable of interest. See the ",
                    "following technical paper for more information: ",
                   technical),
            )
        )
      )
    })

    observeEvent(input$spathelper, {
      showModal(
        modalDialog(
          title = "Available grid resolution",
          HTML(
            paste0("Select the grid resolution for mean fields on a 1- or ",
                   "5-degree longitude/latitude grid . See the ",
                   "following technical paper for more information: ",
                   technical),
          )
        )
      )
    })

    observeEvent(input$temphelper, {
      showModal(
        modalDialog(
          title = "Available time periods",
          HTML(
            paste0("Select the time period over which the mean is calculated. ",
                   "The period can be annual, North Hemisphere seasonal ",
                   "(e.g. Spring, three-month periods) and monthly. See the ",
                   "following technical paper for more information: ",
                   technical),
          )
        )
      )
    })

    # assign parameter information to `reactiveValues`
    var <- reactiveValues(parm = NULL, spat = NULL, temp = NULL)
    observe({
      var$parm <- input$var
      var$spat <- input$spat
      var$temp <- input$temp
    })

    # output
    list(
      data = reactive(x()$data),
      code = reactive(x()$code),
      variable = var
    )
  })
}
#' @rdname input_ui
#'
#' @export
output_server <- function(id, NOAA, variable) {

  stopifnot(is.reactivevalues(variable))
  stopifnot(is.reactive(NOAA))

  moduleServer(id, function(input, output, session) {

    # format
    pretty_table <- reactive({
      # require
      req(NOAA())
      req(variable$parm)
      # format table
      format_table(NOAA(), variable$parm, variable$spat, variable$temp)
    })

    output$download <- downloadHandler(
      filename = function() {
        paste0(variable$parm, ".csv")
      },
      content = function(file) {
        utils::write.csv(pretty_table(), file)
      }
    )

  })
}

# cite the papers
vc_cite <- c(
  temperature = paste0(
    "Locarnini, R. A., A. V. Mishonov, O. K. Baranova, T. P. Boyer, M. M. ",
    "Zweng, H. E. Garcia, J. R. Reagan, D. Seidov, K. Weathers, C. R. Paver, ",
    "and I. Smolyar, 2018. World Ocean Atlas 2018, Volume 1: Temperature. A. ",
    "Mishonov Technical Ed.; NOAA Atlas NESDIS 81, 52pp."
  ),
  salinity = paste0(
    "Zweng, M. M., J. R. Reagan, D. Seidov, T. P. Boyer, R. A. Locarnini, H. ",
    "E. Garcia, A. V. Mishonov, O. K. Baranova, K. Weathers, C. R. Paver, and",
    "I. Smolyar, 2018. World Ocean Atlas 2018, Volume 2: Salinity. A.  ",
    "Mishonov Technical Ed.; NOAA Atlas NESDIS 82, 50pp."
  ),
  oxygen = paste0(
    "Garcia, H. E., K. Weathers, C. R. Paver, I. Smolyar, T. P. Boyer, R. A. ",
    "Locarnini, M. M. Zweng, A. V. Mishonov, O. K. Baranova, D. Seidov, and  ",
    "J. R. Reagan, 2018. World Ocean Atlas 2018, Volume 3: Dissolved Oxygen,  ",
    "Apparent Oxygen Utilization, and Oxygen Saturation. A. Mishonov ",
    "Technical Ed.; NOAA Atlas NESDIS 83, 38pp."
  ),
  nutrients = paste0(
    "Garcia, H. E., K. Weathers, C. R. Paver, I. Smolyar, T. P. Boyer, R. A. ",
    "Locarnini, M. M. Zweng, A. V. Mishonov, O. K. Baranova, D. Seidov, and ",
    "J. R. Reagan, 2018. World Ocean Atlas 2018, Volume 4: Dissolved Inorganic",
    " Nutrients (phosphate, nitrate and nitrate+nitrite, silicate). A.  ",
    "Mishonov Technical Ed.; NOAA Atlas NESDIS 84, 35pp."
  ),
  density = paste0(
    "Locarnini, R.A., T.P. Boyer, A.V. Mishonov, J.R. Reagan, M.M. Zweng,  ",
    "O.K. Baranova, H.E. Garcia, D. Seidov, K.W. Weathers, C.R. Paver, and  ",
    "I.V. Smolyar (2019). World Ocean Atlas 2018, Volume 5: Density. A. ",
    "Mishonov, Technical Editor. NOAA Atlas NESDIS 85, 41pp."
  )
)

citations <- function(x) {

  HTML(
    paste(
      vc_cite[x],
      a(
        href = "https://www.ncei.noaa.gov/products/world-ocean-atlas",
        "(Click here for the original papers)"
      )
    )
  )
}

technical <- a(
  href =  "https://www.ncei.noaa.gov/data/oceans/woa/WOA18/DOC/woa18documentation.pdf",
  "NOAA World Ocean Atlas 2018 Product Documentation"
)
