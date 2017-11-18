#' Divert Message And Output Stream to File
#'
#' All output and messages up to the first error, for example thrown by
#' \code{\link{stop}}.
#'
#' @param path The path of the file to divert to.
#' @param code The code to be executed.
#' @return \code{\link[base:invisible]{Invisibly}} \code{\link{NULL}}.
#' @export
#' @examples
#' sink_path  <- file.path(tempdir(), "sink_all.txt")
#' sink_all(sink_path, {
#'          print("some output")
#'          warning("a warning")
#'          message("a message")
#'          print("some more output")
#' })
#' cat(readLines(sink_path), sep = "\n")
sink_all <- function(path, code) {
    op <- options(warn = 1)
    on.exit(options(op))
    con <- file(path)
    sink(con, append = FALSE, type = "output")
    on.exit(sink(file = NULL, type = "output"), add = TRUE)
    sink(con, append = TRUE, type = "message")
    on.exit(sink(file = NULL, type = "message"), add = TRUE)
    on.exit(close(con), add = TRUE)
    force(code)
    return(invisible(NULL))
}
