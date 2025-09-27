#' Evaluate common R functions in parallel
#'
#' \if{html}{\figure{futurize-magic-touch-parallelization-120x138.png}{options: style='float: right;' alt='logo' width='120'}}
#'
#' @inheritParams future::future
#'
#' @param expr An \R expression, typically a function call to futurize.
#' If FALSE, then futurization is disabled, and if TRUE, it is
#' re-enabled.
#'
#' @param options,\ldots Named options, passed to [futurize_options()],
#' controlling how futures are resolved.
#' 
#' @param when If TRUE (default), the expression is futurized, otherwise not.
#'
#' @param eval If TRUE (default), the futurized expression is evaluated,
#' other it is returned.
#'
#' @param flavor Flavor of futurize transpiler to use.
#' If `"add-on"`, then registered transpilers for packages such as
#' \pkg{future.apply} and \pkg{furrr} are used.
#' If `"built-in"`, then built-in transpilers are used.
#'
#' @returns
#' Returns the value of the evaluated expression `expr`.
#'
#' If `expr` is a TRUE or FALSE, then a logical is returned indicating 
#' whether futurization was previously enabled or disabled.
#'
#'
#' @section Conditionally futurization:
#' It is possible to control whether futurization should take place at
#' run-time. For example,
#'
#' ```r
#' y <- lapply(xs, fun) |> futurize(when = { length(xs) >= 10 })
#' ```
#'
#' will be futurized, unless `length(xs)` less than ten, in case it is
#' evaluated as:
#'
#' ```r
#' y <- lapply(xs, fun)
#' ```
#'
#' 
#' @section Disable and re-enable all futurization:
#' It is possible to globally disable the effect of all `futurize()` calls
#' by calling `futurize(FALSE)`. The effect is as if `futurize()` was never
#' applied. For example,
#'
#' ```r
#' futurize(FALSE)
#' y <- lapply(xs, fun) |> futurize()
#' ```
#'
#' is evaluates as:
#'
#' ```r
#' y <- lapply(xs, fun)
#' ```
#'
#' To re-enable futurization, call `futurize(TRUE)`.
#' Please note that it is only the end-user that may control whether
#' futurization should be disabled and enabled. A package must _never_
#' disable or enable futurization.
#'
#'
#' @example incl/futurize.R
#'
#' @aliases parallelize
#' @importFrom future future value
#' @export
futurize <- function(expr, substitute = TRUE, options = futurize_options(...), ..., when = TRUE, eval = TRUE, flavor = c("add-on", "built-in"), envir = parent.frame()) {
  if (substitute) expr <- substitute(expr)
  debug <- isTRUE(getOption("futurize.debug"))
  if (debug) {
    mdebug_push("futurize() ...")
    on.exit(mdebug_pop())
  }

  ## futurize(TRUE), futurize(FALSE), or futurize(NA)?
  .futurize <- .package[[".futurize"]]
  if (is.logical(expr) && length(expr) == 1L) {
    if (is.na(expr)) return(.futurize)
    .package[[".futurize"]] <- expr
    return(invisible(.futurize))
  }

  stopifnot(
    is.logical(when), length(when) == 1L, !is.na(when)
  )

  ## Don't futurize, i.e. evaluate as-is?
  if (!when || !.futurize) {
    if (eval) {
      if (debug) mdebug("Evaluate call expression")
      return(eval(expr, envir = envir))
    } else {
      if (debug) mdebug("Return call expression")
      return(expr)
    }
  }
  

  flavor <- match.arg(flavor, several.ok = FALSE)

  ## -------------------------------------------------------
  ## 1. Identify (namespace, function)
  ## -------------------------------------------------------
  call <- expr[[1]]
  call_info <- parse_call(call, envir = envir, what = "futurize", debug = debug)
  ns_name <- call_info[["ns_name"]]
  fcn_name <- call_info[["fcn_name"]]
  

  ## -------------------------------------------------------
  ## 2. Locate matching transpiler
  ## -------------------------------------------------------
  if (debug) {
    mdebugf_push("Locating %s transpiler for %s::%s() ...", sQuote(flavor), ns_name, fcn_name)
  }

  transpiler_sets <- get_transpilers(flavor)
  transpilers <- transpiler_sets[[ns_name]]
  if (is.null(transpilers)) {
    if (!requireNamespace(ns_name)) {
      stop(sprintf("Please install %s in order to futurize %s::%s()",
           sQuote(ns_name), ns_name, fcn_name))
    }
    req_pkgs <- append_transpilers_for_pkg(ns_name)
    okay <- vapply(req_pkgs, FUN.VALUE = NA, FUN = requireNamespace, quietly = FALSE)
    if (!all(okay)) {
      pkgs <- req_pkgs[!okay]
      stop(sprintf("Please install %s in order to futurize %s::%s()",
           commaq(pkgs), ns_name, fcn_name))
    }
    transpiler_sets <- get_transpilers(flavor)
    transpilers <- transpiler_sets[[ns_name]]
  }

  if (debug) {
    mdebugf("Namespaces registered with futurize(): %s", commaq(names(transpiler_sets)))
  }
  
  ## Is there a registered transpiler for the function?
  if (is.null(transpilers)) {
    stop(sprintf("Function %s::%s() is not in one of the registered futurize namespaces: %s", ns_name, fcn_name, commaq(names(transpiler_sets))))
  }

  if (! fcn_name %in% names(transpilers)) {
    stop(sprintf("Do not know how to futurize function: %s()", deparse(call)))
  }
  transpiler <- transpilers[[fcn_name]]
  if (debug) {
    mdebugf("Transpiler: %s", transpiler[["label"]])
  }
  if (debug) mdebugf_pop()


  ## -------------------------------------------------------
  ## 3. Transpile
  ## -------------------------------------------------------
  if (debug) mdebug("Transpile call expression")
  expr_futurized <- transpiler[["transpiler"]](expr, options = options)
  if (debug) mprint(expr_futurized)


  ## -------------------------------------------------------
  ## 4. Evaluate or return transpiled expression?
  ## -------------------------------------------------------
  if (eval) {
    if (debug) mdebug("Evaluate transpiled call expression")
    eval(expr_futurized, envir = envir)
  } else {
    if (debug) mdebug("Return transpiled call expression")
    expr_futurized
  }
} ## futurize()


#' @export
parallelize <- futurize
