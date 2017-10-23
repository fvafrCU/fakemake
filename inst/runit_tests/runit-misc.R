if (interactive()) devtools::load_all()

test_package_path <- function() {
    package_path <- file.path(tempdir(), "anRpackage")
    devtools::create(path = package_path)
    result <- get_pkg_archive_path(package_path)
    expectation <- file.path(tempdir(),
                             "anRpackage", "anRpackage_0.0.0.9000.tar.gz")
    RUnit::checkIdentical(result, expectation)
}

test_check_archive <- function() {
    package_path <- file.path(tempdir(), "fakepack")
    devtools::create(path = package_path)
    file.copy(system.file("templates", "throw.R", package = "fakemake"),
              file.path(package_path, "R"))
    roxygen2::roxygenize(package_path)
    tarball <- get_pkg_archive_path(package_path)
    devtools::build(pkg = package_path, path = package_path)
    result <- check_archive(tarball)
    RUnit::checkTrue(result[["status"]] == 0)
    result <- check_archive_as_cran(tarball)
    RUnit::checkTrue(result[["status"]] == 0)
}

test_touch <- function() {
    file <- tempfile()
    touch(file)
    t1 <- file.mtime(file)
    touch(file)
    t2 <- file.mtime(file)
    RUnit::checkTrue(t1 < t2)
}
