str(fakemake::provide_make_list("minimal", clean_sink = TRUE))
ml <- fakemake::provide_make_list("minimal", clean_sink = TRUE)
withr::with_dir(tempdir(), print(fakemake::make("all.Rout", ml)))
show_file_mtime <- function(files = list.files(tempdir(), full.names = TRUE, 
                                               pattern = "^.*\\.Rout")) {
    return(file.info(files)["mtime"])
}
show_file_mtime()
# ensure the modification time would change if the files were recreated
Sys.sleep(1)
withr::with_dir(tempdir(), print(fakemake::make("all.Rout", ml)))
show_file_mtime()
fakemake::touch(file.path(tempdir(), "b1.Rout"))
withr::with_dir(tempdir(), print(fakemake::make("all.Rout", ml)))
show_file_mtime()
# touch should do the job...
Sys.sleep(1)
fakemake::touch(file.path(tempdir(), "a1.Rout"))
withr::with_dir(tempdir(), print(fakemake::make("all.Rout", ml)))
show_file_mtime()
i <- which(sapply(ml, "[[", "target") == "all.Rout")
ml[[i]]["alias"] <- "all"
fakemake::touch(file.path(tempdir(), "b1.Rout"))
withr::with_dir(tempdir(), print(fakemake::make("all", ml)))
file.show(file.path(tempdir(), "b1.Rout"), pager = "cat")
i <- which(sapply(ml, "[[", "target") == "b1.Rout")
ml[[i]]["code"]  <- paste(ml[[i]]["code"], 
                      "cat('hello, world', file = \"b1.Rout\")", 
                      "print(\"foobar\")",
                      sep = ";")
file.remove(file.path(tempdir(), "b1.Rout"))
withr::with_dir(tempdir(), print(fakemake::make("all.Rout", ml)))
file.show(file.path(tempdir(), "b1.Rout"), pager = "cat")
ml[[i]]["sink"] <- "b1.txt"
file.remove(file.path(tempdir(), "b1.Rout"))
withr::with_dir(tempdir(), print(fakemake::make("all.Rout", ml)))
file.show(file.path(tempdir(), "b1.Rout"), pager = "cat")
file.show(file.path(tempdir(), "b1.txt"), pager = "cat")
i <- which(sapply(ml, "[[", "target") == "a1.Rout")
ml[[i]]["code"]
file.show(file.path(tempdir(), "a1.Rout"), pager = "cat")
ml[[i]]["code"]  <- NULL
file.remove(file.path(tempdir(), "a1.Rout"))
withr::with_dir(tempdir(), print(fakemake::make("all.Rout", ml)))
file.size(file.path(tempdir(), "a1.Rout"))
