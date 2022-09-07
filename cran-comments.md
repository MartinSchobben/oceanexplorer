## Resubmission

This is a resubmission. I have made the following amendments as requested.

* I have added a URL to description in the DESCRIPTION file that points to a series of papers on the NOAA website describing the methods behind the data. As there are multiple papers, this is probably the best solution.

* I added return values to "tidyeval.Rd".

* I wrapped the examples initially in `/dontrun{}` because of the latency of the `get_NOAA()` call which can take some time to get the data. Otherwise R CMD check on the examples would take a considerable amount of time. In addition, `get_NOAA()` requires an internet connection. As a solution I have now replaced `/dontrun{}` with `if (curl::has_internet() && interactive()){}` in all instances. I added `curl` to the suggested packages. I hope this is an acceptable solution.

* I removed the function `clean_cache()` that modifies the user's home directory. I replaced it with `list_NOAA()` that shows the cached content, leaving the action of removing the files to the user. The write function `get_NOAA()` already by default did not write the obtained NetCDF to the user's home directory. Caching is left as an option by modifying the `cache` parameter of `get_NOAA()`.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.
