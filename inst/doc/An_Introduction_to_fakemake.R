str(fakemake::provide_make_list("minimal"))
ml <- fakemake::provide_make_list("minimal")
withr::with_dir(tempdir(), print(fakemake::make(ml[[1]][["target"]], ml)))
file_time <- function(files = list.files(tempdir(), full.names = TRUE)) {
    return(data.frame(path = files, modification_time = file.mtime(files)))
}
file_time(list.files(tempdir(), full.names = TRUE, pattern = "^.*\\.Rout"))
# ensure the modification time would change if the files were recreated
Sys.sleep(1)
file_time(list.files(tempdir(), full.names = TRUE, pattern = "^.*\\.Rout"))
fakemake::touch(file.path(tempdir(), "b1.Rout"))
withr::with_dir(tempdir(), print(fakemake::make(ml[[1]][["target"]], ml)))
file_time(list.files(tempdir(), full.names = TRUE, pattern = "^.*\\.Rout"))
