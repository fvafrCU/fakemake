test_make_minimal <- function() {
    ml <- fakemake:::prune_list(provide_make_list(type = "minimal"))
    for (i in seq(along = ml)) {
        ml[[i]][["target"]] <- file.path(tempdir(), ml[[i]][["target"]])
        if (!is.null(ml[[i]][["prerequisites"]]))
            ml[[i]][["prerequisites"]] <- file.path(tempdir(),
                                                    ml[[i]][["prerequisites"]])
    }

    # initial full tree
    result <- make(file.path(tempdir(), "all.Rout"), ml)
    make_tree <- c("b1.Rout", "a1.Rout", "a2.Rout", "all.Rout")
    expectation <- file.path(tempdir(), make_tree)
    RUnit::checkIdentical(result, expectation)

    # rerun
    result <- make(file.path(tempdir(), "all.Rout"), ml)
    expectation <- NULL
    RUnit::checkIdentical(result, expectation)

    # target missing
    unlink(file.path(tempdir(), "all.Rout"))
    result <- make(file.path(tempdir(), "all.Rout"), ml)
    make_tree <- c("all.Rout")
    expectation <- file.path(tempdir(), make_tree)
    RUnit::checkIdentical(result, expectation)

    # prerequisite newer
    cat("touched", file = file.path(tempdir(), "b1.Rout"))
    result <- make(file.path(tempdir(), "all.Rout"), ml)
    make_tree <- c("a1.Rout", "all.Rout")
    expectation <- file.path(tempdir(), make_tree)
    RUnit::checkIdentical(result, expectation)

    # phony target
    ml[[2]][".PHONY"] <- TRUE
    result <- make(file.path(tempdir(), "all.Rout"), ml)
    make_tree <- c("a2.Rout", "all.Rout")
    expectation <- file.path(tempdir(), make_tree)
    RUnit::checkIdentical(result, expectation)

    # rerun
    result <- make(file.path(tempdir(), "all.Rout"), ml)
    RUnit::checkIdentical(result, expectation)

    # prerequisite missing
    ml[[4]]["prerequisites"] <- file.path(tempdir(), "c1.Rout")
    RUnit::checkException(make(file.path(tempdir(), "all.Rout"), ml))

}
