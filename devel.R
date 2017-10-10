devtools::load_all(".")
make_list <- provide_make_list()
write_makefile(make_list, path = "nomakefile")

names(make_list) <- sapply(make_list, "[[", "target")


write_makefile(make_list, path = "nomakefile")
file.show("nomakefile", pager = "cat")
nm <- read_makefile("nomakefile")
unlink(list.files(pattern = ".*\\.Rout"))
print(make("all.Rout", nm))

unlink("a2.Rout")
print(make("all.Rout", make_list))

unlink("a1.Rout")
print(make("all.Rout", make_list))

unlink("b1.Rout")
print(make("all.Rout", make_list))

make_list[["a2.Rout"]][".PHONY"] <- TRUE
print(make("all.Rout", make_list))
