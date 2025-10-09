# Used by transpilers for the future.apply, furrr packages
make_addon_transpilers <- function(from_package, to_package, make_options) {
  call_template <- as.call(list(as.symbol("::"), as.symbol(to_package), as.symbol("<place-holder>")))
  make_call <- function(name) {
    call <- call_template
    call[[3]] <- as.symbol(name)
    call
  }

  transpilers <- list()
  
  ns <- getNamespace(to_package)
  exports <- names(ns[[".__NAMESPACE__."]][["exports"]])
  names <- grep("^future_", exports, value = TRUE)
  for (name in names) {
    basename <- sub("^future_", "", name)

    transpiler <- eval(bquote(function(expr, options = NULL) {
      call <- make_call(.(name))
      fcn <- eval(call)
      expr[[1]] <- call
      parts <- c(as.list(expr), .(make_options)(options, fcn))
      expr <- as.call(parts)
      expr
    }))
    body(transpiler) <- body(transpiler)

    transpilers[[basename]] <- list(
      label = sprintf("%s::%s() -> %s::%s()", from_package, basename, to_package, name),
      transpiler = transpiler
    )
  }

  transpilers <- list(transpilers)
  names(transpilers) <- from_package
  transpilers
} ## make_addon_transpilers()



## This function registered functions that adds transpilers for specific
## package, without loading those package.
register_all_transpilers <- function() {
  add_transpilers_for_package("futurize", package = "base",         append_transpilers_for_future.apply)
  add_transpilers_for_package("futurize", package = "stats",        append_transpilers_for_future.apply)
  add_transpilers_for_package("futurize", package = "purrr",        append_transpilers_for_furrr)
  add_transpilers_for_package("futurize", package = "crossmap",     append_transpilers_for_crossmap)
  add_transpilers_for_package("futurize", package = "foreach",      append_transpilers_for_doFuture)
  add_transpilers_for_package("futurize", package = "BiocParallel", append_transpilers_for_BiocParallel)
  add_transpilers_for_package("futurize", package = "glmnet",       append_transpilers_for_glmnet)
  add_transpilers_for_package("futurize", package = "boot",         append_transpilers_for_boot)
  add_transpilers_for_package("futurize", package = "caret",        append_transpilers_for_caret)
  add_transpilers_for_package("futurize", package = "lme4",         append_transpilers_for_lme4)
  add_transpilers_for_package("futurize", package = "plyr",         append_transpilers_for_plyr)
  add_transpilers_for_package("futurize", package = "tm",           append_transpilers_for_tm)
} ## register_all_transpilers()
