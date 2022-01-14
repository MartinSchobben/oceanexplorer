#' Obtain NOAA WORLD OCEAN ATLAS dataset
#'
#' The function can also automatically caches the extracted files.
#'
#' @param var The chemical or physical variable of interest.
#' @param spat_res Spatial resolution, either 1 or 5 degree grid-cells (numeric)
#'  .
#' @param av_period Temporal resolution, either `"annual"`, specific seasons
#'  (e.g. `"winter"`), or month (e.g. `"August"`).
#' @param cacheNOAA Caching the extracted files under `inst/extdata`.
#'
#' @return Star object.
#' @export
#'
#' @examples
#' \dontrun{
#' get_NOAA("oxygen", 1, "annual")
#' }
get_NOAA <- function(var, spat_res, av_period, cacheNOAA = TRUE) {

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

  # path
  NOAA_path <- url_parser(var, spat_res, av_period)

  if (length(NOAA_path) == 1) {
    # get stars
    NOAA <- readRDS(NOAA_path[[1]])
  } else {
    # get netcdf
    NOAA <- suppressWarnings(stars::read_ncdf(NOAA_path[[1]], var = stat)) # suppress warning for unrecognized units

    if (isTRUE(cacheNOAA)) {
      # write stars object if extracted from NOAA server
      # create dir
      fs::dir_create(fs::path_dir(NOAA_path[[2]]))
      # create file
      saveRDS(NOAA, NOAA_path[[2]])
    }
  }

  # return object
  NOAA
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
  file_path <- paste(var, deca, if(spat_res > 1) "5deg" else "1.00", file, sep = "/")

  # check whether exist locally
  local_path <- fs::path("inst", "extdata", fs::path_ext_remove(file_path), ext = "rds")
  # if not exist make external path to server
  if (!fs::file_exists(local_path)) {
    external_path <- paste(base_path, file_path, sep = "/")
    list(external = external_path, local = local_path)
  } else {
    list(local = local_path)
  }
}
