# Thanks to Gabor Grothendieck and Josh O'Brien on
# https://stackoverflow.com/questions/26539441/
# r-remove-null-elements-from-list-of-lists
is_null <- function(x) is.null(x) | all(sapply(x, is.null))

prune_list <- function(x) {
   x <- Filter(Negate(is_null), x)
   lapply(x, function(x) if (is.list(x)) prune_list(x) else x)
}
