## Bug fixes

This is a patch for problems encountered during the first upload to CRAN. I received the following email from Prof Ripley:

> Dear maintainer,

> Please see the problems shown on
> <https://cran.r-project.org/web/checks/check_results_oceanexplorer.html>.

> Please correct before 2022-09-22 to safely retain your package on CRAN.

> Do remember to look at the 'Additional issues'.

> The CRAN Team

I have made the following amendments to accommodate the problems encountered:

* Removed unicode characters (5 times in data directory).

* Ensure that there is a fall-back for vignette building even without an internet connection or in case of connection failure (HTTP non-success status) with the NOAA server.

The errors and warnings relate to point two and thus should have been mended by these changes. 

## Test environments

I used `rhub` for platforms similar to the macOS and Windows setups that fail during CRAN Package Checks (`rhub::check(platforms = c("windows-x86_64-oldrel", "macos-highsierra-release-cran"))`). For the checks on a M1 (arm64) macOS setup I used: <https://mac.r-project.org/macbuilder/submit.html>. Furthermore, I tested on Ubuntu Focal (x86_64) with `devtools::check(remote = TRUE, manual = TRUE)` and with CI: GitHub Workflows (<https://github.com/r-lib/actions>).

## R CMD check results

R-hub macos-highsierra-release-cran (r-release):     

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

R-hub windows-x86_64-oldrel (r-release):     

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

macOS builder r-release-macosx-arm64|4.2.1|macosx|macOS 11.5.2 (20G95)|Mac mini|Apple M1||en_US.UTF-8:    

0 errors ✔ | 0 warnings ✔ | 0 notes ✔    

GitHub Workflows <https://github.com/UtrechtUniversity/oceanexplorer/actions/runs/3037222238> (macOS, Windows and Ubuntu):    

0 errors ✔ | 0 warnings ✔ | 0 notes ✔ 

x86_64-pc-linux-gnu (64-bit)|4.2.1:

  Maintainer: ‘Martin Schobben <schobbenmartin@gmail.com>’
  
  Days since last update: 5

0 errors ✔ | 0 warnings ✔ | 1 note ✖

## Reverse dependencies

No reverse dependencies.
