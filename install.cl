version=$(grep "Version" DESCRIPTION | cut -f2 -d" ")
R CMD build . && R CMD INSTALL fakemake_${version}.tar.gz && R-devel CMD build . && R-devel CMD INSTALL fakemake_${version}.tar.gz
