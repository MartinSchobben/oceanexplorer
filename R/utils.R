#' Parsing expressions for plot labels
#'
#' @param var Environmental parameter.
#'
#' @return Expression
#' @export
env_parm_labeller <- function(var, prefix = character(1), postfix = character(1)) {
  # get species / parameter names
  parm <- sub("_.*$", "", var)
  if (parm %in% c("i", "p", "o", "n")) {
    # ion
    ion <- c(i = "SiO", p = "PO", o = "O", n = "NO")
    # index number
    index <- c(i = 2, p = 4, o = 2, n = 3)
    as.expression(
      substitute(
        prefix ~ a[b]~"("*mu*"mol kg"^{"-"}*")" ~ postfix,
        list(prefix = rlang::sym(prefix), postfix = rlang::sym(postfix), a = rlang::sym(ion[[parm]]), b = index[[parm]])
      )
    )
  } else if (parm == "t") {
    as.expression(
      substitute(
        prefix ~ 'Temperature ('*degree~C*')' ~ postfix,
        list(prefix = rlang::sym(prefix), postfix = rlang::sym(postfix))
      )
    )
  } else if (parm == "s") {
    "Salinity"
  } else if (parm == "I") {
    as.expression(
      substitute(
        prefix ~ "Density (kg m"^{"-3"}*")" ~ postfix,
        list(prefix = rlang::sym(prefix), postfix = rlang::sym(postfix))
      )
    )
  } else {
    stop("Parameter is unkown.", call. = FALSE)
  }
}

#' Reprojecting spatial objects to new epsg
#'
#' @param var Environmental parameter.
#'
#' @return sf or stars object
#' @export
reproject <- function(obj, epsg = NULL, ...) {

  # epsg NULL, "", or "original" then use crs of supplied object
  if (is.null(epsg) || epsg == "original" || epsg == character(1)) {
    return(obj)
  } else if (inherits(epsg, "crs")) {
    # coord transform NOAA and selected points if different from origin
    if (epsg == sf::st_crs(obj)) return(obj)
  } else if (grepl("^[0-9]*$", epsg)) {
    epsg <- as.numeric(epsg)
    # coord transform NOAA and selected points if different from origin
    if (sf::st_crs(epsg) == sf::st_crs(obj)) return(obj)
  }

  UseMethod("reproject")
}
#' @rdname reproject
#'
#' @export
reproject.sf <- function(obj, epsg) {
  sf::st_transform(obj, crs = epsg)
}
#' @rdname reproject
#'
#' @export
reproject.stars <- function(obj, epsg) {
  trywarp <- try(stars::st_warp(base, crs = epsg), silent = TRUE)
  if (inherits(trywarp, "try-error")) {
    sf::st_transform(obj, crs = epsg)
  } else {
    trywarp
  }
}
