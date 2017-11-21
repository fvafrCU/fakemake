Dear CRAN Team,
this is a resubmission of the inital commit of package 'fakemake'. 
Thanks to Uwe Ligges' hints I have added the following changes:

* Replaced file.show(x, pager = "cat") with cat(readLines(x), sep = "\"n) in
  examples as they did not pass checks on windows.
* Fixed example path for windows. 

Please consider uploading it to CRAN.

Best, Dominik

# Package fakemake 1.0.1
## Test  environments 
- R Under development (unstable) (2017-11-07 r73685)
  Platform: x86_64-pc-linux-gnu (64-bit)
  Running under: Devuan GNU/Linux 1 (jessie)
- R version 3.4.2 (2017-01-27)
  Platform: x86_64-pc-linux-gnu (64-bit)
  Running under: Ubuntu 14.04.5 LTS
- win-builder (devel)
- R version 3.3.1 (2016-06-21)
  Platform: x86_64-w64-mingw32/x64 (64-bit)
  Running under: Windows 7 x64 (build 7601) Service Pack 1

## R CMD check results
0 errors | 0 warnings | 1 note 


> On Fri, Nov 17, 2017 14:26:23, Uwe Ligges wrote:
> Thanks, unfortunately your package fails in our checks as it tries to open a
> new console and then I get under WIndows, for example (with ConEmu):
> 
> 
> /usr/bin/cat: d:\temp\RtmpK8Ak65/my_Makefile: No such file or directory
> 
> -> Does cat need forward slashes?
> 
> 
> Current directory:
> d:\library-devel\fakemake.Rcheck\examples_i386
> 
> Command to be executed:
> "d:\compiler\bin\cat.exe"  "d:\temp\RtmpK8Ak65/my_Makefile"
> 
> 
> ConEmuC: Root process was alive less than 10 sec, ExitCode=1.
> Press Enter or Esc to close console...
> 
> 
> And now the check process waits infinitly for my interaction. That must not
> happen during the checks.
> 
> 
> Or if I run this in the standard Windows command shell, I simply get an
> ERROR without the above message.
> 
> 
> Best,
> Uwe Ligges
> 
> 
> 
> On 09.11.2017 15:05, CRAN submission wrote:
> >[This was generated from CRAN.R-project.org/submit.html]
> >
> >The following package was uploaded to CRAN:
> >===========================================
> >
> >Package Information:
> >Package: fakemake
> >Version: 1.0.0
> >Title: Mock the Unix Make Utility
> >Author(s): Andreas Dominik Cullmann [aut, cre]
> >Maintainer: Andreas Dominik Cullmann <fvafrcu@arcor.de>
> >Depends: R (>= 3.3.3)
> >Suggests: knitr, rmarkdown, testthat, RUnit, devtools, rprojroot,
> >   roxygen2, hunspell, cleanr, lintr, covr
> >Description: Use R as a minimal build system. This might come in handy if
> >   you are developing R packages and can not use a proper build
> >   system. Stay away if you can (use a proper build system).
> >License: BSD_2_clause + file LICENSE
> >Imports: MakefileR, callr, withr, utils, igraph, graphics
> >
> >
> >The maintainer confirms that he or she
> >has read and agrees to the CRAN policies.
> >
> >Submitter's comment: Dear CRAN Team,
> >I've written a package to use R as a
> >   minimal build system, because I sometimes
> >do not have
> >   a proper build system at hand and am not entitled to
> >   install
> >software due to restrictive software
> >   policies.
> >I don't know if that is a common setup, but
> >   maybe there is someone else out
> >there who might
> >   consider it helpful.
> >
> >Please consider uploading it to
> >   CRAN.
> >Best, Dominik
> >
> ># Package fakemake 0.5.0
> >## Test
> >    environments
> >- R Under development (unstable)
> >   (2017-11-07 r73685)
> >   Platform: x86_64-pc-linux-gnu
> >   (64-bit)
> >   Running under: Devuan GNU/Linux 1
> >   (jessie)
> >- R version 3.4.2 (2017-01-27)
> >   Platform:
> >   x86_64-pc-linux-gnu (64-bit)
> >   Running under: Ubuntu
> >   14.04.5 LTS
> >- win-builder (devel)
> >
> >## R CMD check
> >   results
> >0 errors | 0 warnings | 1 note
> >
> >=================================================
> >
> >Original content of DESCRIPTION file:
> >
> >Package: fakemake
> >Title: Mock the Unix Make Utility
> >Version: 1.0.0
> >Authors@R: person(given = "Andreas Dominik", family = "Cullmann", email
> >         = "fvafrcu@arcor.de", role = c("aut", "cre"))
> >Description: Use R as a minimal build system. This might come in handy
> >         if you are developing R packages and can not use a proper build
> >         system. Stay away if you can (use a proper build system).
> >Depends: R (>= 3.3.3)
> >License: BSD_2_clause + file LICENSE
> >Encoding: UTF-8
> >LazyData: true
> >Suggests: knitr, rmarkdown, testthat, RUnit, devtools, rprojroot,
> >         roxygen2, hunspell, cleanr, lintr, covr
> >Imports: MakefileR, callr, withr, utils, igraph, graphics
> >VignetteBuilder: knitr
> >RoxygenNote: 6.0.1
> >NeedsCompilation: no
> >Packaged: 2017-11-09 14:00:44 UTC; qwer
> >Author: Andreas Dominik Cullmann [aut, cre]
> >Maintainer: Andreas Dominik Cullmann <fvafrcu@arcor.de>
> >
