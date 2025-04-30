# Build transpilers for the future.apply and furrr APIs
#
#   make_addon_transpilers("base", "future.apply")
#   make_addon_transpilers("purrr", "furrr")
#
make_addon_transpilers <- function(from_package, to_package) {
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

    transpiler <- eval(bquote(function(expr) {
      expr[[1]] <- make_call(.(name))
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
