#' NOAA table module
#'
#' @param id Namespace id shiny module.
#' @param download Add download button.
#' @param NOAA Reactive value of NOAA dataset.
#' @param back Reactive value for back button.
#' @param reset Reactive value for reset button.
#' @param extended Boolean whether to build the extended module
#'  (default = `TRUE`).
#'
#' @return Shiny module.
#' @export
table_ui <- function(id, download = NULL, extended = TRUE) {

  if (isTRUE(extended)) {
    tagList(
      tags$br(),
      conditionalPanel(condition = "output.table!=null", download, ns = NS(id)),
      tags$br(),
      tags$br(),
      tags$br(),
      tableOutput(NS(id,  "table"))
    )
  } else {
    dataTableOutput(NS(id,  "table"))
  }
}
#' @rdname table_ui
#'
#' @export
table_server <- function(id, NOAA, back, reset, extended = TRUE) {

  # check for reactive
  stopifnot(is.reactive(NOAA))

  moduleServer(id, function(input, output, session) {

    obs <- reactiveVal(NULL)

    # update output table
    observeEvent(NOAA(), {
      req(NOAA())
      if (is.null(obs())) {
        obs(NOAA())
      } else {
        obs(dplyr::rows_upsert(obs(), NOAA(), by = c("depth", "coordinates")))
      }
    })

    # delete observation table
    observeEvent(back(), {
      req(back())
      obs(dplyr::rows_delete(obs(), tail(obs(), 1), by = colnames(obs())))
    })

    # reset whole table
    observeEvent(reset(), {
      req(reset())
      obs(NULL)
    })

    if (isTRUE(extended)) {
      output$table <- renderTable({obs()})
    } else {
      output$table <- renderDataTable({obs()})
    }
  })
}
