## Package-specific hooks called by the transpiler code shared with the
## 'progressify' package. Each package using the shared transpiler code
## must define these functions.

#' Creates a call that transpiles an expression at run time
#'
#' This is used when the transpiler cannot be identified until run time,
#' e.g. when the S3 or S4 method of a generic function depends on an
#' argument that should only be evaluated once.
#'
#' @param expr The call expression to be transpiled at run time.
#'
#' @param options (optional) Named list of transpiler options.
#'
#' @return
#' A call expression.
#'
#' @noRd
make_runtime_transpile_call <- function(expr, options = NULL) {
  if (is.null(options)) options <- futurize_options()
  bquote(futurize::futurize(.(expr), options = .(options)))
}


#' Gets a hint on what to do instead of specifying a controlled argument
#'
#' @return
#' A character string, or NULL.
#'
#' @noRd
controlled_argument_hint <- function() {
  "pass any future options to futurize() instead, e.g. futurize(seed = TRUE)"
}
