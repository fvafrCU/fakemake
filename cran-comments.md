Dear CRAN Team,
this is a resubmission of package 'fakemake'. I have added the following changes:

* Fixed recursive treatment of argument `verbose` to function `make`.
* Fixed internal function `package\_makelist` to using `devtools::test` instead 
  `testthat::test_package` directly (the former is a wrapper to the latter).
* Now `package\_makelist` is printing output from roxygen2, testthat, cleanr and
  devtools::build to harmonize logs.

Please upload to CRAN.
Best, Andreas Dominik

# Package fakemake 1.1.0
## Test  environments 
- R Under development (unstable) (2018-01-12 r74112)
  Platform: x86_64-pc-linux-gnu (64-bit)
  Running under: Devuan GNU/Linux 1 (jessie)
- R version 3.4.2 (2017-01-27)
  Platform: x86_64-pc-linux-gnu (64-bit)
  Running under: Ubuntu 14.04.5 LTS
- win-builder (devel)

## R CMD check results
0 errors | 0 warnings | 0 notes
