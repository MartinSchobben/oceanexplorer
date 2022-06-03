#' Obtain NOAA World Ocean Atlas dataset
#'
#' The function retrieves data from the NOAA World Ocean Atlas.
#'
#' This function retrieves data from the
#' \href{https://www.ncei.noaa.gov/products/world-ocean-atlas}{NOAA World Ocean Atlas}
#' as an 3D array (longitude, latitude, and depth) and stores them with
#' \code{stars::\link[stars:read_stars]{read_stars()}} as an stars object
#' (see also: \href{https://r-spatial.github.io/stars/articles/stars1.html}{Introduction to the stars package}).
#' The function can automatically cache the extracted files
#' (default: \code{cacheNOAA = TRUE}).
#'
#' @param var The chemical or physical variable of interest.
#' @param spat_res Spatial resolution, either 1 or 5 degree grid-cells (numeric)
#'  .
#' @param av_period Temporal resolution, either `"annual"`, specific seasons
#'  (e.g. `"winter"`), or month (e.g. `"August"`).
#' @param cacheNOAA Caching the extracted files under `inst/extdata`.
#'
#' @return \code{\link[stars:read_stars]{stars}} object.
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

  # where is package
  pkg_path <- fs::path_package("oceanexplorer")

  # path
  NOAA_path <- url_parser(var, spat_res, av_period)

  if (length(NOAA_path) == 1) {
    # get data and make stars
    NOAA <- readRDS(fs::path(pkg_path, NOAA_path[[1]])) |> stars::st_as_stars()
  } else {
    # get netcdf ('make_units' = suppress warning for unrecognized units)
    NOAA <- stars::read_ncdf(NOAA_path[[1]], var = stat, make_units = FALSE)

    if (isTRUE(cacheNOAA)) {

      # write stars object if extracted from NOAA server
      # create dir
      fs::dir_create(pkg_path, fs::path_dir(NOAA_path[[2]]))
      # create file
      saveRDS(NOAA, fs::path(pkg_path, NOAA_path[[2]]))
    }
  }

  # return object
  NOAA
}

url_parser <- function(var, spat_res, av_period) {

  # temporal resolution
  averaging_periods <- c("annual", month.name, "winter", "spring", "summer",
                         "autumn")
  stopifnot(av_period %in% averaging_periods)

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
  tp <- grep(av_period, averaging_periods, ignore.case = TRUE) - 1
  tp <- sprintf(fmt = "%02.0f", tp)
  # grid-cell size
  gr <- if(spat_res > 1) "5d" else "01"
  # complete file name
  file <- paste0(paste("woa18", deca, paste0(v, tp), gr, sep = "_"), ".nc")
  # complete file path
  file_path <- paste(var, deca, if(spat_res > 1) "5deg" else "1.00", file,
                     sep = "/")

  # check whether exist locally
  local_path <- fs::path("extdata", fs::path_ext_remove(file_path), ext = "rds")
  # if not exist make external path to server
  noaa_path <- try(fs::path_package("oceanexplorer", local_path), silent = TRUE)
  if (!inherits(noaa_path, "fs_path")) {
    external_path <- paste(base_path, file_path, sep = "/")
    list(external = external_path, local = local_path)
  } else {
    list(local = local_path)
  }
}
