if(
  requireNamespace('spelling', quietly = TRUE) &&
  testthat::skip_on_ci() &&
  testthat::skip_on_covr()
)
  spelling::spell_check_test(vignettes = TRUE, error = FALSE,
                             skip_on_cran = TRUE)
