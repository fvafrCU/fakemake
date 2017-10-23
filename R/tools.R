get_pkg_archive_path <- function(path = ".") {
    # return the tarball path according to the DESCRIPTION file. It doesn't have
    # to exists!
    pkg <- devtools::as.package(path) 
    tgz <- file.path(pkg$path, 
                     paste0(pkg$package, "_", pkg$version, ".tar.gz"))
    return(tgz)
}

check_archive <- function(path, cmdargs = NULL) {
    # heavily borrowing from rcmdcheck::rcmdcheck()
    withr::with_dir(dirname(path),
                    out <- callr::rcmd_safe("check", 
                                            cmdargs = c(basename(path), 
                                                        cmdargs),
                                            libpath = .libPaths(), 
                                            callback =  writeLines))
    invisible(out)
}

check_archive_as_cran <- function(path) {
    return(check_archive(path, cmdargs = "--as-cran")) 
}
