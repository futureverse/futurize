parse_call <- function(call, envir = parent.frame(), what, debug = FALSE) {
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
        stop(sprintf("Do not know how to %s function: %s()", what, deparse(call)))
      }
      namespace <- call[[2]]
      fcn <- call[[3]]
    } else {
      stop(sprintf("Do not know how to %s object of type %s: %s()", what, sQuote(typeof(op)), deparse(call)))
    }
  } else {
    stop(sprintf("Do not know how to %s function: %s", what, as.character(call)))
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

  list(ns = ns_name, fcn = fcn_name)
} ## parse_call()
