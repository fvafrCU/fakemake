devtools::load_all(".")

default_make_list <- function(type = "minimal") {
    name <- "Makefile"
    if (! is.null(type)) name <- paste0(name, "_", type)
    ml <- read_makefile(system.file("inst", "templates", name, 
                                    package = "fakemake"))
    return(ml)

}
str(default_make_list("minimal"))

write_makefile <- function(make_list, path, 
                           R = "Rscript-devel") {
    m <- MakefileR::makefile() + MakefileR::make_def("R_engine", R)
    R_call <- "$(R_engine) --vanilla -e "
    for (e in make_list) {
        m <- m + MakefileR::make_rule(e[["target"]], 
                                      deps = e[["prerequisites"]], 
                                      script = paste0(R_call, 
                                                     "'fakemake::sink_all(", 
                                                     '"', (e[["target"]]), '",', 
                                                     e[["code"]], ")'"))
    }
    MakefileR::write_makefile(m, path)
}
make_file <- file.path(tempdir(), "Makefile")
write_makefile(default_make_list(), path = make_file)
file.show(make_file)

read_makefile <- function(path) {
    lines <- readLines(path)
    lines <- grep("^$", lines, value = TRUE, invert = TRUE)
    lines <- grep("^#.*$", lines, value = TRUE, invert = TRUE)
    lines <- grep("^R_engine.*$", lines, value = TRUE, invert = TRUE)
    pattern <- paste0("\\$\\(R_engine\\) --vanilla -e ",
                      "'fakemake::sink_all\\((.*),(.*)\\)'")
    lines <- sub(pattern, "\\2", lines)
    seperator1 <- "@@@"
    seperator2 <- "###"
    targets <- strsplit(gsub(paste0(seperator1, "\t"), ":", 
                           paste(lines, collapse = seperator1)), 
                      split = seperator1)
    targets <- unlist(targets)
    make_list <- list()
    for (target in targets) {
        parts  <-  trimws(unlist(strsplit(target, split = ":")))
        #XXX one list per item
        make_list[[length(make_list)+1]] <- list(target = parts[1],
                                                 prerequisites = parts[2],
                                                 code = parts[3])
    }
    return(make_list)
}
make_file <- file.path(tempdir(), "Makefile")
write_makefile(default_make_list(), path = make_file)
str(makelist <- read_makefile(path = make_file))

make <- function(target, makelist) {
    index <- which(lapply(makelist, "[[", "target") == target)
    prerequisites <- makelist[[index]][["prerequisites"]]
    for (p in prerequisites) make(p, makelist)
    if (file.exists(target) && 
        ! is.null(prerequisites) && all(file.exists(prerequisites)) && 
        all(file.mtime(prerequisites) < file.mtime(target))) {
        # skip
    } else {
        code <- makelist[[index]][["code"]]
        sink_all(path = target, code = eval(parse(text = code)))
    }
}
makelist <- default_make_list()
make("all.Rout", makelist)
