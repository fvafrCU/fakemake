get_ml <- function() {
    res <- prune_list(add_tempdir(provide_make_list(type = "minimal")))
    return(res)
}

make_initial <- function() {
    ml <- get_ml()
    unlink(list.files(tempdir(), pattern = ".*\\.Rout", full.names = TRUE))

    #% initial full tree
    result <- make(file.path(tempdir(), "all.Rout"), ml)
    make_tree <- c("b1.Rout", "a1.Rout", "a2.Rout", "all.Rout")
    expectation <- file.path(tempdir(), make_tree)
    RUnit::checkIdentical(result, expectation)
}
