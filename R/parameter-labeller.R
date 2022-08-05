#' Parsing expressions for plot labels
#'
#' Conveniently converts NOAA world ocean atlas parameter names into full
#' oceanographic variable names including units for parsing in plot labels.
#'
#' @param var Environmental parameter.
#' @param prefix Prefix.
#' @param postfix Postfix.
#'
#' @return Expression
#' @export
#'
#' @examples
#'
#' # expression
#' env_parm_labeller("t_an")
#'
#' # plot with temperature axis label
#' library(ggplot2)
#'
#' ggplot() +
#'  geom_blank() +
#'  ylab(env_parm_labeller("t_an"))
#'
#'
env_parm_labeller <- function(var, prefix = character(1),
                              postfix = character(1)) {
  # get species / parameter names
  parm <- sub("_.*$", "", var)
  if (parm %in% c("i", "p", "o", "n")) {
    # ion
    ion <- c(i = "SiO", p = "PO", o = "O", n = "NO")
    # index number
    index <- c(i = 2, p = 4, o = 2, n = 3)
    as.expression(
      substitute(
        prefix ~ a[b]~"("*mu*"mol kg"^{"-1"}*")" ~ postfix,
        list(
          prefix = rlang::sym(prefix),
          postfix = rlang::sym(postfix),
          a = rlang::sym(ion[[parm]]),
          b = index[[parm]]
        )
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
