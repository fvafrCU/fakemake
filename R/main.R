#' Load an Example \code{Makelist} Provided by \pkg{fakemake}.
#'
#' @param type The type of \code{makelist}.
#' @return A \code{makelist}.
#' @export
#' @examples
#' str(provide_make_list("minimal"))
provide_make_list <- function(type = "minimal") {
    if (! type %in% c("minimal")) throw(paste0("type ", type, " not known!"))
    name <- "Makefile"
    if (! is.null(type)) name <- paste0(name, "_", type)
    ml <- read_makefile(system.file("templates", name, package = "fakemake"))
    return(ml)
}

#' Add the Output of \code{\link{tempdir}} to a \code{Makelist}
#'
#' You do not want to litter your working directory? Use \R's temporary
#' directory.
#' @note This is mainly meant to run examples without touching your disk. You
#' should not bother.
#' @param x The \code{makelist}.
#' @return The \code{makelist}.
#' @export
#' @examples
#' str(add_tempdir(provide_make_list("minimal")))
add_tempdir <- function(x) {
    res <- x
    for (i in seq(along = res)) {
        res[[i]][["target"]] <- file.path(tempdir(), res[[i]][["target"]])
        if (!is.null(res[[i]][["prerequisites"]]))
            res[[i]][["prerequisites"]] <- file.path(tempdir(),
                                                    res[[i]][["prerequisites"]])
    }
    return(res)
}

#' Write a \code{Makelist} to File
#'
#' @param make_list The list to write to file.
#' @param path The path to the file.
#' @param Rbin The R binary to use in the Makefile.
#' @return See
#' \code{\link[MakefileR:write_makefile]{MakefileR::write_makefile}}.
#' @export
#' @examples
#' make_file <- file.path(tempdir(), "my_Makefile")
#' write_makefile(provide_make_list(), path = make_file)
#' file.show(make_file, pager = "cat")
write_makefile <- function(make_list, path,
                           Rbin = "Rscript-devel") {
    m <- MakefileR::makefile() +
        MakefileR::make_group(MakefileR::make_comment("Ensure POSIX"),
                              MakefileR::make_rule(".POSIX")
                              )
    m <- m + MakefileR::make_def("R_engine", Rbin)
    R_call <- "$(R_engine) --vanilla -e "
    for (e in make_list) {
        if (isTRUE(e[[".PHONY"]]))
            m <- m + MakefileR::make_rule(".PHONY", e[["target"]])
        m <- m + MakefileR::make_rule(e[["target"]],
                                      deps = e[["prerequisites"]],
                                      script = paste0(R_call,
                                                      "'fakemake::sink_all(",
                                                      '"', (e[["target"]]),
                                                      '",', e[["code"]], ")'"))
    }
    return(MakefileR::write_makefile(m, path))
}

#' Read a Makefile Into a \code{Makelist}
#'
#' @param path The path to the file.
#' @return The \code{makelist}.
#' @note This function will not read arbitrary Makefiles, just those
#' created via \code{\link{write_makefile}}! If you modify such a Makefile
#' make sure you only add simple rules like the ones you see in that file.
#' @export
#' @examples
#' make_file <- file.path(tempdir(), "Makefile")
#' write_makefile(provide_make_list(), path = make_file)
#' str(make_list <- read_makefile(path = make_file))
read_makefile <- function(path) {
    lines <- readLines(path)
    lines <- grep("^$", lines, value = TRUE, invert = TRUE)
    lines <- grep("^#.*$", lines, value = TRUE, invert = TRUE)
    lines <- grep("^\\.POSIX:$", lines, value = TRUE, invert = TRUE)
    lines <- grep("^R_engine.*$", lines, value = TRUE, invert = TRUE)
    phony_lines <- grep("^\\.PHONY:", lines, value = TRUE)
    lines <- grep("^\\.PHONY:", lines, value = TRUE, invert = TRUE)
    pattern <- paste0("\\$\\(R_engine\\) --vanilla -e ",
                      "'fakemake::sink_all\\((.*),(.*)\\)'")
    lines <- sub(pattern, "\\2", lines)
    seperator <- "@@@"
    targets <- strsplit(gsub(paste0(seperator, "\t"), ":",
                             paste(lines, collapse = seperator)),
                        split = seperator)
    targets <- unlist(targets)
    res <- list()
    for (target in targets) {
        parts  <-  trimws(unlist(strsplit(target, split = ":")))
        prerequisites <- unlist(strsplit(parts[2], split = " "))
        if (identical(prerequisites, character(0))) prerequisites <- NULL
        res[[length(res) + 1]] <- list(target = parts[1],
                                       prerequisites = prerequisites,
                                       code = parts[3])
    }
    # add phonicity to .PHONY targets. This is quite a mess.
    phony_targets <- sapply(strsplit(phony_lines, split = ": "), "[[", 2)
    for (target in phony_targets) {
        for (i in seq(along = res)) {
            if (res[[i]][["target"]] == target)
                res[[i]][[".PHONY"]] <- TRUE
        }
    }
    return(res)
}

