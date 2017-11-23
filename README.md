[![Build Status](https://travis-ci.org/fvafrCU/fakemake.svg?branch=master)](https://travis-ci.org/fvafrCU/fakemake)
[![Coverage Status](https://codecov.io/github/fvafrCU/fakemake/coverage.svg?branch=master)](https://codecov.io/github/fvafrCU/fakemake?branch=master)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/fakemake)](https://cran.r-project.org/package=fakemake)
[![RStudio_downloads_monthly](https://cranlogs.r-pkg.org/badges/fakemake)](https://cran.r-project.org/package=fakemake)
[![RStudio_downloads_total](https://cranlogs.r-pkg.org/badges/grand-total/fakemake)](https://cran.r-project.org/package=fakemake)

<!-- README.md is generated from README.Rmd. Please edit that file -->



# fakemake
Please read the
[vignette](https://htmlpreview.github.io/?https://github.com/fvafrCU/fakemake/blob/master/inst/doc/An_Introduction_to_fakemake.html).

Or, after installation, the help page:

```r
help("fakemake-package", package = "fakemake")
```

```
#> Mock the Unix Make Utility
#> 
#> Description:
#> 
#>      Use R as a minimal build system. This might come in handy if you
#>      are developing R packages and can not use a proper build system.
#>      Stay away if you can (use a proper build system).
#> 
#> Details:
#> 
#>      You will find the details in
#>      'vignette("An_Introduction_to_fakemake", package = "fakemake")'.
```
{{#github}}
## Installation

You can install {{{ Package }}} from github with:

{{#Rmd}}

```r
{{/Rmd}}
{{^Rmd}}
``` r
{{/Rmd}}
if (! require("devtools")) install.packages("devtools")
devtools::install_github("{{{username}}}/{{{repo}}}")
```

Feel free to fork!
{{/github}}
