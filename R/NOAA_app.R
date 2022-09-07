#' Ocean explorer app
#'
#' Wrapper function that launches the NOAA app.
#'
#' @inheritParams input_ui
#'
#' @return Shiny app
#' @export
#'
#' @examples
#'
#' if (curl::has_internet() && interactive()) {
#'
#' # run app
#' NOAA_app()
#'
#' }
NOAA_app <- function(cache = FALSE) {

  # add resources
  addResourcePath('img', system.file('www/img', package = 'oceanexplorer'))

  ui <- fluidPage(

    theme = bslib::bs_theme(bootswatch = "slate"), # nice theming

    shinyjs::useShinyjs(), # use shinyjs

    shinyFeedback::useShinyFeedback(), # feedback

    titlePanel("NOAA WORLD OCEAN ATLAS"),
    sidebarLayout(
      sidebarPanel(
        tabsetPanel(
          id = "tabset",
          tabPanel("Parameters", input_ui("NOAA")),
          tabPanel("Locations", filter_ui("depth"))
          ),
        tags$br(),
        HTML(
          paste0(
            "R package: ",
            a(
              href = "https://github.com/UtrechtUniversity/oceanexplorer",
              "install_github('UtrechtUniversity/oceanexplorer')"
            )
          )
        ),
        tags$br(),
        HTML(
          paste0(
            "See the website for more help: ",
            a(
              href = "https://utrechtuniversity.github.io/oceanexplorer/",
              "utrechtuniversity.github.io/oceanexplorer"
            )
          )
        ),
        tags$br(),
        citation_ui("NOAA")
        ),
      mainPanel(
        waiter::use_waiter(),
        conditionalPanel(
          condition = "output.citation==null",
          h4(paste0("Select variable of interest and click ",
                    "\"Load data\" to display results.")),
          ns = NS("NOAA")
        ),
        conditionalPanel(
          condition = "output.citation!=null",
          tabsetPanel(
            tabPanel(
              "Map",
              plot_ui("worldmap")
              ),
            tabPanel(
              "Table",
              table_ui("table", output_ui("download"))
            )
          ),
          ns = NS("NOAA")
        )
      )
    ),
    # footer
    tags$hr(),
    tags$div(
      HTML(
        paste0(
          "This project was funded by ERC Starting grant number 802835, ",
          "OceaNice, awarded to Peter Bijl.    ",
          tags$img(src = "img/oceanice-logo.jpg", width = "150px"),
          tags$img(src = "img/erc-logo.jpg", width = "69px")
        )
      ),
      style ="text-align: right;"
    )
  )
  # run app
  shinyApp(ui, NOAA_server(extended = TRUE, cache = cache))
}
#' @rdname NOAA_app
#'
#' @export
NOAA_server <- function(extended = TRUE, cache) {
  function(input, output, session) {

    # plot colors to match shiny ui
    thematic::thematic_shiny()

    # original data
    withProgress(message = "Retrieving dataset from NOAA server", {
      NOAA <- input_server("NOAA", cache = cache)
    })

    # show locations selection controls when data loaded
    observeEvent(NOAA$data() , {
      updateTabsetPanel(
        session,
        "tabset",
        selected = if (isTRUE(extended)) "Locations" else "Map"
      )
    })

    # initiate plot click filter with null value
    clicked <- reactiveValues(lon = NULL, lat = NULL, depth = NULL)

    # filter depth (new variable resets dataset)
    filter <- filter_server("depth", NOAA$data, clicked,
                            variable = NOAA$variable, extended = extended)

    # plot data
    output_plot <- plot_server("worldmap", NOAA$data, filter$coord)

    # update `reactivevalue` if plot click selection has been used
    observe({
      clicked$lon <- output_plot$lon
      clicked$lat <- output_plot$lat
      clicked$depth <- output_plot$depth
    })

    # table
    output_table <- table_server("table", filter$coord, NOAA$variable)

    # download
    output_server("download", filter$coord, NOAA$variable)

    # emit code (RStudio addin)
    if (isFALSE(extended)) {

      # collect code
      emit <- reactiveValues(code = "library(oceanexplorer) \n")

      # code (only loading)
      observeEvent(NOAA$code(), {

        emit$code <- paste0(emit$code, "NOAA <- ", NOAA$code())

      })

      # code (loading and filter extraction)
      observeEvent(output_table(), {

        emit$code <- paste0(emit$code, "\n", output_table())

      })

      # listen for 'done'.
      observeEvent(input$done, {
        rstudioapi::insertText(emit$code)
        invisible(stopApp())
      })
    }
  }
}

