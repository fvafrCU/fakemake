testthat::context("Testing fakepack:::throw()")
testthat::test_that("throw the fakepack exception", {
                        error_message <- "test error"
                        testthat::expect_error(fakepack:::throw("test error"),
                                               error_message)
}
)
