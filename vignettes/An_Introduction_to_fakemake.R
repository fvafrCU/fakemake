## ------------------------------------------------------------------------
str(fakemake::provide_make_list("minimal", clean_sink = TRUE))

## ------------------------------------------------------------------------
ml <- fakemake::provide_make_list("minimal", clean_sink = TRUE)

## ------------------------------------------------------------------------
withr::with_dir(tempdir(), print(fakemake::make("all.Rout", ml)))

## ------------------------------------------------------------------------
show_file_mtime <- function(files = list.files(tempdir(), full.names = TRUE, 
                                               pattern = "^.*\\.Rout")) {
    return(file.info(files)["mtime"])
}
show_file_mtime()

## ------------------------------------------------------------------------
# ensure the modification time would change if the files were recreated
Sys.sleep(1)
withr::with_dir(tempdir(), print(fakemake::make("all.Rout", ml)))
show_file_mtime()

## ------------------------------------------------------------------------
fakemake::touch(file.path(tempdir(), "b1.Rout"))
withr::with_dir(tempdir(), print(fakemake::make("all.Rout", ml)))
show_file_mtime()

## ---- echo = FALSE-------------------------------------------------------
# touch should do the job...
Sys.sleep(1)

## ------------------------------------------------------------------------
fakemake::touch(file.path(tempdir(), "a1.Rout"))
withr::with_dir(tempdir(), print(fakemake::make("all.Rout", ml)))
show_file_mtime()

