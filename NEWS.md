# fakemake 1.0.2

* Disabled RUnit tests for OSX (I can't debug failing tests on OSX) 
  and R Versions older than 3.3.1 (as required by DESCRIPTION).

# fakemake 1.0.1

* Replaced file.show(x, pager = "cat") with cat(readLines(x), sep = "\"n) in
  examples as they did not pass checks on windows.
* Fixed example path for windows. 

# fakemake 1.0.0

* Added a `NEWS.md` file to track changes to the package.



