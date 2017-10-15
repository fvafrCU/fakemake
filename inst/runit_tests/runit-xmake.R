test_make_full_tree <- function() {
    ml <- fakemake:::get_ml()
    fakemake:::make_initial()

    #% rerun
    result <- make(file.path(tempdir(), "all.Rout"), ml)
    expectation <- NULL
    RUnit::checkIdentical(result, expectation)
}

test_make_missing <- function() {
    ml <- fakemake:::get_ml()
    fakemake:::make_initial()

    #% target missing
    unlink(file.path(tempdir(), "all.Rout"))
    result <- make(file.path(tempdir(), "all.Rout"), ml)
    make_tree <- c("all.Rout")
    expectation <- file.path(tempdir(), make_tree)
    RUnit::checkIdentical(result, expectation)
}

test_make_newer <- function() {
    ml <- fakemake:::get_ml()
    fakemake:::make_initial()

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
    ml <- fakemake:::get_ml()
    fakemake:::make_initial()

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
    ml <- fakemake:::get_ml()
    fakemake:::make_initial()

    #% prerequisite missing
    ml[[4]]["prerequisites"] <- file.path(tempdir(), "c1.Rout")
    RUnit::checkException(make(file.path(tempdir(), "all.Rout"), ml))
    #% file as prerequisite 
    # need to sleep on fast machine as the file modification times are identical
    # otherwise.
    Sys.sleep(1)
    cat("touched", file =  ml[[4]][["prerequisites"]])
    target <- file.path(tempdir(), "all.Rout")
    result <- make(target, ml)
    make_tree <- c("b1.Rout", "a1.Rout", "all.Rout")
    expectation <- file.path(tempdir(), make_tree)
    # TODO: somehow RUnit::checkIdentical(result, expectation) fails?!
    RUnit::checkTrue(identical(result, expectation))
}
