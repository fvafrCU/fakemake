check_makelist <- function(makelist) {

    #% is a list
    if (! is.list(makelist)) throw(paste(makelist, "is not a list."))

    #% all entries have targets
    has_target <- sapply(lapply(makelist, function(x)  names(x) == "target"), 
                         function(x) any(x))
    if (! all(has_target)) {
        throw(paste("Items", paste(which(! has_target), collapse = ", "),
                    "of list", dQuote(deparse(substitute(makelist))), 
                    "have no target entries."))
    }

    #% all entries have valid names only
    valid_names <- c("alias", "target", "code", "sink", "prerequisites", 
                     ".PHONY")
    is_valid_name <- lapply(makelist, function(x) names(x) %in% valid_names)
    if (! all(unlist(is_valid_name))) {
        all_valid_names <- sapply(is_valid_name, function(x)  all(unlist(x)))
        msg <- NULL
        for (i in seq(along = makelist)) {
            if (! all_valid_names[i]) {
                invalid_names <- names(makelist[[i]][! is_valid_name[[i]]])
                msg <- paste(msg, 
                             paste(paste(dQuote(invalid_names), 
                                         collapse = ", "),
                                   "for make target", makelist[[i]]["target"],
                                   "(item number", i,
                                   " in list", 
                                   dQuote(deparse(substitute(makelist))),
                                   ") are no valid names."), sep = "\n")
            }
        }
        throw(msg)
    }
    return(invisible(TRUE))
}

parse_make_list <- function(ml) {
    for (i in seq(along = ml)) {
        for (type in setdiff(names(ml[[i]]), "code")) {
            x <- ml[[i]][[type]]
            res <- NULL
            for (j in seq(along = x)) {
                y <- ml[[i]][[type]][[j]]
                res <- c(res, tryCatch(eval(parse(text = y)),
                                       error = function(e) return(y)))
            }
            ml[[i]][[type]] <- res
        }
        if (is.null(ml[[i]][["sink"]])) ml[[i]][["sink"]] <- ml[[i]][["target"]]
    }
    return(ml)
}

# Thanks to Gabor Grothendieck and Josh O'Brien on
# https://stackoverflow.com/questions/26539441
# /r-remove-null-elements-from-list-of-lists
is_null <- function(x) is.null(x) | all(sapply(x, is.null))

prune_list <- function(x) {
   x <- Filter(Negate(is_null), x)
   lapply(x, function(x) if (is.list(x)) prune_list(x) else x)
}
