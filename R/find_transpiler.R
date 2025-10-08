find_transpiler <- function(expr, envir = parent.frame(), flavor, what, debug = FALSE) {
  if (debug) {
    mdebug_push("find_transpiler() ...")
    on.exit(mdebug_pop())
  }

  
  mdebug_push("Finding call to be futurized ...")
  call_pos <- c(1L)
  ready <- FALSE
  while (!ready) {
    if (debug) {
      mdebugf("Call position in expression: c(%s)", comma(call_pos))
    }
    call <- expr[[call_pos]]
    if (debug) {
      mdebug("Call:")
      mprint(call)
    }
    call_info <- parse_call(call, envir = envir, what = what, debug = debug)
    fcn <- call_info[["fcn"]]
    fcn_name <- call_info[["fcn_name"]]
    ns_name <- call_info[["ns_name"]]

    ## Special cases: {...}, (...), local(...), I(...), identity(...)
    if (identical(fcn, `{`) ||
        identical(fcn, `(`) ||
        identical(fcn, base::local) ||
        identical(fcn, base::I) ||
        identical(fcn, base::identity)
       ) {
      if (debug) {
        info <- switch(fcn_name,
          "{" = "{ ... }",
          "(" = "( ... )",
          "I" = "I( ... )",
          "identity" = "identity( ... )",
          "local" = "local( ... )"
        )
        mdebugf("Futurizing an expression wrapped in %s", info)
      }
      call_pos <- c(2L, call_pos)
    } else {
      ready <- TRUE
    }
  }
  mdebugf("Call position in expression: c(%s)", comma(call_pos))
  mdebug_pop()

  if (debug) {
    mdebugf_push("Locating %s transpiler for %s::%s() of class %s ...", sQuote(flavor), ns_name, fcn_name, sQuote(class(fcn)[1]))
  }

  ## Special case: A nested transpiler function?
  if (inherits(fcn, "transpiler")) {
    if (debug) {
      mdebugf("Detected a nested transpiler function: %s::%s()", ns_name, fcn_name)
    }
    transpiler <- list(
      label      = fcn_name,
      transpiler = fcn
    )

    stopifnot(call_pos == 1L)
    return(transpiler)
  }

  transpiler_sets <- get_transpilers(flavor)
  transpilers <- transpiler_sets[[ns_name]]
  if (is.null(transpilers)) {
    if (!requireNamespace(ns_name)) {
      stop(sprintf("Please install %s in order to %s %s::%s()",
           sQuote(ns_name), what, ns_name, fcn_name))
    }
    req_pkgs <- append_transpilers_for_pkg(ns_name)
    okay <- vapply(req_pkgs, FUN.VALUE = NA, FUN = requireNamespace, quietly = FALSE)
    if (!all(okay)) {
      pkgs <- req_pkgs[!okay]
      stop(sprintf("Please install %s in order to %s %s::%s()",
           commaq(pkgs), what, ns_name, fcn_name))
    }
    transpiler_sets <- get_transpilers(flavor)
    transpilers <- transpiler_sets[[ns_name]]
  }

  if (debug) {
    mdebugf("Namespaces registered with %s(): %s", what, commaq(names(transpiler_sets)))
  }
  
  ## Is there a registered transpiler for the function?
  if (is.null(transpilers)) {
    stop(sprintf("Function %s::%s() is not in one of the registered %s namespaces: %s", ns_name, fcn_name, what, commaq(names(transpiler_sets))))
  }

  if (! fcn_name %in% names(transpilers)) {
    stop(sprintf("Do not know how to %s function: %s()", what, deparse(call)))
  }
  transpiler <- transpilers[[fcn_name]]
  if (debug) {
    mdebugf("Transpiler: %s", transpiler[["label"]])
  }

  if (length(call_pos) > 1L) {
    if (debug) {
      mdebug_push("Creating wrapper transpiler ...")
    }
    transpiler_inner <- transpiler[["transpiler"]]
    transpiler <- list(
      label      = sprintf("Apply transpiler to inner expression at c(%s)", comma(call_pos)),
      transpiler = function(expr, ...) {
        inner_pos <- call_pos[-length(call_pos)]         
        expr_inner <- expr[[inner_pos]]
        expr_inner <- transpiler_inner(expr_inner, ...)
        expr[[inner_pos]] <- expr_inner
        expr
      }
    )
    if (debug) {
      mprint(transpiler)
      mdebug_pop()
    }
  }

  if (debug) mdebugf_pop()

  transpiler
} ## find_transpiler()
