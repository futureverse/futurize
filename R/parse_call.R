#' Parse an R call to be transpiled
#'
#' @param call An R symbol or an R call.
#'
#' @param envir The environment from which to search for the function that
#' is called in the `call`.
#'
#' @param what A character string used in error messages describing what
#' type of transpiler is used.
#'
#' @param debug If TRUE, output debug information.
#'
#' @return
#' A names list with elements:
#'
#'  * `fcn`: the function called in the `call`
#'
#'  * `fcn_name`: the name of the function
#'
#'  * `ns_name`: the name of the namespace where the function lives
#'
#' @keywords internal
parse_call <- function(call, envir = parent.frame(), what = "transpiler", debug = FALSE) {
  if (debug) {
    mdebug_push("parse_call() ...")
    on.exit(mdebug_pop())
  }
  
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
        stop(sprintf("Do not know how to %s a private function: %s()", what, deparse(call)))
      } else {
        stop(sprintf("Do not know how to %s function %s()", what, deparse(call)))
      }
      namespace <- call[[2]]
      fcn <- call[[3]]
    } else {
      stop(sprintf("Do not know how to %s object of type %s: %s()", what, sQuote(typeof(op)), deparse(call)))
    }
  } else {
    stop(sprintf("Do not know how to %s expression: %s", what, as.character(call)))
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
      name <- deparse(call)
      if (grepl("^%.*%$", name)) {
        stop(sprintf("Unknown infix operator: %s", name))
      } else {
        stop(sprintf("Unknown function: %s()", name))
      }
    }
    fcn <- get(fcn_name, mode = "function", envir = envir, inherits = TRUE)
    env <- environment(fcn)

    if (is.null(env) && is.primitive(fcn)) {
      env <- baseenv()
    } else if (inherits(fcn, "standardGeneric")) {
      env <- parent.env(env)
    }
    tenv <- env
    repeat {
      ns_name <- environmentName(tenv)
      if (nzchar(ns_name)) break
      tenv <- parent.env(tenv)
    }
    
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
    fcn <- get(fcn_name, mode = "function", envir = ns, inherits = TRUE)
  }

  list(fcn = fcn, ns_name = ns_name, fcn_name = fcn_name)
} ## parse_call()
