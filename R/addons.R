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
  register_transpilers("base",         append_transpilers_for_future.apply)
  register_transpilers("stats",        append_transpilers_for_future.apply)
  register_transpilers("purrr",        append_transpilers_for_furrr)
  register_transpilers("crossmap",     append_transpilers_for_crossmap)
  register_transpilers("foreach",      append_transpilers_for_doFuture)
  register_transpilers("BiocParallel", append_transpilers_for_BiocParallel)
  
  register_transpilers("glmnet",       append_transpilers_for_glmnet)
  register_transpilers("boot",         append_transpilers_for_boot)
  register_transpilers("caret",        append_transpilers_for_caret)
  register_transpilers("lme4",         append_transpilers_for_lme4)
  register_transpilers("plyr",         append_transpilers_for_plyr)
  register_transpilers("tm",           append_transpilers_for_tm)
} ## register_all_transpilers()
