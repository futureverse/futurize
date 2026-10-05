#' Finds registered S3 method for S3 generic function and object
#'
#' @param fcn,fcn_name An S3 generic function and its name.
#'
#' @param call The S3 function call, which includes the dispatch object.
#'
#' @param envir The environment in which the dispatch object should be
#' resolved.
#'
#' @param what A character string used in error messages describing what
#' type of transpiler is used.
#'
#' @param debug If TRUE, debug output is given.
#'
#' @return
#' Returns a named list of elements `package` and `name` if found,
#' otherwise NULL.
#'
#' @noRd
#' @importFrom utils getS3method
find_s3_method <- function(fcn, fcn_name, call, envir, what = "transpile", debug = FALSE) {
  ## Get the name of the first argument, which is the S3 dispatch argument
  fmls <- formals(fcn)
  if (length(fmls) == 0L) return(NULL)

  ## FIXME: Here we assume we're dispatching on the first argument
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

  ## The dispatch argument must be evaluated to identify the method.
  ## To avoid evaluating it twice, it must be a variable, or a formula,
  ## which is safe to evaluate, e.g. breakpoints(y ~ 1)
  if (is.call(dispatch_expr) && !identical(dispatch_expr[[1]], as.symbol("~"))) {
    stop_dispatch_argument_not_variable(call, dispatch_expr = dispatch_expr, fcn_name = fcn_name, type = "S3", what = what)
  }

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




#' Signals an error that the dispatch argument is not a variable
#'
#' @param call The S3 or S4 generic function call.
#'
#' @param dispatch_expr The dispatch argument expression in the call.
#'
#' @param fcn_name The name of the generic function.
#'
#' @param type The type of generic function, i.e. `"S3"` or `"S4"`.
#'
#' @param what A character string describing what type of transpiler
#' is used.
#'
#' @return
#' Nothing; produces an error.
#'
#' @noRd
stop_dispatch_argument_not_variable <- function(call, dispatch_expr, fcn_name, type, what) {
  ## Abbreviate long expressions, e.g. lmer(<long formula>, data) -> lmer(...)
  abbreviate <- function(expr) {
    code <- paste(deparse(expr), collapse = " ")
    if (nchar(code) <= 30L) return(code)
    sprintf("%s(...)", paste(deparse(expr[[1]]), collapse = " "))
  }
  dispatch_code <- abbreviate(dispatch_expr)
  msg <- sprintf("Cannot %s %s(%s), because its first argument is not a variable. To identify the %s method to be called, %s() would have to evaluate it, which would evaluate it twice. Instead, assign the first argument to a variable first, e.g. 'obj <- %s' and '%s(obj, ...) |> %s()'", what, fcn_name, dispatch_code, type, what, dispatch_code, fcn_name, what)
  stop_with_version(msg, call. = FALSE)
} ## stop_dispatch_argument_not_variable()
