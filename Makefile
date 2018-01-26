# Force posix:
.POSIX:

R = R-devel
Rscript = Rscript-devel
Rscript_release = Rscript-release
R_release = R-release

PKGNAME = $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS = $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  = $(shell pwd)
R_FILES = $(shell find R/ -type f -name "*.[rR]" -print)
MAN_FILES = $(shell find man/ -type f -print)
RUNIT_FILES = $(shell find tests/ -type f  -print | grep  'runit')
TESTTHAT_FILES = $(shell find tests/ -type f  -print | grep  'testthat')
VIGNETTES_FILES = $(shell find vignettes/ -type f -print)
INST_FILES = $(shell if [ -d inst/ ] ; then find inst/ -type f -print; fi)
DEPS = $(shell sed -n "s/.*\(\<.*\>\)::.*/\1/p" < Makefile | sort | uniq)
TEMP_FILE = $(shell tempfile)
LOG_DIR = log

.PHONY: all
all: $(LOG_DIR)/install.Rout

# devel stuff
.PHONY: devel
devel: vignettes build_win release use_dev_version tag_release

.PHONY: tag_release
tag_release:
	$(R) --vanilla -e 'packager::git_tag()'

.PHONY: use_dev_version
use_dev_version:
	$(Rscript) --vanilla -e 'devtools::use_dev_version()'

.PHONY: release
release: 
	echo "library('utils'); devtools::release(check = FALSE)" > /tmp/rel.R
	echo "source('/tmp/rel.R')" > ./.Rprofile
	$(R_release)
	rm /tmp/rel.R ./.Rprofile

.PHONY: build_win
build_win:
	$(Rscript_release) --vanilla -e 'devtools::build_win()'

.PHONY: vignettes
vignettes: $(R_FILES) $(MAN_FILES) $(VIGNETTES_FILES)
	$(Rscript) --vanilla -e 'devtools::build_vignettes(); lapply(tools::pkgVignettes(dir = ".")[["docs"]], function(x) knitr::purl(x, output = file.path(".", "inst", "doc", sub("\\.Rmd$$", ".R", basename(x))), documentation = 0))'

# install
.PHONY: install
install: $(LOG_DIR)/install.Rout
$(LOG_DIR)/install.Rout: cran-comments.md
	$(R) --vanilla CMD INSTALL  $(PKGNAME)_$(PKGVERS).tar.gz > $(LOG_DIR)/install.Rout 2>&1 

cran-comments.md: $(LOG_DIR)/check.Rout
	$(Rscript) --vanilla -e 'packager::provide_cran_comments(check_log = "log/check.Rout", travis_session_info = "travis-cli")' > $(LOG_DIR)/cran_comments.Rout 2>&1 

.PHONY: check
check: $(LOG_DIR)/check.Rout
$(LOG_DIR)/check.Rout: $(PKGNAME)_$(PKGVERS).tar.gz 
	export _R_CHECK_FORCE_SUGGESTS_=TRUE && \
		$(R) --vanilla CMD check --as-cran --run-donttest $(PKGNAME)_$(PKGVERS).tar.gz; \
		cp $(PKGNAME).Rcheck/00check.log $(LOG_DIR)/check.Rout

.PHONY: build
build: $(PKGNAME)_$(PKGVERS).tar.gz 
$(PKGNAME)_$(PKGVERS).tar.gz: NEWS.md README.md DESCRIPTION LICENSE \
	$(LOG_DIR)/roxygen2.Rout $(R_FILES) $(MAN_FILES) $(TESTTHAT_FILES) \
	$(RUNIT_FILES) $(VIGNETTES_FILES) $(INST_FILES) $(LOG_DIR)/spell.Rout \
	$(LOG_DIR)/check_codetags.Rout $(LOG_DIR)/news.Rout $(LOG_DIR)/runit.Rout \
	$(LOG_DIR)/testthat.Rout $(LOG_DIR)/covr.Rout $(LOG_DIR)/cleanr.Rout \
	$(LOG_DIR)/lintr.Rout $(LOG_DIR)/cyclocomp.Rout 
	$(R_release) --vanilla CMD build $(PKGSRC)

README.md: README.Rmd R/$(PKGNAME)-package.R
	$(Rscript) --vanilla -e 'knitr::knit("README.Rmd")'

$(LOG_DIR)/roxygen2.Rout: $(LOG_DIR) $(R_FILES)
	$(R) --vanilla -e 'roxygen2::roxygenize(".")' > $(LOG_DIR)/roxygen2.Rout 2>&1 

$(LOG_DIR): 
	$(Rscript) --vanilla -e 'packager:::use_directory("log", ignore = TRUE)'

.PHONY: dependencies
dependencies: $(LOG_DIR)/dependencies.Rout
$(LOG_DIR)/dependencies.Rout: Makefile $(LOG_DIR)
	$(Rscript) --vanilla -e 'deps <- unlist(strsplit("$(DEPS)", split = " ")); for (dep in deps) if (! require(dep, character.only = TRUE)) install.packages(dep, repos = "https://cran.uni-muenster.de/")' > $(LOG_DIR)/dependencies.Rout 2>&1 

