devtools::load_all(".")
makelist <- list(list(target = "a1.Rout", code = 'print("all")', prerequisits = c("a1.Rout", "a2.Rout")),
                 list(target = "a2.Rout", code = 'print("a2")'),
                 list(target = "a1.Rout", code = 'print("a1")', prerequisits = c("b1.Rout")),
                 list(target = "b1.Rout", code = 'print("b1")')
                 )
write_makefile <- function(make_list, path = "tmp_makefile") {
    m <- MakefileR::makefile()
    for (e in make_list) {
        m <- m + MakefileR::make_rule(e[["target"]], deps = e[["prerequisits"]], 
                                      script = e[["code"]])
    }
    MakefileR::write_makefile(m, path)
}
write_makefile(makelist)

read_makefile <- function(path) {
    lines <- readLines(path)
    lines <- grep("^$", lines, value = TRUE, invert = TRUE)
    lines <- grep("^#.*$", lines, value = TRUE, invert = TRUE)
    seperator1 <- "@@@"
    seperator2 <- "###"
    items <- strsplit(gsub(paste0(seperator1, "\t"), ":", 
                           paste(lines, collapse = seperator1)), 
                      split = seperator1)
    items <- unlist(items)
    make_list <- list()
    for (i in items) {
        parts  <-  unlist(strsplit(i, split = ":"))
        #XXX one list per item
        make_list <- c(make_list, list(target = parts[1],
                                       prerequisits = parts[2],
                                       code = parts[3]))
    }
    return(make_list)


}
read_makefile("tmp_makefile")

make <- function(target, makelist) {
    prerequisits <- makelist["target"]["prerequisits"]
    for (p in prerequisits) make(p, makelist)
    if (file.exists(target) && all(file.exists(prerequisits)) && 
        file.mtime(prerequisits) older file.mtime(target)) {
        # skip
    } else {
        code <- makelist["target"]["code"]
        sink_all(target, code)
    }
}
