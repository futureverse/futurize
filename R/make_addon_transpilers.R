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
#' @keywords internals
#' @noRd
make_addon_transpilers <- function(from_package, to_package, make_options) {
  call_template <- as.call(list(as.symbol("::"), as.symbol(to_package), as.symbol("<place-holder>")))
  make_call <- function(name) {
    call <- call_template
    call[[3]] <- as.symbol(name)
    call
  }

  transpilers <- list()
  
  exports <- names(getNamespaceInfo(to_package, "exports"))
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
