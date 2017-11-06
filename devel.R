a  <- sub("(email)", "\n\t\\1",
          packager::author_at_r("Andreas Dominik", "Cullmann", "fvafrcu@arcor.de"))

packager::set_package_info(".", author_at_r = a,
       title = "Mock the Unix Make Utility", 
       description = "Use R as a minimal build system. This might come in handy if you are developing R packages and can not use a proper build system.",
       details = NULL)
unlink(list.files(tempdir(), pattern = ".*\\.Rout", full.names = TRUE))
devtools::load_all(".")
str(ml <- provide_make_list("minimal"))


#% code does not create target: infill
str(ml <- provide_make_list("package"))
ml[[1]]$sink <- "log/foo.Rout"
print(fakemake::make("lint", ml, force = TRUE))
print(fakemake::make("build", ml))

#% This goes into packager
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

ml <- list(list(target = file.path("log", "dependencies.Rout"),
                code = dep_code),
           list(target = file.path("log", "roxygen2.Rout"),
                code = "roxygen2::roxygenize(\".\")",
                prerequisites = "list.files(\"R\", full.names = TRUE)"),
           list(target = file.path("log", "cleanr.Rout"),
                code = cleanr_code,
                prerequisites = c("list.files(\"R\", full.names = TRUE)", 
                                  "log/dependencies.Rout")),
           list(alias = "build",
                target = "get_pkg_archive_path()",
                code = "devtools::build(pkg = \".\", path = \".\")",
                sink = "log/build.Rout",
                prerequisites = c("log/dependencies.Rout", "log/roxygen2.Rout", 
                                  "DESCRIPTION")),
           list(alias = "check",
                target = "log/check.Rout",
                code = "check_archive_as_cran(get_pkg_archive_path())",
                prerequisites = "get_pkg_archive_path()")
)

parse_make_list(ml)



write_makefile(ml, "foo")
print(fakemake::make("log/cleanr.Rout", ml))

print(fakemake::make("log/dependencies.Rout", ml))
print(fakemake::make("log/roxygen2.Rout", ml))

print(fakemake::make("check", ml))
