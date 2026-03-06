#' Finds registered S3 method for S3 generic function and object
#'
#' @param fcn,fcn_name An S3 generic function and its name.
#'
#' @param call The S3 function call, which includes the dispatch object.
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
#' @importFrom utils getS3method
find_s3_method <- function(fcn, fcn_name, call, envir, debug = FALSE) {
  ## Get the name of the first argument, which is the S3 dispatch argument
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
  if (is.null(dispatch_expr) || !is.symbol(dispatch_expr)) return(NULL)

  ## Evaluate the dispatch argument to get its class
  dispatch_obj <- tryCatch(
    eval(dispatch_expr, envir = envir),
    error = function(e) NULL
  )
  if (is.null(dispatch_obj)) return(NULL)

  ## Use .class2() to get the full S3 dispatch chain, which includes inherited
  ## classes from S4/R5 hierarchies not visible in class() alone.
  ## Example: class(lmerMod_obj) = "lmerMod", but .class2() = c("lmerMod", "merMod")
  dispatch_classes <- .class2(dispatch_obj)

  ## Walk the class hierarchy to find a dispatched S3 method
  method <- NULL
  dispatch_class <- NULL
  for (cls in dispatch_classes) {
    m <- getS3method(fcn_name, cls, optional = TRUE)
    if (!is.null(m)) {
      method <- m
      dispatch_class <- cls
      break
    }
  }
  if (is.null(method)) return(NULL)

  ## Determine the package the method lives in
  method_env <- environment(method)
  if (is.null(method_env)) return(NULL)
  method_pkg <- environmentName(topenv(method_env))

  method_name <- paste0(fcn_name, ".", dispatch_class)

  if (debug) {
    mdebugf("S3 generic %s() dispatches to %s::%s() for class %s",
            fcn_name, method_pkg, method_name, sQuote(dispatch_class))
  }

  list(package = method_pkg, name = method_name)
} ## find_s3_method()


