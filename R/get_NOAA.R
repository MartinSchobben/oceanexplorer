#' Obtain NOAA WORLD OCEAN ATLAS dataset
#'
#' @param var The chemical or physical variable of interest.
#' @param spat_res Spatial resolution, either 1 or 5 degree grid-cells (numeric)
#'  .
#' @param av_period Temporal resolution, either `"annual"`, specific seasons
#'  (e.g. `"winter"`), or month (e.g. `"August"`).
#'
#' @return Star object.
#' @export
#'
#' @examples
#' \dontrun{
#' get_NOAA("oxygen", 1, "annual")
#' }
get_NOAA <- function(var, spat_res, av_period) {

  # abbreviate variable
  if (var == "silicate") {
    v <- strsplit(var, "")[[1]][2]
  } else if (var == "density") {
    v <- "I"
  } else {
    v <- strsplit(var, "")[[1]][1]
  }
  # stat to extract
  if (spat_res < 5) {
    # standard set to objectively analyzed climatology for variable of interest
    stat <- paste(v, "an", sep = "_")
  } else {
    # standard set to Statistical mean for variable of interest
    stat <- paste(v, "mn", sep = "_")
  }
  # get netcdf
  stars::read_ncdf(url_parser(var, spat_res, av_period), var = stat)
}

url_parser <- function(var, spat_res, av_period) {

  # temporal resolution
  averaging_periods <- c("annual", month.name, "winter", "spring", "summer", "autumn")
  assertthat::assert_that(av_period %in% averaging_periods)

  # base path to NCEI server
  base_path <- "https://data.nodc.noaa.gov/thredds/dodsC/ncei/woa"

  # grouped variables
  chem <- c("phosphate", "nitrate", "silicate", "oxygen")
  misc <- c("temperature", "salinity", "density")

  # see https://www.ncei.noaa.gov/data/oceans/woa/WOA18/DOC/woa18documentation.pdf for metadata names
  # recording range
  if (var %in% chem) {
    deca <- "all"
  } else if (var %in% misc) {
    deca <- "decav"
  }
  # abbreviate variable
  if (var == "silicate") {
    v <- strsplit(var, "")[[1]][2]
  } else if (var == "density") {
    v <- "I"
  } else {
    v <- strsplit(var, "")[[1]][1]
  }
  # averaging period
  tp <- stringr::str_which(averaging_periods, stringr::regex(av_period, ignore_case = TRUE)) - 1
  tp <- sprintf(fmt = "%02.0f", tp)
  # grid-cell size
  gr <- if(spat_res > 1) "5d" else "01"
  # complete file name
  file <- paste0(paste("woa18", deca, paste0(v, tp), gr, sep = "_"), ".nc")
  # complete file path
  paste(base_path, var, deca, if(spat_res > 1) "5deg" else "1.00", file, sep = "/")
}
