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
  ## To avoid evaluating it twice, it must be safe to evaluate. If not
  ## safe, the transpiler will defer identification of the method until
  ## run time, when the dispatch argument is evaluated once and
  ## assigned to a variable
  if (!is_safe_dispatch_expr(dispatch_expr, envir = envir)) {
    index <- dispatch_arg_index(fcn, call = call, dispatch_arg_name = dispatch_arg_name)
    if (!is.null(index)) return(list(deferred = TRUE, index = index))
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

  list(package = method_pkg, name = method_name, class = dispatch_class)
} ## find_s3_method()




#' Checks whether a dispatch argument is safe to evaluate
#'
#' An expression is safe to evaluate, if evaluating it more than once
#' has no side effects and is cheap. This is the case for:
#'
#'  * variables and literals, e.g. `fit` and `42`
#'
#'  * formulas, e.g. `y ~ 1`
#'
#'  * calls to `base::list()` and `base::c()`, where all elements are
#'    variables or literals, e.g. `list(CSC = fit)`
#'
#' @param expr An \R expression.
#'
#' @param envir The environment in which `list()` and `c()` are resolved.
#'
#' @return
#' TRUE if `expr` is safe to evaluate, otherwise FALSE.
#'
#' @noRd
is_safe_dispatch_expr <- function(expr, envir) {
  if (!is.call(expr)) return(TRUE)

  head <- expr[[1]]
  if (!is.symbol(head)) return(FALSE)
  name <- as.character(head)

  ## Formula?
  if (name == "~") return(TRUE)

  ## list(...) or c(...) of variables and literals?
  if (name %in% c("list", "c")) {
    fcn <- get0(name, envir = envir, mode = "function", inherits = TRUE)
    if (!identical(fcn, get(name, envir = baseenv(), mode = "function"))) {
      return(FALSE)
    }
    args <- as.list(expr)[-1]
    for (arg in args) {
      if (is.call(arg)) return(FALSE)
    }
    return(TRUE)
  }

  FALSE
} ## is_safe_dispatch_expr()


#' Gets the position of the dispatch argument in a call
#'
#' @param fcn The generic function.
#'
#' @param call The generic function call.
#'
#' @param dispatch_arg_name The name of the dispatch argument.
#'
#' @return
#' The index of the dispatch argument in `call`, such that
#' `call[[index]]` is the dispatch argument expression, or NULL if
#' it could not be identified.
#'
#' @noRd
dispatch_arg_index <- function(fcn, call, dispatch_arg_name) {
  ## Replace each argument by its index, and let match.call() tell which
  ## one is the dispatch argument
  call_idxs <- call
  for (kk in seq_along(call)[-1]) {
    call_idxs[[kk]] <- kk
  }
  matched_call <- tryCatch({
    match.call(fcn, call = call_idxs)
  }, error = function(e) NULL)

  if (is.null(matched_call)) return(NULL)
  
  index <- matched_call[[dispatch_arg_name]]
  if (!is.numeric(index) || length(index) != 1L) return(NULL)
  
  as.integer(index)
} ## dispatch_arg_index()


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
