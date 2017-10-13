get_ml <- function() {
    res <- fakemake:::prune_list(provide_make_list(type = "minimal"))
    for (i in seq(along = res)) {
        res[[i]][["target"]] <- file.path(tempdir(), res[[i]][["target"]])
        if (!is.null(res[[i]][["prerequisites"]]))
            res[[i]][["prerequisites"]] <- file.path(tempdir(),
                                                    res[[i]][["prerequisites"]])
    }
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

test_make_full_tree <- function() {
    ml <- get_ml()
    make_initial()

    #% rerun
    result <- make(file.path(tempdir(), "all.Rout"), ml)
    expectation <- NULL
    RUnit::checkIdentical(result, expectation)
}

test_make_missing <- function() {
    ml <- get_ml()
    make_initial()

    #% target missing
    unlink(file.path(tempdir(), "all.Rout"))
    result <- make(file.path(tempdir(), "all.Rout"), ml)
    make_tree <- c("all.Rout")
    expectation <- file.path(tempdir(), make_tree)
    RUnit::checkIdentical(result, expectation)
}

test_make_newer <- function() {
    ml <- get_ml()
    make_initial()

    #% prerequisite newer
    # need to sleep on fast machine as the file modification times are identical
    # otherwise.
    Sys.sleep(1)
    cat("touched", file = file.path(tempdir(), "b1.Rout"))
    result <- make(file.path(tempdir(), "all.Rout"), ml)
    make_tree <- c("a1.Rout", "all.Rout")
    expectation <- file.path(tempdir(), make_tree)
    RUnit::checkIdentical(result, expectation)

}

test_make_phony <- function() {
    ml <- get_ml()
    make_initial()

    #% phony target
    # need to sleep on fast machine as the file modification times are identical
    # otherwise.
    Sys.sleep(1)
    ml[[2]][".PHONY"] <- TRUE
    result <- make(file.path(tempdir(), "all.Rout"), ml)
    make_tree <- c("a2.Rout", "all.Rout")
    expectation <- file.path(tempdir(), make_tree)
    # TODO: somehow RUnit::checkIdentical(result, expectation) fails?!
    RUnit::checkTrue(identical(result, expectation))

    #% rerun
    # need to sleep on fast machine as the file modification times are identical
    # otherwise.
    Sys.sleep(1)
    result <- make(file.path(tempdir(), "all.Rout"), ml)
    # TODO: somehow RUnit::checkIdentical(result, expectation) fails?!
    RUnit::checkTrue(identical(result, expectation))
}

test_make_prerequisite <- function() {
    ml <- get_ml()
    make_initial()

    #% prerequisite missing
    ml[[4]]["prerequisites"] <- file.path(tempdir(), "c1.Rout")
    RUnit::checkException(make(file.path(tempdir(), "all.Rout"), ml))
    #% file as prerequisite 
    cat("touched", file =  ml[[4]][["prerequisites"]])
    # need to sleep on fast machine as the file modification times are identical
    # otherwise.
    Sys.sleep(1)
    target <- file.path(tempdir(), "all.Rout")
    result <- make(target, ml)
    make_tree <- c("b1.Rout", "a1.Rout", "all.Rout")
    expectation <- file.path(tempdir(), make_tree)
    # TODO: somehow RUnit::checkIdentical(result, expectation) fails?!
    RUnit::checkTrue(identical(result, expectation))
}
