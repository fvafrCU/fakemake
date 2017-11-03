#' Load an Example \code{Makelist} Provided by \pkg{fakemake}.
#'
#' @inheritParams read_makefile
#' @param type The type of \code{makelist}.
#' @param prune Prune the \code{makelist} of \code{NULL} items?
#' @return A \code{makelist}.
#' @export
#' @examples
#' str(provide_make_list("minimal"))
provide_make_list <- function(type = "minimal", prune = TRUE,
                              clean_sink = FALSE) {
    pl <- list(list(alias = "lint",
                    target = file.path("log", "lintr.Rout"),
                    code = "lintr::lint_package(path = \".\")",
                    prerequisites = "list.files(\"R\", full.names = TRUE)"),
               list(alias = "build", target = "get_pkg_archive_path()",
                    code = "devtools::build(pkg = \".\", path = \".\")",
                    sink = "log/build.Rout",
                    prerequisites = c("list.files(\"R\", full.names = TRUE)",
                                      "list.files(\"man\", full.names = TRUE)",
                                      "DESCRIPTION",
                                      "file.path(\"log\", \"lintr.Rout\")")),
               list(alias = "check", target = "log/check.Rout",
                    code = "check_archive_as_cran(get_pkg_archive_path())",
                    prerequisites = "get_pkg_archive_path()"))
    ml <- switch(type,
                 "minimal" =  {
                     name <- "Makefile"
                     if (! is.null(type)) name <- paste0(name, "_", type)
                     read_makefile(system.file("templates", name,
                                               package = "fakemake"),
                                   clean_sink)
                 },
                 "package" = pl,
                 throw(paste0("type ", type, " not known!"))
                 )
    if (isTRUE(prune)) ml <- prune_list(ml)
    return(ml)
}

#' Write a \code{Makelist} to File
#'
#' The \code{makelist} is parsed before writing, so all \R code which is not in
#' a "code" item will be evaluated.
#' So if any other item's string contains code allowing for a dynamic rule,
#' for example with some "dependencies" reading
#' \code{"list.files(\"R\", full.names = TRUE)"}, the Makefile will have the
#' evaluated code, a list static list of files in the above case.
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
    check_makelist(make_list)
    make_list <- parse_make_list(make_list)
    m <- MakefileR::makefile() +
        MakefileR::make_comment(paste0("Modified by fakemake ",
                                       utils::packageVersion("fakemake"),
                                       ", do not edit by hand."))
    m <- m + MakefileR::make_group(MakefileR::make_comment("Ensure POSIX"),
                                   MakefileR::make_rule(".POSIX"))
    m <- m + MakefileR::make_def("R_engine", Rbin)
    R_call <- "$(R_engine) --vanilla -e "
    for (e in make_list) {
        if (isTRUE(e[[".PHONY"]]))
            m <- m + MakefileR::make_rule(".PHONY", e[["target"]])
        m <- m + MakefileR::make_rule(e[["target"]],
                                      deps = e[["prerequisites"]],
                                      script = paste0(R_call,
                                                      "'fakemake::sink_all(",
                                                      '"', (e[["sink"]]),
                                                      '",', e[["code"]], ")'"))
    }
    return(MakefileR::write_makefile(m, path))
}

#' Read a Makefile Into a \code{Makelist}
#'
#' @param path The path to the file.
#' @param clean_sink Remove sinks identical to corresponding targets from the
#' list? Since \code{makelists} are parsed, missing sinks are set to the
#' corresponding targets, but this makes them harder to read.
#' @return The \code{makelist}.
#' @note This function will not read arbitrary Makefiles, just those
#' created via \code{\link{write_makefile}}! If you modify such a Makefile
#' make sure you only add simple rules like the ones you see in that file.
#' @export
#' @examples
#' make_file <- file.path(tempdir(), "Makefile")
#' write_makefile(provide_make_list(), path = make_file)
#' str(make_list <- read_makefile(path = make_file))
read_makefile <- function(path, clean_sink = FALSE) {
    lines <- readLines(path)
    lines <- grep("^$", lines, value = TRUE, invert = TRUE)
    lines <- grep("^#.*$", lines, value = TRUE, invert = TRUE)
    lines <- grep("^\\.POSIX:$", lines, value = TRUE, invert = TRUE)
    lines <- grep("^R_engine.*$", lines, value = TRUE, invert = TRUE)
    phony_lines <- grep("^\\.PHONY:", lines, value = TRUE)
    lines <- grep("^\\.PHONY:", lines, value = TRUE, invert = TRUE)
    pattern <- paste0("\\$\\(R_engine\\) --vanilla -e ",
                      "'fakemake::sink_all\\((.*),(.*)\\)'")
    lines <- sub(pattern, "\\1:\\2", lines)
    separator <- "@@@"
    targets <- strsplit(gsub(paste0(separator, "\t"), ":",
                             paste(lines, collapse = separator)),
                        split = separator)
    targets <- unlist(targets)
    res <- list()
    for (target in targets) {
        parts  <-  trimws(unlist(strsplit(target, split = ":")))
        prerequisites <- unlist(strsplit(parts[2], split = " "))
        if (identical(prerequisites, character(0))) prerequisites <- NULL
        # Sink needs to go last as is it may be added by parse_make_list. Unit
        # testing may fail otherwise...
        tmp <- list(target = parts[1],
                    prerequisites = prerequisites,
                    code = parts[4],
                    sink = gsub("\"", "", parts[3]))
        if (isTRUE(clean_sink) && identical(tmp[["sink"]], tmp[["target"]]))
            tmp[["sink"]] <- NULL
        res[[length(res) + 1]] <- tmp
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
#' str(make_list <- provide_make_list(type = "minimal"))
#' withr::with_dir(tempdir(), make(make_list[[1]][["target"]], make_list))
#'
#' \dontshow{
#' withr::with_dir(tempdir(), {
#'                 str(make_list <- provide_make_list(type = "minimal"))
#'                 make(make_list[[1]][["target"]], make_list)
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
#' }
#' )

make <- function(name, make_list) {
    check_makelist(make_list)
    res <- NULL
    make_list <- parse_make_list(make_list)
    targets <- sapply(make_list, "[[", "target")
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
            for (p in sort(prerequisites)) {
                res <- c(res, make(p, make_list))
            }
        }
        is_phony <- isTRUE(make_list[[index]][[".PHONY"]])
        is_to_be_made <- is_to_be_made(target = target, is_phony = is_phony,
                                       prerequisites = prerequisites)
        if (is_to_be_made) {
            sink_all(path = make_list[[index]][["sink"]],
                     code = eval(parse(text = make_list[[index]][["code"]])))
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
