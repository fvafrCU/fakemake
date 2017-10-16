#' Load an Example Makelist Provided by \pkg{fakemake}.
#'
#' @param type The type of makelist.
#' @return A makelist.
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

#' Write a Makelist to File
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

#' Read a Makefile into a Makelist
#'
#' @param path The path to the file.
#' @return The makelist.
#' @section Warning This function will not read arbitrary Makefiles, just those
#' created via \code{\link{write_makefile()}}! If you modify such a Makefile
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
#' @param make_list The makelist (a listed version of a Makefile).
#' @param target The make target.
#' @return \code{\link[base:NULL]{base::NULL}}.
#' @export
#' @examples
#' str(make_list <- provide_make_list())
#' make("all.Rout", make_list)
make <- function(target, make_list) {
    res <- NULL
    warning(target)
    index <- which(lapply(make_list, "[[", "target") == target)
    if (identical(index, integer(0))) {
        if (! file.exists(target)) {
            throw(paste0("There is no rule to make ", target, "."))
        } else {
            message("Prerequisite ", target, " found.")
        }
    } else {
        prerequisites <- make_list[[index]][["prerequisites"]]
        is_phony <- isTRUE(make_list[[index]][[".PHONY"]])
        if (! is.null(prerequisites)) {
            # If prerequisites is a valid R expression, evaluate it. 
            # Else use as is:
            prerequisites <- tryCatch(eval(parse(text = prerequisites)),
                          error = function(e) return(prerequisites))
            for (p in sort(prerequisites)) {
                warning("prereq ", p)
                res <- c(res, make(p, make_list))
            }
        }
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
        if (is_to_be_made) {
            code <- make_list[[index]][["code"]]
            sink_all(path = target, code = eval(parse(text = code)))
            res <- c(res, target)
        }
    }
    return(invisible(res))
}
