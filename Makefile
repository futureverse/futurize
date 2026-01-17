SHELL=bash

spelling:
	Rscript -e "spelling::spell_check_package()"
	Rscript -e "spelling::spell_check_files(dir('vignettes', pattern='[.]md$$', full.names=TRUE), ignore=readLines('inst/WORDLIST', warn=FALSE))"