#' Mock the Unix Make Utility
#'
#' @param make_list The \code{makelist} (a listed version of a Makefile).
#' @param name The name or alias of a make target.
#' @return A character vector containing the targets made during the current
#' run.
#' @export
#' @examples
#' str(make_list <- add_tempdir(provide_make_list(type = "minimal")))
#' make(make_list[[1]][["target"]], make_list)
#'
#' \dontshow{
#' make_list <- add_tempdir(provide_make_list(type = "minimal"))
#' make(make_list[[1]][["target"]], make_list)
#'
#' src <- file.path(tempdir(), "src")
#' dir.create(src)
#' cat('print("foo")', file = file.path(src, "foo.R"))
#' cat('print("bar")', file = file.path(src, "bar.R"))
#' make_list[[4]]["code"] <- "lapply(list.files(src, full.names = TRUE),
#'                                   source)"
#' make_list[[4]]["prerequisites"] <- "list.files(src, full.names = TRUE)"
#'
#' #% make with updated source files
#' expectation <- make_list[[4]][["target"]]
#' result <- make(make_list[[4]][["target"]], make_list)
#' RUnit::checkTrue(identical(result, expectation))
#'
#' #% rerun
#' # need to sleep on fast machine as the file modification times are identical
#' # otherwise.
#' Sys.sleep(1)
#' expectation <- NULL
#' result <- make(make_list[[4]][["target"]], make_list)
#' RUnit::checkTrue(identical(result, expectation))
#'
#' #% touch source file and rerun
#' fakemake:::touch(file.path(src, "bar.R"))
#' expectation <- make_list[[4]][["target"]]
#' result <- make(make_list[[4]][["target"]], make_list)
#' RUnit::checkTrue(identical(result, expectation))
#' }
make <- function(name, make_list) {
    res <- NULL
    # If target is a valid R expression, evaluate it.
    # Else use as is:
    targets <- sapply(lapply(make_list, "[[", "target"),
                      function(x) tryCatch(eval(parse(text = x)),
                                           error = function(e) return(x)))
    index <- which(targets == name)
    if (identical(index, integer(0))) {
        # If name doesn't match any target, see if it matches an alias.
        index <- which(lapply(make_list, "[[", "alias") == name)
    }
    if (identical(index, integer(0))) {
        if (! file.exists(name)) {
            throw(paste0("There is no rule to make ", name, "."))
        } else {
            message("Prerequisite ", name, " found.")
        }
    } else {
        target <- targets[index]
        prerequisites <- make_list[[index]][["prerequisites"]]
        if (! is.null(prerequisites)) {
            # If any prerequisite is a valid R expression, evaluate it.
            # Else use as is:
            evaluated <- NULL
            for (p in prerequisites)
                evaluated <- c(evaluated,
                               tryCatch(eval(parse(text = p)),
                                        error = function(e) return(p)))
            prerequisites <- evaluated
            for (p in sort(prerequisites)) {
                res <- c(res, make(p, make_list))
            }
        }
        is_phony <- isTRUE(make_list[[index]][[".PHONY"]])
        is_to_be_made <- is_to_be_made(target = target, is_phony = is_phony,
                                       prerequisites = prerequisites)
        if (is_to_be_made) {
            code <- make_list[[index]][["code"]]
            sink <- make_list[[index]][["sink"]]
            if (is.null(sink)) {
                sink <- target
            } else {
                sink <- tryCatch(eval(parse(text = sink)),
                                 error = function(e) return(sink))

            }
            sink_all(path = sink, code = eval(parse(text = code)))
            res <- c(res, target)
        }
    }
    return(invisible(res))
}

is_to_be_made <- function(target, prerequisites, is_phony) {
    # This is a nesting depth of 4. But the shorter
    # is_phony || !f(target) ||
    # !null(prerequisites! & any(t(prerequisites) > t(target)
    # will fail with testing coverage. covr doesn't test for all
    # combinations of composite conditions. So I stick with it.
    if (is_phony) {
        is_to_be_made <- TRUE
    } else {
        if (! file.exists(target)) {
            is_to_be_made <- TRUE
        } else {
            if (is.null(prerequisites)) {
                is_to_be_made <- FALSE
            } else {
                if (any(file.mtime(prerequisites) > file.mtime(target))) {
                    is_to_be_made <- TRUE
                } else {
                    is_to_be_made <- FALSE
                }
            }
        }
    }
    return(is_to_be_made)
}
