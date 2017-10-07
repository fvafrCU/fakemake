#' Load an Example Makelist Provided by \pkg{fakemake}.
#'
#' @param type The type of makelist.
#' @return A makelist.
#' @export
#' @examples
#' str(provide_make_list("minimal"))
provide_make_list <- function(type = "minimal") {
    if (! type %in% c("minimal")) throw("type ", type, " not known!")
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
#' make_file <- file.path(tempdir(), "Makefile")
#' write_makefile(provide_make_list(), path = make_file)
#' file.show(make_file, pager = "cat")
write_makefile <- function(make_list, path, 
                           Rbin = "Rscript-devel") {
    m <- MakefileR::makefile() + MakefileR::make_def("R_engine", Rbin)
    R_call <- "$(R_engine) --vanilla -e "
    for (e in make_list) {
        m <- m + MakefileR::make_rule(e[["target"]], 
                                      deps = e[["prerequisites"]], 
                                      script = paste0(R_call, 
                                                      "'fakemake::sink_all(", 
                                                      '"', (e[["target"]]), '",', 
                                                      e[["code"]], ")'"))
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
    lines <- grep("^R_engine.*$", lines, value = TRUE, invert = TRUE)
    pattern <- paste0("\\$\\(R_engine\\) --vanilla -e ",
                      "'fakemake::sink_all\\((.*),(.*)\\)'")
    lines <- sub(pattern, "\\2", lines)
    seperator1 <- "@@@"
    seperator2 <- "###"
    targets <- strsplit(gsub(paste0(seperator1, "\t"), ":", 
                             paste(lines, collapse = seperator1)), 
                        split = seperator1)
    targets <- unlist(targets)
    make_list <- list()
    for (target in targets) {
        parts  <-  trimws(unlist(strsplit(target, split = ":")))
        prerequisites <- unlist(strsplit(parts[2], split = " "))
        if (identical(prerequisites, character(0))) prerequisites <- NULL
        make_list[[length(make_list)+1]] <- list(target = parts[1],
                                                 prerequisites = prerequisites,
                                                 code = parts[3])
    }
    return(make_list)
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
    index <- which(lapply(make_list, "[[", "target") == target)
   prerequisites <- make_list[[index]][["prerequisites"]]
    for (p in prerequisites) make(p, make_list)
    if (file.exists(target) && 
        ! is.null(prerequisites) && all(file.exists(prerequisites)) && 
        all(file.mtime(prerequisites) <= file.mtime(target))) {
        # Skip as the target has no missing or modified prerequisites.
        # !(!t | !p | p>t)
        # !!t & !!p & !p>t
        # t & p & p<=t
    } else {
        # !t | !p | p>t
        code <- make_list[[index]][["code"]]
        sink_all(path = target, code = eval(parse(text = code)))
    }
    #    make_it <- TRUE
    #    # This is for test coverage's sake. 
    #    # Shorter is e(t) && ! is.null(p) && all(e(p)) && all(t(p) <= t(t)),
    #    # where e() := file.exists() and t() := file.mtime().
    #    if (file.exists(target))
    #        if (! is.null(prerequisites))
    #            if (all(file.exists(prerequisites)))
    #                if (all(file.mtime(prerequisites) <= file.mtime(target)))
    #                    make_it <- FALSE
    #    if (make_it) {
    #        code <- make_list[[index]][["code"]]
    #        sink_all(path = target, code = eval(parse(text = code)))
    #    }
    return(invisible(NULL))
}

