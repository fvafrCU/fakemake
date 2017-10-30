if (interactive()) devtools::load_all()

test_make_full_tree <- function() {
    old <- setwd(tempdir())
    on.exit(setwd(old))
    ml <- fakemake:::get_ml()
    fakemake:::make_initial()

    #% rerun
    result <- make("all.Rout", ml)
    expectation <- NULL
    RUnit::checkIdentical(result, expectation)
}

test_make_missing <- function() {
    old <- setwd(tempdir())
    on.exit(setwd(old))
    ml <- fakemake:::get_ml()
    fakemake:::make_initial()

    #% target missing
    unlink("all.Rout")
    result <- make("all.Rout", ml)
    expectation <- c("all.Rout")
    RUnit::checkIdentical(result, expectation)
}

test_make_newer <- function() {
    old <- setwd(tempdir())
    on.exit(setwd(old))
    ml <- fakemake:::get_ml()
    fakemake:::make_initial()

    #% prerequisite newer
    # need to sleep on fast machine as the file modification times are identical
    # otherwise.
    Sys.sleep(1)
    cat("touched", file = file.path(tempdir(), "b1.Rout"))
    result <- make("all.Rout", ml)
    expectation <- c("a1.Rout", "all.Rout")
    RUnit::checkIdentical(result, expectation)

}

test_make_phony <- function() {
    old <- setwd(tempdir())
    on.exit(setwd(old))
    ml <- fakemake:::get_ml()
    fakemake:::make_initial()

    #% phony target
    # need to sleep on fast machine as the file modification times are identical
    # otherwise.
    Sys.sleep(1)
    ml[[2]][".PHONY"] <- TRUE
    result <- make("all.Rout", ml)
    expectation <- c("a2.Rout", "all.Rout")
    # TODO: somehow RUnit::checkIdentical(result, expectation) fails?!
    RUnit::checkTrue(identical(result, expectation))

    #% rerun
    # need to sleep on fast machine as the file modification times are identical
    # otherwise.
    Sys.sleep(1)
    result <- make("all.Rout", ml)
    # TODO: somehow RUnit::checkIdentical(result, expectation) fails?!
    RUnit::checkTrue(identical(result, expectation))
}

test_make_prerequisite <- function() {
    old <- setwd(tempdir())
    on.exit(setwd(old))
    ml <- fakemake:::get_ml()
    fakemake:::make_initial()

    #% prerequisite missing
    ml[[4]]["prerequisites"] <- file.path(tempdir(), "c1.Rout")
    RUnit::checkException(make("all.Rout", ml))
    #% file as prerequisite
    # need to sleep on fast machine as the file modification times are identical
    # otherwise.
    Sys.sleep(1)
    cat("touched", file =  ml[[4]][["prerequisites"]])
    target <- "all.Rout"
    result <- make(target, ml)
    expectation <- c("b1.Rout", "a1.Rout", "all.Rout")
    # TODO: somehow RUnit::checkIdentical(result, expectation) fails?!
    RUnit::checkTrue(identical(result, expectation))
}

test_make_source_files <- function() {
    old <- setwd(tempdir())
    on.exit(setwd(old))
    warning("FIXME: The remaining code is in dontshow() in the examples ",
            "section of make()! ",
            "I haven't understood yet why is does not work in formal testing.")
}

test_make_sink <- function() {
    old <- setwd(tempdir())
    on.exit(setwd(old))
    ml <- fakemake:::get_ml()
    unlink(list.files(tempdir(), pattern = ".*\\.Rout", full.names = TRUE))
    ml[[1]][["sink"]] <- "file.path(tempdir(), \"all.txt\")"
    #% using a sink
    unlink("all.Rout")
    result <- make("all.Rout", ml)
    expectation <- c("b1.Rout", "a1.Rout", "a2.Rout", "all.Rout")
    RUnit::checkIdentical(result, expectation)
    RUnit::checkTrue(file.exists(file.path(tempdir(), "all.txt")))
}
