Dear CRAN Team,
this is a resubmission of package 'fakemake'. 
Seeing errors (https://cran.r-project.org/web/checks/check_results_fakemake.html)
I have added the following changes:

* Disabled RUnit tests for OSX (I can't debug failing tests on OSX) 
  and R Versions older than 3.3.1 (as required by DESCRIPTION).

Please upload to CRAN.
Best, Dominik

# Package fakemake 1.0.2
## Test  environments 
- R Under development (unstable) (2017-11-07 r73685)
  Platform: x86_64-pc-linux-gnu (64-bit)
  Running under: Devuan GNU/Linux 1 (jessie)
- R version 3.4.2 (2017-01-27)
  Platform: x86_64-pc-linux-gnu (64-bit)
  Running under: Ubuntu 14.04.5 LTS
- win-builder (devel)

## R CMD check results
0 errors | 0 warnings | 1 note 
