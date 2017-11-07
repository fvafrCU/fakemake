test_provide_makefile <- function() {
    # This test is broken. I do not know, why result would be a list of 10 and
    # why the 5th item is an error where the list breaks.
    make_list <- fakemake:::provide_make_list(type = "minimal")

    result <- fakemake:::makelist2igraph(make_list, root = "all.Rout")
    RUnit::checkTrue(length(result) == 10)
    RUnit::checkException(result[[5]])

    result <- fakemake:::makelist2igraph(make_list, root = NULL)
    RUnit::checkTrue(length(result) == 10)
    RUnit::checkException(result[[5]])
}
