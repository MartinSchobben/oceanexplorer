#' NOAA table module
#'
#' @param id Namespace id shiny module.
#' @param download Add download button.
#' @param NOAA Reactive value of NOAA dataset.
#' @param variable Reactive value for selected variable name.
#'
#' @return Shiny module.
#' @export
table_ui <- function(id, download = NULL) {

    tagList(
      tags$br(),
      conditionalPanel(condition = "output.table!=null", download, ns = NS(id)),
      tags$br(),
      tags$br(),
      DT::DTOutput(NS(id,  "table"))
    )
}
#' @rdname table_ui
#'
#' @export
table_server <- function(id, NOAA, variable) {

  # check for reactive
  stopifnot(is.reactive(NOAA))

  moduleServer(id, function(input, output, session) {

    # format
    pretty_table <- reactive({
      req(NOAA())
      req(variable())

      format_table(NOAA(), variable())
    })

    # table
    output$table <- DT::renderDT({
      pretty_table()
      DT::formatRound(
        DT::datatable(pretty_table()),
        columns  = c(variable(), "depth", "longitude", "latitude"),
        digits = c(1, 0, 2, 2)
        )
      })

    # return code for the specific operation
    reactive({
      glue::glue(
        "filter_NOAA(\\
         NOAA, \\
         depth = c({glue::glue_collapse(pretty_table()$depth, sep = ', ')}), \\
         coord = \\
         list(\\
         lon = c({glue::glue_collapse(pretty_table()$longitude, sep = ', ')}), \\
         lat = c({glue::glue_collapse(pretty_table()$latitude, sep = ', ')})\\
         )\\
         )"
      )
    })

  })
}

# table output formatting
format_table <- function(NOAA, variable) {

  tb <- tibble::as_tibble(NOAA) %>%
    dplyr::mutate(
      coordinates = sf::st_as_text(.data$geometry),
      .keep = "unused"
      )

  tb <- format_coord(tb)

  # rename variable
  tb_nm <- colnames(tb)
  tb_nm[1] <- variable
  colnames(tb) <- tb_nm
  tb
}

format_coord <- function(NOAA, coord) {

  tidyr::separate(NOAA, "coordinates", into = c("geometry", "longitude", "latitude"), sep = "[^[:alnum:]|.|-]+", extra = "drop")


}
