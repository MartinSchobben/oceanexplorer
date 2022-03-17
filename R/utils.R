#' Title
#'
#' @param var Environmental parameter.
#'
#' @return
#' @export
env_parm_labeller <- function(var) {
  # get species / parameter names
  parm <- sub("_.*$", "", var)
  if (parm %in% c("i", "p", "o", "n")) {
    # ion
    ion <- c(i = "SiO", p = "PO", o = "O", n = "NO")
    # index number
    index <- c(i = 2, p = 4, o = 2, n = 3)
    as.expression(
      substitute(
        a[b]~"("*mu*"mol kg"^{"-"}*")",
        list(a = rlang::sym(ion[[parm]]), b = index[[parm]])
      )
    )
  } else if (parm == "t") {
    expression('Temperature ('*degree~C*')')
  } else if (parm == "s") {
    "Salinity"
  } else if (parm == "I") {
    expression("Density (kg m"^{"-3"}*")")
  } else {
    stop("Parameter is unkown.", call. = FALSE)
  }
}
