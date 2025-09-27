find_transpiler <- function(expr, envir = parent.frame(), flavor, what, debug = FALSE) {
  if (debug) {
    mdebug_push("find_transpiler() ...")
    on.exit(mdebug_pop())
  }

  call <- expr[[1]]
  
  call_info <- parse_call(call, envir = envir, what = what, debug = debug)
  fcn <- call_info[["fcn"]]
  fcn_name <- call_info[["fcn_name"]]
  ns_name <- call_info[["ns_name"]]

  if (debug) {
    mdebugf_push("Locating %s transpiler for %s::%s() of class %s ...", sQuote(flavor), ns_name, fcn_name, sQuote(class(fcn)[1]))
  }

  if (inherits(fcn, "transpiler")) {
    stop(sprintf("Do not how to transpiler a transpiler function: %s::%s()", ns_name, fcn_name))
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
  
  transpiler
} ## find_transpiler()
