#! /usr/bin/env bash

## Missing or outdated LaTeX packages
false && R --quiet --no-save <<EOF
    tinytex::install_tinytex(force = TRUE)
    message("TeX root: ", tinytex::tinytex_root())
    tinytex::tlmgr_update()

    # Other R packages
    tinytex::tlmgr_install(c(
    ))
EOF

## Non-default system dependencies
if command -v module &> /dev/null; then
    module load CBI
fi


## ---------------------------------------------------------------------
## Phase 1
## ---------------------------------------------------------------------

## Add packages to check
revdep/run.R --add-children

## Drop packages failing on CRAN (2026-10-05)
revdep/run.R --rm rtemis

## Drop packages failing on Bioconductor (2026-10-05)
# revdep/run.R --rm ...

## Drop packages no longer on CRAN (2026-07-19)
#revdep/run.R --rm ...

## Drop packages no longer on Bioconductor (2026-10-05)
#revdep/run.R --rm ...

## Packages failing on Rocky 8 (2026-10-05)
#revdep/run.R --rm marcxmlr

## Requires sequential processing due to clashes, e.g. port and cache 
pkgs_seq=()
#revdep/run.R --rm "${pkgs_seq[@]}"

## Too many threads
pkgs_threads=()
#revdep/run.R --rm "${pkgs_threads[@]}"

# Too many cores
pkgs_cores=()
#revdep/run.R --rm "${pkgs_cores[@]}"

## Too many cores due to detectCores
pkgs_detectCores=()
#revdep/run.R --rm "${pkgs_detectCores[@]}"

## Run revdep check
revdep/run.R


## ---------------------------------------------------------------------
## Phase 2
## ---------------------------------------------------------------------
## Set: Too many threads
#revdep/run.R --add "${pkgs_threads[@]}"
#OMP_NUM_THREADS=4 revdep/run.R

## Set: Too many cores
#revdep/run.R --add "${pkgs_cores[@]}"
#OMP_NUM_THREADS=4 NSLOTS=4 revdep/run.R

## Sequential
#revdep/run.R --add "${pkgs_seq[@]}"
#NSLOTS=1 revdep/run.R
