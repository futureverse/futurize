#' Transpile an R expression
#'
#' @param expr An \R expression, typically a function call to transpile.
#'
#' @param options (optional) Named options for the transpilation.
#' 
#' @param when If TRUE (default), the expression is transpiled, otherwise not.
#'
#' @param eval If TRUE (default), the transpiled expression is evaluated,
#' other it is returned.
#'
#' @param envir The environment where the expression should be evaluated.
#'
#' @param flavor Flavor of the transpiler to use.
#'
#' @param unwrap (optional) A list of functions that should be considered
#' wrapping function, that the transpiler should unwrap ("enter"). This
#' Allows us to transpile expressions within `{ ... }` and `local( ... )`.
#'
#' @returns
#' Returns the value of the evaluated expression `expr` if `eval = TRUE`,
#' otherwise the transpiled expression.
#'
#' @keywords internal
transpile <- function(expr, options = list(...), ..., when = TRUE, eval = TRUE, envir = parent.frame(), flavor = "built-in", what = "transpile", unwrap = list(base::`{`, base::`(`, base::local, base::I, base::identity), debug = FALSE) {
  if (debug) {
    mdebug_push("transpile() ...")
    on.exit(mdebug_pop())
  }

  stopifnot(
    is.logical(when), length(when) == 1L, !is.na(when)
  )

  ## Don't transpile, i.e. evaluate as-is?
  if (!when) {
    if (eval) {
      if (debug) mdebug("Evaluate call expression")
      return(eval(expr, envir = envir))
    } else {
      if (debug) mdebug("Return call expression")
      return(expr)
    }
  }
  
  repeat {
    ## 1a. Get a matching transpiler
    transpiler <- get_transpiler(expr, envir = envir, flavor = flavor, what = what, unwrap = unwrap, debug = debug)
  
    transpile <- transpiler[["transpiler"]]

    ## 1b. If not a nested transpiler function, we're done here
    if (!inherits(transpile, "transpiler")) break

    ## 1c. Generate transpiled expression of nested transpiler
    expr <- local({
      if (debug) mdebug_push("Apply nested transpiler ...")
      on.exit(mdebug_pop())
      if (debug) mprint(expr)
      parts <- as.list(expr)
      parts$eval <- FALSE
      expr2 <- as.call(parts)
      expr <- eval(expr2, envir = envir)
      if (debug) mprint(expr)
      expr
    })
  }


  ## 2. Transpile
  if (debug) {
    mdebug_push("Transpile call expression ...")
  }

  expr_transpiled <- transpile(expr, options = options)
  if (debug) {
    mprint(expr_transpiled)
    mdebug_pop()
  }


  ## 3. Evaluate or return transpiled expression?
  if (eval) {
    if (debug) mdebug("Evaluate transpiled call expression")
    eval(expr_transpiled, envir = envir)
  } else {
    if (debug) mdebug("Return transpiled call expression")
    expr_transpiled
  }
} ## transpile()
class(transpile) <- c("transpiler", class(transpile))


get_transpiler <- function(expr, envir = parent.frame(), unwrap = list(), flavor, what, debug = FALSE) {
  if (debug) {
    mdebug_push("get_transpiler() ...")
    on.exit(mdebug_pop())
  }
  
  mdebug_push("Finding call to be transpiled ...")
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

    ready <- TRUE

    ## Unwrap, e.g. {...}, (...), local(...)?
    if (length(unwrap) > 0) {
      for (wrapper in unwrap) {
        if (identical(fcn, wrapper)) {
          if (debug) {
            info <- switch(fcn_name,
              "{" = "{ ... }",
              "(" = "( ... )",
              sprintf("%s( ... )", fcn_name)
            )
            mdebugf("Transpiling an expression wrapped in %s", info)
          }
          call_pos <- c(2L, call_pos)
          ready <- FALSE
        }
      }
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
} ## get_transpiler()


.env <- new.env()
.env[["transpiler_db"]] <- list()

get_transpilers <- function(flavor) {
  .env[["transpiler_db"]][[flavor]]
}

append_transpilers <- function(flavor, ...) {
  transpiler_db <- .env[["transpiler_db"]]
  transpilers <- transpiler_db[[flavor]]
  transpilers <- c(transpilers, ...)
  transpiler_db[[flavor]] <- transpilers
  .env[["transpiler_db"]] <- transpiler_db
}


list_transpilers <- function() {
  data <- list()
  db <- .env[["transpiler_db"]]
  flavors <- names(db)
  for (flavor in flavors) {
    transpilers <- db[[flavor]]
    pkgs <- unique(names(transpilers))
    for (pkg in pkgs) {
      idxs <- which(pkg == names(transpilers))
      if (length(idxs) == 1) {
        transpilers_pkg <- transpilers[[idxs]]
      } else {
        ## length(idxs) > 1 should not happend, but in case ...
        transpilers_pkg <- list()
        for (idx in idxs) {
          transpilers_pkg <- c(transpilers_pkg, transpilers[[idx]])
        }
        drop <- duplicated(names(transpilers_pkg), fromLast = TRUE)
        transpilers_pkg <- transpilers_pkg[!drop]
      }
      transpilers_pkg <- transpilers_pkg[order(names(transpilers_pkg))]
      names <- names(transpilers_pkg)
      labels <- vapply(transpilers_pkg, FUN = function(t) t$label, FUN.VALUE = "")
      dd <- data.frame(flavor = flavor, package = pkg, fcn = names, description = labels)
      data <- c(data, list(dd))
    }
  }
  data <- Reduce(rbind, data)
  rownames(data) <- NULL
  data
}
