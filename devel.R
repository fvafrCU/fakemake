devtools::load_all(".")
make_list <- provide_make_list()
make("all.Rout", make_list)

