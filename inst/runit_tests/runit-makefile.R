test_provide_makefile <- function() {
    result <- provide_make_list(type = "minimal")
    expectation <- list(list(target = "all.Rout", 
                             prerequisites = c("a1.Rout", "a2.Rout"
                                               ), code = "print(\"all\")"), 
                        list(target = "a2.Rout", prerequisites = NULL, 
                             code = "print(\"a2\")"), 
                        list(target = "a1.Rout", prerequisites = "b1.Rout", 
                             code = "print(\"a1\")"), 
                        list(target = "b1.Rout", prerequisites = NULL, 
                             code = "print(\"b1\")"))
    RUnit::checkIdentical(result, expectation)
}

test_write_makefile <- function() {
    path <- tempfile()
    makefile <- provide_make_list(type = "minimal")
    write_makefile(makefile, path = path)
    result <- readLines(path)
    expectation <- readLines(system.file("templates", "Makefile_minimal", 
                               package = "fakemake"))
    RUnit::checkIdentical(result, expectation)
}

test_read_makefile <- function() {
    path <- tempfile()
    expectation <- provide_make_list(type = "minimal")
    write_makefile(expectation, path = path)
    result <- read_makefile(path)
    RUnit::checkIdentical(result, expectation)
}



