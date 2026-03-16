## This function registered functions that adds transpilers for specific
## packages, without loading those packages.
register_all_transpilers <- function() {
  ## Map-reduce packages (base-R)
  transpilers_for_package("futurize::add-on", package = "base",         append_transpilers_for_future.apply)
  transpilers_for_package("futurize::add-on", package = "stats",        append_transpilers_for_future.apply)

  ## Map-reduce packages (pbapply)
  transpilers_for_package("futurize::add-on", package = "pbapply",      append_transpilers_for_pbapply)

  ## Map-reduce packages (Tidyverse)
  transpilers_for_package("futurize::add-on", package = "purrr",        append_transpilers_for_furrr)
  transpilers_for_package("futurize::add-on", package = "crossmap",     append_transpilers_for_crossmap)

  ## Map-reduce packages (foreach)
  transpilers_for_package("futurize::add-on", package = "foreach",      append_transpilers_for_doFuture)
  transpilers_for_package("futurize::add-on", package = "plyr",         append_transpilers_for_plyr)
  transpilers_for_package("futurize::add-on", package = "BiocParallel", append_transpilers_for_BiocParallel)

  ## Domain-specific "recommended" packages
  transpilers_for_package("futurize::add-on", package = "boot",         append_transpilers_for_boot)
  transpilers_for_package("futurize::add-on", package = "mgcv",         append_transpilers_for_mgcv)

  ## Bioconductor packages
  transpilers_for_package("futurize::add-on", package = "DESeq2",              append_transpilers_for_DESeq2)
  transpilers_for_package("futurize::add-on", package = "fgsea",               append_transpilers_for_fgsea)
  transpilers_for_package("futurize::add-on", package = "GenomicAlignments",   append_transpilers_for_GenomicAlignments)
  transpilers_for_package("futurize::add-on", package = "Rsamtools",           append_transpilers_for_Rsamtools)
  transpilers_for_package("futurize::add-on", package = "GSVA",                append_transpilers_for_GSVA)
  transpilers_for_package("futurize::add-on", package = "scater",              append_transpilers_for_scater)
  transpilers_for_package("futurize::add-on", package = "scuttle",             append_transpilers_for_scuttle)
  transpilers_for_package("futurize::add-on", package = "SingleCellExperiment", append_transpilers_for_SingleCellExperiment)
  transpilers_for_package("futurize::add-on", package = "sva",                  append_transpilers_for_sva)

  ## Domain-specific packages
  transpilers_for_package("futurize::add-on", package = "caret",        append_transpilers_for_caret)
  transpilers_for_package("futurize::add-on", package = "fwb",          append_transpilers_for_fwb)
  transpilers_for_package("futurize::add-on", package = "glmnet",       append_transpilers_for_glmnet)
  transpilers_for_package("futurize::add-on", package = "glmmTMB",      append_transpilers_for_glmmTMB)
  transpilers_for_package("futurize::add-on", package = "lme4",         append_transpilers_for_lme4)
  transpilers_for_package("futurize::add-on", package = "partykit",     append_transpilers_for_partykit)
  transpilers_for_package("futurize::add-on", package = "seriation",    append_transpilers_for_seriation)
  transpilers_for_package("futurize::add-on", package = "shapr",        append_transpilers_for_shapr)
  transpilers_for_package("futurize::add-on", package = "strucchange",  append_transpilers_for_strucchange)
  transpilers_for_package("futurize::add-on", package = "tm",           append_transpilers_for_tm)
  transpilers_for_package("futurize::add-on", package = "TSP",          append_transpilers_for_TSP)
  transpilers_for_package("futurize::add-on", package = "vegan",        append_transpilers_for_vegan)
} ## register_all_transpilers()
