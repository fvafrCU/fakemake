# fakemake 1.0.2.9000

* Fixed recursive treatment of argument `verbose` to function `make`.
* Fixed logging from package `lintr` in internal function `package\_makelist`.
* Now using `devtools::test` instead of package `testthat` directly in internal 
  function `package\_makelist`.

# fakemake 1.0.2

* Disabled RUnit tests for OSX and R Versions older than 3.4.0.

# fakemake 1.0.1

* Replaced file.show(x, pager = "cat") with cat(readLines(x), sep = "\"n) in
  examples as they did not pass checks on windows.
* Fixed example path for windows. 

# fakemake 1.0.0

* Added a `NEWS.md` file to track changes to the package.



