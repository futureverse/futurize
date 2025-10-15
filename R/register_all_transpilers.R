## This function registered functions that adds transpilers for specific
## packages, without loading those packages.
register_all_transpilers <- function() {
  ## Built-in
  transpilers_for_package("futurize::built-in", package = "base",       append_builtin_transpilers_for_base)
  
  ## Add-ons
  transpilers_for_package("futurize::add-on", package = "base",         append_transpilers_for_future.apply)
  transpilers_for_package("futurize::add-on", package = "stats",        append_transpilers_for_future.apply)
  transpilers_for_package("futurize::add-on", package = "purrr",        append_transpilers_for_furrr)
  transpilers_for_package("futurize::add-on", package = "crossmap",     append_transpilers_for_crossmap)
  transpilers_for_package("futurize::add-on", package = "foreach",      append_transpilers_for_doFuture)
  transpilers_for_package("futurize::add-on", package = "BiocParallel", append_transpilers_for_BiocParallel)
  transpilers_for_package("futurize::add-on", package = "glmnet",       append_transpilers_for_glmnet)
  transpilers_for_package("futurize::add-on", package = "boot",         append_transpilers_for_boot)
  transpilers_for_package("futurize::add-on", package = "caret",        append_transpilers_for_caret)
  transpilers_for_package("futurize::add-on", package = "lme4",         append_transpilers_for_lme4)
  transpilers_for_package("futurize::add-on", package = "plyr",         append_transpilers_for_plyr)
  transpilers_for_package("futurize::add-on", package = "tm",           append_transpilers_for_tm)
} ## register_all_transpilers()
