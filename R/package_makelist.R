package_makelist <- function() {
    cleanr_code <- paste("tryCatch(cleanr::check_directory(\"R/\",",
                         "check_return = FALSE),",
                         "cleanr = function(e) print(e))")
    spell_code <- paste("spell <- devtools::spell_check();",
                        "if (length(spell) > 0) {print(spell);",
                        "warning(\"spell check failed\")}")
    covr_code <- paste("co <- covr::package_coverage(path = \".\");",
                       "print(covr::zero_coverage(co)); print(co)")
    testthat_code <- paste("tryCatch(testthat::test_package(\".\"),",
                           "error = function(e) print(e))")
    list_of_r_files_code <- paste("grep(list.files(\".\",",
                                  "pattern = \".*\\\\.[rR]$\",",
                                  "recursive = TRUE),",
                                  "value = TRUE,",
                                  "pattern = \"^R/|^inst/|^tests/\")")
    dir_r <- "list.files(\"R\", full.names = TRUE, recursive = TRUE)"
    dir_man <- "list.files(\"man\", full.names = TRUE, recursive = TRUE)"
    dir_inst <- "list.files(\"inst\", full.names = TRUE, recursive = TRUE)"
    dir_tests <- "list.files(\"tests\", full.names = TRUE, recursive = TRUE)"
    pl <- list(list(target = file.path("log", "list_of_r_codes.txt"),
                    prerequisites = list_of_r_files_code
                    ),
               list(alias = "roxygen2",
                    target = file.path("log", "roxygen2.Rout"),
                    code = "roxygen2::roxygenize(\".\")",
                    prerequisites = "list.files(\"R\", full.names = TRUE)"),
               list(alias = "spell",
                    target = file.path("log", "spell.Rout"),
                    code = spell_code,
                    prerequisites = c("DESCRIPTION",
                                      file.path("log", "roxygen2.Rout"))),
               list(alias = "cleanr",
                    target = file.path("log", "cleanr.Rout"),
                    code = cleanr_code,
                    prerequisites = file.path("log", "list_of_r_codes.txt")),
               list(alias = "lint",
                    target = file.path("log", "lintr.Rout"),
                    code = "lintr::lint_package(path = \".\")",
                    prerequisites = file.path("log", "list_of_r_codes.txt")),
               list(alias = "testthat",
                    target = file.path("log", "testthat.Rout"),
                    code = testthat_code,
                    prerequisites = c(file.path("log", "list_of_r_codes.txt"),
                                      dir_tests, dir_inst)),
               list(alias = "covr",
                    target = file.path("log", "covr.Rout"),
                    code = covr_code,
                    prerequisites = c(file.path("log", "list_of_r_codes.txt"),
                                      dir_tests, dir_inst)),
               list(alias = "build", target = "get_pkg_archive_path()",
                    code = "devtools::build(pkg = \".\", path = \".\")",
                    sink = "log/build.Rout",
                    prerequisites = c(dir_r, dir_man,
                                      "DESCRIPTION",
                                      "file.path(\"log\", \"lintr.Rout\")",
                                      "file.path(\"log\", \"cleanr.Rout\")",
                                      "file.path(\"log\", \"spell.Rout\")",
                                      "file.path(\"log\", \"covr.Rout\")",
                                      "file.path(\"log\", \"testthat.Rout\")",
                                      "file.path(\"log\", \"roxygen2.Rout\")")),
               list(alias = "check", target = "log/check.Rout",
                    code = "check_archive_as_cran(get_pkg_archive_path())",
                    prerequisites = "get_pkg_archive_path()"))
    return(pl)
}
