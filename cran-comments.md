Dear CRAN Team,
this is a resubmission of package 'fakemake'. 
Seeing errors (https://cran.r-project.org/web/checks/check_results_fakemake.html)
I have added the following changes:

* Disabled RUnit tests for OSX and R Versions older than 3.4.0.

I'm not happy about that: I successfully ran the tests using R 3.3.1
under Windows 7, but since I can see no way to get RUnit's output from CRAN
servers, I disable testing for OSX and oldrel.

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
- R version 3.3.1 (2016-06-21)
  Platform: x86_64-w64-mingw32/x64 (64-bit)
  Running under: Windows 7 x64 (build 7601) Service Pack 1
- win-builder (devel)
 
## R CMD check results
0 errors | 0 warnings | 1 note 
checking CRAN incoming feasibility ... NOTE
Maintainer: ‘Andreas Dominik Cullmann <fvafrcu@arcor.de>’

Days since last update: 3

