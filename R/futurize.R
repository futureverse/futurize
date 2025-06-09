#' Evaluate common R functions in parallel
#'
#' \if{html}{\figure{futurize-magic-touch-parallelization-120x138.png}{options: style='float: right;' alt='logo' width='120'}}
#'
#' @inheritParams future::future
#'
#' @param options,\ldots Named options, passed to [futurize_options()],
#' controlling how futures are resolved.
#' 
#' @param flavor Flavor of futurize transpiler to use.
#' If `"add-on"`, then registered transpilers for packages such as
#' \pkg{future.apply} and \pkg{furrr} are used.
#' If `"built-in"`, then built-in transpilers are used.
#'
#' @returns
#' Returns the value of the evaluated expression `expr`.
#'
#' @example incl/futurize.R
#'
#' @aliases parallelize
#' @importFrom future future value
#' @export
futurize <- function(expr, substitute = TRUE, options = futurize_options(...), ..., flavor = c("add-on", "built-in"), envir = parent.frame()) {
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
    env <- environment(fcn)
    if (inherits(fcn, "standardGeneric")) {
      env <- parent.env(env)
    }
    ns_name <- environmentName(env)
    stopifnot(nzchar(ns_name))
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

  if (debug) mdebug("Transpile call expression")
  expr_futurized <- transpiler[["transpiler"]](expr, options = options)
  if (debug) mprint(expr_futurized)

  if (debug) mdebug("Evaluate transpiled call expression")
  eval(expr_futurized, envir = envir)
} ## futurize()


#' @export
parallelize <- futurize
