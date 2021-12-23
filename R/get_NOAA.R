#' Obtain NOAA WORLD OCEAN ATLAS dataset
#'
#' @param var The chemical or physical variable of interest.
#' @param spat_res Spatial resolution, either 1 or 5 degree grid-cells (numeric)
#'  .
#' @param temp_res Temporal resolution, either `"annual"`, `"monthly"` and
#'  `"daily"`.
#' @param year Year of publication (numeric).
#'
#' @return Star object.
#' @export
#'
#' @examples
#' \dontrun{
#' get_NOAA("oxygen", 1, "annual", 2001)
#' }
get_NOAA <- function(var, spat_res, temp_res, year) {

  # temporal resolution
  averaging_periods <- c(annual = "an", monthly = "mn", daily = "dd")
  if (spat_res == 5) {
    if (temp_res == "annual") stop("Annual records do not exist for the 5 degrees lattice.", call. = FALSE)
    averaging_periods <- averaging_periods [-1]
    }
  temp_res <- paste(if (var == "silicate") strsplit(var, "")[[1]][2] else strsplit(var, "")[[1]][1], averaging_periods[temp_res],  sep = "_")
  stars::read_ncdf(url_parser(var, spat_res, year) , var = temp_res)

}


url_parser <- function(var, spat_res, year) {
  base_path <- "https://data.nodc.noaa.gov/thredds/dodsC/ncei/woa"
  chem <- c("phosphate", "nitrate", "silicate", "oxygen")
  if (var %in% chem) {
    subset_year <- paste0(if (var == "silicate") strsplit(var, "")[[1]][2] else strsplit(var, "")[[1]][1], stringr::str_sub(year, -2), if(spat_res > 1) "_5d" else "_01")
    subset_year <- paste("woa18_all", subset_year, sep = "_")
    file <- paste(base_path, var, "all", if(spat_res > 1) "5deg" else "1.00", subset_year, sep = "/")
    paste0(file, ".nc")
  }
}
