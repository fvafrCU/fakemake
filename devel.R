devtools::load_all(".")
make_list <- provide_make_list()
unlink(list.files(pattern = ".*\\.Rout"))
print(make("all.Rout", make_list))
unlink("a2.Rout")
print(make("all.Rout", make_list))

