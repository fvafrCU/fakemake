get_ml <- function() {
    res <- prune_list(provide_make_list(type = "minimal"))
    return(res)
}

make_initial <- function() {
    ml <- get_ml()
    unlink(list.files(tempdir(), pattern = ".*\\.Rout", full.names = TRUE))

    #% initial full tree
    result <- make("all.Rout", ml)
    expectation <- c("b1.Rout", "a1.Rout", "a2.Rout", "all.Rout")
    RUnit::checkIdentical(result, expectation)
}
