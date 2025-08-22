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


append_transpilers_for_pkg <- function(pkg) {
  if (pkg == "foreach") {
    append_transpilers_for_doFuture()
  } else if (pkg == "purrr") {
    append_transpilers_for_furrr()
  } else if (pkg == "crossmap") {
    append_transpilers_for_crossmap()
  } else if (pkg %in% c("base", "stats")) {
    append_transpilers_for_future.apply()
  } else if (pkg == "glmnet") {
    append_transpilers_for_glmnet()
  } else if (pkg == "boot") {
    append_transpilers_for_boot()
  } else if (pkg == "caret") {
    append_transpilers_for_caret()
  } else if (pkg == "lme4") {
    append_transpilers_for_lme4()
  } else if (pkg == "plyr") {
    append_transpilers_for_plyr()
  } else if (pkg == "tm") {
    append_transpilers_for_tm()
  } else if (pkg == "BiocParallel") {
    append_transpilers_for_BiocParallel()
  } else {
    stop("Unsupported package: ", sQuote(pkg))
  }
}