# utils
utils: clean remove viz dev_install
.PHONY: clean
clean:
	rm -rf $(PKGNAME).Rcheck

.PHONY: remove
remove:
	 $(R) --vanilla CMD REMOVE  $(PKGNAME)

.PHONY: dev_install
dev_install: $(LOG_DIR)/dev_install.log
.PHONY: $(LOG_DIR)/dev_install.log
$(LOG_DIR)/dev_install.log:
	$(Rscript) --vanilla -e 'devtools::install(pkg = ".")' > $(LOG_DIR)/dev_install.log

.PHONY: viz
viz: $(LOG_DIR)/make.png 
$(LOG_DIR)/make.png: $(LOG_DIR) Makefile $(R_FILES) $(MAN_FILES) \
	$(TESTTHAT_FILES) $(RUNIT_FILES) $(VIGNETTES_FILES) $(INST_FILES)
	make -Bnd all devel utils| make2graph | dot -Tpng -o $(LOG_DIR)/make.png

# checks
.PHONY: cleanr
cleanr: $(LOG_DIR)/cleanr.Rout 
$(LOG_DIR)/cleanr.Rout: $(LOG_DIR) $(R_FILES) $(LOG_DIR)/dependencies.Rout
	$(Rscript) --vanilla -e 'tryCatch(cleanr::check_directory("R/", check_return = FALSE), cleanr = function(e) print(e))' > $(LOG_DIR)/cleanr.Rout 2>&1 

.PHONY: lintr
lintr: $(LOG_DIR)/lintr.Rout 
$(LOG_DIR)/lintr.Rout: $(LOG_DIR) $(R_FILES) $(VIGNETTES_FILES) $(LOG_DIR)/dependencies.Rout
	$(Rscript) --vanilla -e 'lintr::lint_package(path = ".")' > $(LOG_DIR)/lintr.Rout 2>&1 

.PHONY: coverage
coverage: $(LOG_DIR)/covr.Rout 
$(LOG_DIR)/covr.Rout: $(LOG_DIR) $(R_FILES) $(TESTTHAT_FILES) $(RUNIT_FILES) $(INST_FILES) $(LOG_DIR)/dependencies.Rout
	$(Rscript) --vanilla -e 'co <- covr::package_coverage(path = ".", function_exclusions = "\\.onLoad"); covr::zero_coverage(co); print(co)' > $(LOG_DIR)/covr.Rout 2>&1 

.PHONY: testthat
testthat: $(LOG_DIR)/testthat.Rout 
$(LOG_DIR)/testthat.Rout: $(LOG_DIR) $(R_FILES) $(TESTTHAT_FILES) $(INST_FILES) $(LOG_DIR)/dependencies.Rout
	$(Rscript) --vanilla -e 'devtools::test()' >  $(LOG_DIR)/testthat.Rout 2>&1

.PHONY: runit
runit: $(LOG_DIR)/runit.Rout
$(LOG_DIR)/runit.Rout: $(LOG_DIR) $(R_FILES) $(RUNIT_FILES) $(INST_FILES) $(LOG_DIR)/dependencies.Rout $(LOG_DIR)/dev_install.log
	$(Rscript) --vanilla tests/runit.R > $(LOG_DIR)/runit.Rout 2>&1 
	
.PHONY: news
news: $(LOG_DIR)/news.Rout
$(LOG_DIR)/news.Rout: $(LOG_DIR) DESCRIPTION NEWS.md $(LOG_DIR)/dependencies.Rout
	$(Rscript) --vanilla -e 'packager::check_news()' > $(LOG_DIR)/news.Rout 2>&1 

.PHONY: codetags
codetags: $(LOG_DIR)/check_codetags.Rout 
$(LOG_DIR)/check_codetags.Rout: $(LOG_DIR) $(LOG_DIR)/dependencies.Rout
	$(Rscript) --vanilla -e 'packager::check_codetags()' > $(LOG_DIR)/check_codetags.Rout 2>&1 

.PHONY: spell
spell: $(LOG_DIR)/spell.Rout
$(LOG_DIR)/spell.Rout: $(LOG_DIR) DESCRIPTION $(LOG_DIR)/roxygen2.Rout $(MAN_FILES) $(LOG_DIR)/dependencies.Rout
	$(Rscript) --vanilla -e 'spell <- devtools::spell_check(); if (length(spell) > 0) {print(spell); warning("spell check failed")} ' > $(LOG_DIR)/spell.Rout 2>&1 

.PHONY: cyclocomp
cyclocomp: $(LOG_DIR)/cyclocomp.Rout
$(LOG_DIR)/cyclocomp.Rout: $(LOG_DIR) $(LOG_DIR)/dependencies.Rout $(R_FILES)
	$(Rscript) --vanilla -e 'tryCatch(print(packager::check_cyclomatic_complexity()), error = identity)' > $(LOG_DIR)/cyclocomp.Rout 2>&1 
