## YEAH! This is the first of two steps for a futurize() function
## This solves the second part of that challenge. It works!
## It took 2.5 hours to get to a first working prototype /HB 2025-03-17

#' Run a map-reduce call in parallel
#'
#' @inheritParams future::future
#'
#' @param options Named options controlling how futures are resolved.
#' 
#' @param \ldots Names options passed to [future_options()].
#'
#' @param flavor Flavor of futurize transpiler to use.
#' If `"addon"`, then registered transpilers for packages such as
#' \pkg{future.apply} and \pkg{furrr} are used.
#' If `"builtin"`, then built-in transpilers are used.
#'
#' @returns
#' Returns the value of `call`.
#'
#' @example incl/futurize.R
#'
#' @importFrom future future value
#' @export
futurize <- function(expr, substitute = TRUE, options = futurize_options(...), ..., flavor = c("addon", "built-in"), envir = parent.frame()) {
  if (substitute) expr <- substitute(expr)
  debug <- isTRUE(getOption("futurize.debug"))
  if (debug) {
    mdebug_push("futurize() ...")
    on.exit(mdebug_pop())
  }
  
  stopifnot(
    is.language(expr),
    is.call(expr)
  )

  flavor <- match.arg(flavor, several.ok = FALSE)
  transpiler_sets <- transpiler_db[[flavor]]
  stopifnot(length(transpiler_sets) > 0L)
  
  ## Identify (namespace, function)
  call <- expr[[1]]
  if (is.symbol(call)) {
    ## Examples: lapply(...), map(...)
    namespace <- NULL
    fcn <- call
  } else if (is.call(call)) {
    stopifnot(length(call) == 3L)
    ## Examples: base::lapply(...), purrr::map(...)
    ## Not supported: base:::lapply(), baseenv()$lapply(...), ...
    op <- call[[1]]
    if (is.symbol(op)) {
      op_name <- as.character(op)
      if (op_name == "::") {
      } else if (op_name == ":::") {
        stop(sprintf("Do not know how to futurize a private function: %s()", deparse(call)))
      } else {
        stop(sprintf("Do not know how to futurize function: %s()", deparse(call)))
      }
      namespace <- call[[2]]
      fcn <- call[[3]]
    } else {
      stop(sprintf("Do not know how to futurize object of type %s: %s()", sQuote(typeof(op)), deparse(call)))
    }
  } else {
    stop(sprintf("Do not know how to futurize function: %s()", as.character(call)))
  }

  ns_name <- as.character(namespace)
  fcn_name <- as.character(fcn)
  if (debug) {
    if (length(ns_name) == 1L) {
      msg <- sprintf("Function: %s::%s(...)", ns_name, fcn_name)
    } else {
      msg <- sprintf("Function: %s(...)", fcn_name)
    }
    mdebug(msg)
  }

  ## Does the function exist?
  if (is.null(namespace)) {
    if (debug) mdebug_push("Locate function ...")
    if (!exists(fcn_name, mode = "function", envir = envir, inherits = TRUE)) {
      stop(sprintf("No such function: %s()", deparse(call)))
    }
    fcn <- get(fcn_name, mode = "function", envir = envir, inherits = TRUE)
    ns_name <- environmentName(environment(fcn))
    if (debug) {
      mdebugf("Function located in: %s", sQuote(ns_name))
      mdebug_pop()
    }
  } else {
    ns <- getNamespace(ns_name)
    if (!exists(fcn_name, mode = "function", envir = ns, inherits = TRUE)) {
      stop(sprintf("No such function in %s: %s()", sQuote(ns_name), deparse(call)))
    }
  }

  if (debug) mdebugf_push("Locating %s transpiler for %s::%s() ...", sQuote(flavor), ns_name, fcn_name)
  ## Is there a registered transpiler for the function?
  transpilers <- transpiler_sets[[ns_name]]
  if (! fcn_name %in% names(transpilers)) {
    stop(sprintf("Do not know how to futurize function: %s()", deparse(call)))
  }
  transpiler <- transpilers[[fcn_name]]
  if (debug) {
    mdebugf("Transpiler: %s", transpiler[["label"]])
  }
  if (debug) mdebugf_pop()

  if (debug) mdebug("Transpile call expression")
  expr_futurized <- transpiler[["transpiler"]](expr, options = options)
  if (debug) mprint(expr_futurized)

  if (debug) mdebug("Evaluate transpiled call expression")
  eval(expr_futurized, envir = envir)
} ## futurize()
