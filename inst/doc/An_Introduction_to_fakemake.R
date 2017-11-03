str(fakemake::provide_make_list("minimal", clean_sink = TRUE))
ml <- fakemake::provide_make_list("minimal")
withr::with_dir(tempdir(), print(fakemake::make(ml[[1]][["target"]], ml)))
show_file_mtime <- function(files = list.files(tempdir(), full.names = TRUE, 
                                               pattern = "^.*\\.Rout")) {
    return(file.info(files)["mtime"])
}
show_file_mtime()
# ensure the modification time would change if the files were recreated
Sys.sleep(1)
withr::with_dir(tempdir(), print(fakemake::make(ml[[1]][["target"]], ml)))
show_file_mtime()
fakemake::touch(file.path(tempdir(), "b1.Rout"))
withr::with_dir(tempdir(), print(fakemake::make(ml[[1]][["target"]], ml)))
show_file_mtime()
