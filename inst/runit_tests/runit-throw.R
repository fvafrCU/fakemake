test_exception <- function() {
    RUnit::checkException(fakemake:::throw("Hello, error"))
}
