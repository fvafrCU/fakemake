unlink(list.files(tempdir(), pattern = ".*\\.Rout", full.names = TRUE))
devtools::load_all(".")


dependencies <- "c(\"cleanr\", \"roxygen2\")"
## # using packman unloads fakemake as well
## dep_code <- paste("suppressmessages(pacman::p_unload(\"all\"));",
##                   "for (dep in ", dependencies, ")", 
##                   "if (! require(dep, character.only = true))", 
##                   "install.packages(dep, repos =", 
##                   "\"https://cran.uni-muenster.de/\")")
dep_code <- paste("for (dep in ", dependencies, ")", 
                  "if (! require(dep, character.only = TRUE))", 
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
                prerequisites = c("list.files(\"R\", full.names = TRUE)", 
                                  "log/dependencies.Rout")),
           list(alias = "build",
                target = "pkg <- devtools::as.package(\".\"); 
                          paste0(pkg$package, \"_\", pkg$version, \".tar.gz\")",
                code = "devtools::build(pkg = \".\", path = \".\")",
                sink = "log/build.Rout",
                prerequisites = c("log/dependencies.Rout", "log/roxygen2.Rout"))
)


print(fakemake::make("build", ml))



print(fakemake::make("log/cleanr.Rout", ml))

print(fakemake::make("log/dependencies.Rout", ml))
print(fakemake::make("log/roxygen2.Rout", ml))

