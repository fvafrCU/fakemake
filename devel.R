unlink(list.files(tempdir(), pattern = ".*\\.Rout", full.names = TRUE))
devtools::load_all(".")
ml <- list(list(target = file.path("log", "roxygen2.Rout"),
                code = 'roxygen2::roxygenize(".")',
                prerequisites = 'list.files("R/", full.names = TRUE)'))

print(make("log/roxygen2.Rout", ml))

