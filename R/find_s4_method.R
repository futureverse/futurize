#' Finds S4 method package for S4 generic function and object
#'
#' @param fcn,fcn_name An S4 generic function and its name.
#'
#' @param call The S4 function call, which includes the dispatch object.
#'
#' @param envir The environment in which the dispatch object should be
#' resolved.
#'
#' @param debug If TRUE, debug output is given.
#'
#' @return
#' Returns a named list of elements `package` and `name` if found,
#' otherwise NULL.
#'
#' @noRd
find_s4_method <- function(fcn, fcn_name, call, envir, debug = FALSE) {
  if (!methods::isGeneric(fcn_name)) return(NULL)

  ## Get the name of the first argument (dispatch argument)
  fmls <- formals(fcn)
  if (length(fmls) == 0L) return(NULL)

  dispatch_arg_name <- names(fmls)[[1L]]
  if (dispatch_arg_name == "...") return(NULL) ## FIXME: Skip for now

  ## Use match.call() to correctly handle named and reordered arguments
  matched_call <- tryCatch(
    match.call(fcn, call = call),
    error = function(e) NULL
  )
  if (is.null(matched_call)) return(NULL)

  dispatch_expr <- matched_call[[dispatch_arg_name]]
  if (is.null(dispatch_expr)) return(NULL)
  if (!is.symbol(dispatch_expr) && !is.call(dispatch_expr)) return(NULL)

  ## Evaluate the dispatch argument to get its class
  dispatch_obj <- tryCatch(
    eval(dispatch_expr, envir = envir),
    error = function(e) NULL
  )
  if (is.null(dispatch_obj)) return(NULL)

  dispatch_class <- class(dispatch_obj)[[1L]]

  ## Find the S4 method
  method <- tryCatch(
    methods::selectMethod(fcn_name, signature = dispatch_class),
    error = function(e) NULL
  )
  if (is.null(method)) return(NULL)

  ## Determine the package the method is defined in
  method_env <- environment(method)
  if (is.null(method_env)) return(NULL)
  method_pkg <- environmentName(topenv(method_env))

  if (debug) {
    mdebugf("S4 generic %s() dispatches to %s::%s() for class %s",
            fcn_name, method_pkg, fcn_name, sQuote(dispatch_class))
  }

  list(package = method_pkg, name = fcn_name)
} ## find_s4_method()
