# Used by transpilers for the future.apply, furrr packages
#'
#' @return
#' A named list of list of transpilers, where the name of the list is the package name.
#' The list of transpilers is also a named list, where each element is a transpiler
#' and the corresponding name is the function transpiled.
#' A transpiler is a named list with elements:
#'
#'  * `label` - a character string describing the transpiler
#'
#'  * `transpiler` - a function that takes an R expression and
#'                   an optional argument `options`
#' 
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
