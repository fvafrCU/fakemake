get_ml <- function() {
    res <- prune_list(provide_make_list(type = "minimal"))
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

touch <- function(path) {
    tmp <- tempfile()
    file.copy(path, tmp)
    if (file.mtime(tmp) <= file.mtime(path)) Sys.sleep(1)
    res <- file.copy(tmp, path, overwrite = TRUE)
    return(res)
}
