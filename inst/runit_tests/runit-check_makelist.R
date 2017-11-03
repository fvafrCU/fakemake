test_check_makelist <- function() {
    RUnit::checkException(fakemake:::check_makelist(3))
    ml <- provide_make_list("package")
    RUnit::checkTrue(fakemake:::check_makelist(ml))
    ml1 <- ml
    ml1[[2]]["foo"] <- "invalid item"
    ml1[[2]]["bar"] <- "another invalid item"
    RUnit::checkException(fakemake:::check_makelist(ml1))
    ml1 <- ml
    ml1[[1]]["target"] <- NULL
    ml1[[3]]["target"] <- NULL
    RUnit::checkException(fakemake:::check_makelist(ml1))
}
