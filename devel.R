devtools::load_all(".")
makelist <- list(list(target = "all.Rout", code = 'print("all")', prerequisits = c("a1.Rout", "a2.Rout")),
                 list(target = "a2.Rout", code = 'print("a2")'),
                 list(target = "a1.Rout", code = 'print("a1")', prerequisits = c("b1.Rout")),
                 list(target = "b1.Rout", code = 'print("b1")')
                 )
write_makefile <- function(make_list, path = "Makefile", R = "Rscript-devel") {
    m <- MakefileR::makefile() + MakefileR::make_def("R_engine", R)
    R_call <- "$(R_engine) --vanilla -e "
    for (e in make_list) {
        m <- m + MakefileR::make_rule(e[["target"]], deps = e[["prerequisits"]], 
                                      script = paste0(R_call, 
                                                     "'fakemake::sink_all(", 
                                                     '"', (e[["target"]]), '",', 
                                                     e[["code"]],
                                                     ")'"))
    }
    MakefileR::write_makefile(m, path)
}
write_makefile(makelist)

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
                                                 prerequisits = parts[2],
                                                 code = parts[3])
    }
    return(make_list)
}
nomakelist <- read_makefile("Makefile")
write_makefile(nomakelist, path = "nomakefile")

make <- function(target, makelist) {
    index <- which(lapply(makelist, "[[", "target") == target)
    prerequisits <- makelist[[index]][["prerequisits"]]
    for (p in prerequisits) make(p, makelist)
    if (file.exists(target) && 
        ! is.null(prerequisits) && all(file.exists(prerequisits)) && 
        all(file.mtime(prerequisits) < file.mtime(target))) {
        # skip
    } else {
        code <- makelist[[index]][["code"]]
        sink_all(path = target, code = eval(parse(text = code)))
    }
}
make("all.Rout", makelist)
