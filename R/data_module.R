#' NOAA data module
#'
#' @param id Namespace id shiny module.
#'
#' @return Shiny module.
#' @export
input_ui <- function(id) {

  tagList(
    waiter::use_waiter(),
    selectInput(
      NS(id, "var"),
      h5("Variable"),
      choices = c("temperature", "phosphate", "nitrate", "silicate", "oxygen")
    ),
    selectInput(
      NS(id, "spat"),
      h5("Spatial resolution"),
      choices = c(1, 5)
    ),
    selectInput(
      NS(id, "temp"),
      h5("Averaging period"),
      choices = c("annual", month.name, "winter", "spring", "summer", "autumn")
    ),
    tags$br(),
    tags$br(),
    actionButton(NS(id, "go"), h5("Download data!")),
    tags$br(),
    tags$br(),
    textOutput(NS(id,  "citation"))
  )
}
#' @rdname input_ui
#'
#' @export
input_server <- function(id) {

  moduleServer(id, function(input, output, session) {

    # citation
    output$citation <- renderText({
      if (input$var %in% c("phosphate", "nitrate", "silicate")) {
        citations["Nutrients"]
      } else if (input$var == "oxygen") {
        citations["Oxygen"]
      }
    }) %>%
      bindEvent(input$go)

    # input data
    eventReactive(input$go, {
      waiter <- waiter::Waiter$new()
      waiter$show()
      on.exit(waiter$hide())

      get_NOAA(input$var, input$spat, input$temp)
    })
  })
}



citations <- c(
  Temperature = "Locarnini, R. A., A. V. Mishonov, O. K. Baranova, T. P. Boyer, M. M. Zweng, H. E. Garcia, J. R. Reagan, D. Seidov, K. Weathers, C. R. Paver, and I. Smolyar, 2018. World Ocean Atlas 2018, Volume 1: Temperature. A. Mishonov Technical Ed.; NOAA Atlas NESDIS 81, 52pp.",
  Salinity = "Zweng, M. M., J. R. Reagan, D. Seidov, T. P. Boyer, R. A. Locarnini, H. E. Garcia, A. V. Mishonov, O. K. Baranova, K. Weathers, C. R. Paver, and I. Smolyar, 2018. World Ocean Atlas 2018, Volume 2: Salinity. A. Mishonov Technical Ed.; NOAA Atlas NESDIS 82, 50pp.",
  Oxygen = "Garcia, H. E., K. Weathers, C. R. Paver, I. Smolyar, T. P. Boyer, R. A. Locarnini, M. M. Zweng, A. V. Mishonov, O. K. Baranova, D. Seidov, and J. R. Reagan, 2018. World Ocean Atlas 2018, Volume 3: Dissolved Oxygen, Apparent Oxygen Utilization, and Oxygen Saturation. A. Mishonov Technical Ed.; NOAA Atlas NESDIS 83, 38pp.",
  Nutrients = "Garcia, H. E., K. Weathers, C. R. Paver, I. Smolyar, T. P. Boyer, R. A. Locarnini, M. M. Zweng, A. V. Mishonov, O. K. Baranova, D. Seidov, and J. R. Reagan, 2018. World Ocean Atlas 2018, Volume 4: Dissolved Inorganic Nutrients (phosphate, nitrate and nitrate+nitrite, silicate). A. Mishonov Technical Ed.; NOAA Atlas NESDIS 84, 35pp.",
  Density = "Locarnini, R.A., T.P. Boyer, A.V. Mishonov, J.R. Reagan, M.M. Zweng, O.K. Baranova, H.E. Garcia, D. Seidov, K.W. Weathers, C.R. Paver, and I.V. Smolyar (2019). World Ocean Atlas 2018, Volume 5: Density. A. Mishonov, Technical Editor. NOAA Atlas NESDIS 85, 41pp.",
  Conductivity = "Reagan, J.R., M.M. Zweng, D. Seidov, T.P. Boyer, R.A. Locarnini, A.V. Mishonov, O.K. Baranova, H.E. Garcia, K.W. Weathers, C.R. Paver, I.V. Smolyar, and R.H. Tyler (2019). World Ocean Atlas 2018, Volume 6: Conductivity. A. Mishonov Technical Editor, NOAA Atlas NESDIS 86, 38 pp."
)
