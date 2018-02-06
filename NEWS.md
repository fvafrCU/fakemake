# fakemake 1.1.0.9000

* add make\_list "standard", enhancing "package" by adding the creation of the
  log directory and using it as prerequisite.

# fakemake 1.1.0

* Fixed recursive treatment of argument `verbose` to function `make`.
* Fixed internal function `package\_makelist` to using `devtools::test` instead 
  `testthat::test_package` directly (the former is a wrapper to the latter).
* Now `package\_makelist` is printing output from roxygen2, testthat, cleanr and
  devtools::build to harmonize logs.

# fakemake 1.0.2

* Disabled RUnit tests for OSX and R Versions older than 3.4.0.

# fakemake 1.0.1

* Replaced file.show(x, pager = "cat") with cat(readLines(x), sep = "\"n) in
  examples as they did not pass checks on windows.
* Fixed example path for windows. 

# fakemake 1.0.0

* Added a `NEWS.md` file to track changes to the package.



