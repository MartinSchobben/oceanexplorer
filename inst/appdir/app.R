# load all
pkgload::load_all(export_all = FALSE, helpers = FALSE, attach_testthat = FALSE)
# run app (with caching)
NOAA_app(cache = TRUE)
