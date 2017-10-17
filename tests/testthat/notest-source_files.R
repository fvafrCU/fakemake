testthat::context("Testing source files")
testthat::test_that("foo", 
                    {
                        make_list <- add_tempdir(provide_make_list(type = "minimal"))
                        make(make_list[[1]][["target"]], make_list)

                        src <- file.path(tempdir(), "src")
                        dir.create(src)
                        cat('print("foo")', file = file.path(src, "foo.R"))
                        cat('print("bar")', file = file.path(src, "bar.R"))
                        make_list[[4]]["code"] <- "lapply(list.files(src, full.names = TRUE), source)"
                        make_list[[4]]["prerequisites"] <- "list.files(src, full.names = TRUE)"
                        prerequisites <- make_list[[4]]["prerequisites"]
                        prerequisites <- tryCatch(eval(parse(text = prerequisites)),
                                                  error = function(e) return(prerequisites))
                        for (target in prerequisites) {
                            index <- which(lapply(make_list, "[[", "target") == target)
                            if (identical(index, integer(0))) {
                                if (! file.exists(target)) {
                                    throw(paste0("There is no rule to make ", target, "."))
                                } else {
                                    message("Prerequisite ", target, " found.")
                                }
                            }
                        }

                        #% make with updated source files
                        expectation <- make_list[[4]][["target"]]
                        result <- make(make_list[[4]][["target"]], make_list)
                        #testthat::expect_identical(result, expectation)
})
