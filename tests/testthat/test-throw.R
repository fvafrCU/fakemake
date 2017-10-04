testthat::context("Testing fakemake:::throw()")
testthat::test_that("throw the fakemake exception", {
                        error_message <- "hello, testthat"
                        testthat::expect_error(fakemake:::throw("hello, testthat"),
                                               error_message)
}
)
