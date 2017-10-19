unlink(list.files(tempdir(), pattern = ".*\\.Rout", full.names = TRUE))
devtools::load_all(".")


dependencies <- "c(\"cleanr\", \"roxygen2\")"
dep_code <- paste("for (dep in ", dependencies, 
                  ") if (! require(dep, character.only = TRUE))", 
                  "install.packages(dep, repos =", 
                  "\"https://cran.uni-muenster.de/\")")
cleanr_code <- paste('tryCatch(cleanr::check_directory("R/",', 
                     'check_return = FALSE), cleanr = function(e) print(e))')

R_codes <- "list.files(\"R\", full.names = TRUE)"
ml <- list(list(target = file.path("log", "dependencies.Rout"),
                code = dep_code,
                .PHONY = TRUE),
           list(target = file.path("log", "roxygen2.Rout"),
                code = "roxygen2::roxygenize(\".\")",
                prerequisites = "list.files(\"R\", full.names = TRUE)"),
           list(target = file.path("log", "cleanr.Rout"),
                code = cleanr_code,
                prerequisites = c("list.files(\"R\", full.names = TRUE)", "log/dependencies.Rout"))
)
print(make("log/cleanr.Rout", ml))

print(make("log/dependencies.Rout", ml))
print(make("log/roxygen2.Rout", ml))

