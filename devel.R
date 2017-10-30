    a  <- sub("(email)", "\n\t\\1",
               packager::author_at_r("Andreas Dominik", "Cullmann", "fvafrcu@arcor.de"))

set_package_info(".", author_at_r = NULL,
       title = "What it Does (One Line, Title Case)", description = NULL,
       details = NULL)
unlink(list.files(tempdir(), pattern = ".*\\.Rout", full.names = TRUE))
devtools::load_all(".")


#% This goes into vignette
ml <- list(list(alias = "lint",
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
                prerequisites = "get_pkg_archive_path()")
)
ml <- provide_make_list("package")
ml <- add_tempdir(ml)
pkg_path <- file.path(tempdir(), "fakepack") 
devtools::create(pkg_path)
file.copy(system.file("templates", "throw.R", package = "fakemake"), 
          file.path(pkg_path, "R"))

sub <- paste0("\"", pkg_path, "\"")
lapply(ml, function(x) lapply(x, function (x) gsub("\"\\.\"", sub, x)))

print(fakemake::make("build", ml))
print(fakemake::make("lint", ml))
print(fakemake::make("check", ml))
touch("DESCRIPTION")
print(fakemake::make("check", ml))


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
