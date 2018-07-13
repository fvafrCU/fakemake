# stolen from packager
check_cyclomatic_complexity <- function(path = ".", max_complexity = 10) {
    res <- NULL
    cyclocomp <- cyclocomp::cyclocomp_package_dir(path)
    too_complex <- cyclocomp[["cyclocomp"]] > max_complexity
    if (any(too_complex)) {
        hits <- cyclocomp[too_complex, "name"]
        diff <- cyclocomp[too_complex, "cyclocomp"] - max_complexity
        res <- paste0("Exceeding maximum cyclomatic complexity of ",
            max_complexity, " for ", hits, " by ", diff, ".")
    }
    return(res)
}

package_makelist <- function() {
    roxygen_code  <- paste("tryCatch(print(roxygen2::roxygenize(\".\")),",
                           "error = identity)")
    cleanr_code <- paste("tryCatch(print(cleanr::check_directory(\"R\",",
                         "check_return = FALSE)),",
                         "cleanr = function(e) print(e))")
    spell_code <- paste("spell <- devtools::spell_check();",
                        "if (length(spell) > 0) {print(spell);",
                        "warning(\"spell check failed\")}")
    covr_code <- paste("co <- covr::package_coverage(path = \".\");",
                       "print(covr::zero_coverage(co)); print(co)")
    testthat_code <- "tryCatch(print(devtools::test(\".\")), error = identity)"
    cyclocomp_code <- "check_cyclomatic_complexity(\".\")"
    r_codes <- paste("grep(list.files(\".\",",
                                  "pattern = \".*\\\\.[rR]$\",",
                                  "recursive = TRUE),",
                                  "value = TRUE,",
                                  "pattern = \"^R/|^inst/|^tests/\")")
    dir_r <- "list.files(\"R\", full.names = TRUE, recursive = TRUE)"
    dir_man <- "list.files(\"man\", full.names = TRUE, recursive = TRUE)"
    dir_inst <- "list.files(\"inst\", full.names = TRUE, recursive = TRUE)"
    dir_tests <- "list.files(\"tests\", full.names = TRUE, recursive = TRUE)"
    pl <- list(list(alias = "roxygen2",
                    target = file.path("log", "roxygen2.Rout"),
                    code = roxygen_code,
                    prerequisites = dir_r),
               list(alias = "spell",
                    target = file.path("log", "spell.Rout"),
                    code = spell_code,
                    prerequisites = c("DESCRIPTION",
                                      file.path("log", "roxygen2.Rout"))),
               list(alias = "cyclocomp",
                    target = file.path("log", "cyclocomp.Rout"),
                    code = cyclocomp_code,
                    prerequisites = dir_r),
               list(alias = "cleanr",
                    target = file.path("log", "cleanr.Rout"),
                    code = cleanr_code,
                    prerequisites = r_codes),
               list(alias = "lint",
                    target = file.path("log", "lintr.Rout"),
                    code = "print(lintr::lint_package(path = \".\"))",
                    prerequisites = r_codes),
               list(alias = "testthat",
                    target = file.path("log", "testthat.Rout"),
                    code = testthat_code,
                    prerequisites = c(dir_r, dir_tests, dir_inst)),
               list(alias = "covr",
                    target = file.path("log", "covr.Rout"),
                    code = covr_code,
                    prerequisites = c(dir_r, dir_tests, dir_inst)),
               list(alias = "build",
                    target = "get_pkg_archive_path(absolute = FALSE)",
                    code = "print(devtools::build(pkg = \".\", path = \".\"))",
                    sink = "log/build.Rout",
                    prerequisites = c(dir_r, dir_man,
                                      "DESCRIPTION",
                                      "file.path(\"log\", \"lintr.Rout\")",
                                      "file.path(\"log\", \"cleanr.Rout\")",
                                      "file.path(\"log\", \"spell.Rout\")",
                                      "file.path(\"log\", \"cyclocomp.Rout\")",
                                      "file.path(\"log\", \"covr.Rout\")",
                                      "file.path(\"log\", \"testthat.Rout\")",
                                      "file.path(\"log\", \"roxygen2.Rout\")")),
               list(alias = "check", target = "log/check.Rout",
                    code = "check_archive_as_cran(get_pkg_archive_path())",
                    prerequisites = "get_pkg_archive_path(absolute = FALSE)"))
    return(pl)
}

log_makelist <- function() {
    fml <- provide_make_list("package")
    # add the log directory as prerequisite to all targets
    add_log <- function(x) {
        x[["prerequisites"]] <- c(".log.Rout", x[["prerequisites"]])
        return(x)
    }
    fml <- lapply(fml, add_log)
    # add the log directory
    log_dir_code <- c("usethis::use_directory(\"log\", ignore = TRUE)")
    a <- list(
              list(target = ".log.Rout",
                   code = log_dir_code
                   )
              )
    return(c(a, fml))
}
