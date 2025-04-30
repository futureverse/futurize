## YEAH! This is the first of two steps for a futurize() function
## This solves the second part of that challenge. It works!
## It took 2.5 hours to get to a first working prototype /HB 2025-03-17

#' Run a map-reduce call in parallel
#'
#' @inheritParams future::future
#'
#' @param \ldots Currently not used.
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
futurize <- function(expr, substitute = TRUE, ..., stdout = TRUE, conditions = "condition", flavor = c("addon", "built-in"), envir = parent.frame()) {
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
      stop(sprintf("No such  function in %s: %s()", sQuote(ns_name), deparse(call)))
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

  if (debug) mprint("Transpile call expression")
  expr_futurized <- transpiler[["transpiler"]](expr)
  if (debug) mprint(expr_futurized)

  if (debug) mprint("Evaluate transpiled call expression")
  eval(expr_futurized, envir = envir)
} ## futurize()



if (FALSE) {
  f_expr <- config[["f_expr"]]
  reducer <- config[["reducer"]]
  
  fs <- eval(f_expr, envir = envir)
  fs_chunks <- partition(fs)
  vs_chunks <- value(fs_chunks)
  vs_chunks <- do.call(c, args = vs_chunks)
  vs <- do.call(reducer, args = vs_chunks)
  vs
} ## futurize()




make_addon_transpilers <- function(from_package, to_package) {
  call_template <- as.call(list(as.symbol("::"), as.symbol(to_package), as.symbol("<place-holder>")))
  make_call <- function(name) {
    call <- call_template
    call[[3]] <- as.symbol(name)
    call
  }
  
  transpilers <- list()
  
  ns <- getNamespace(to_package)
  exports <- names(ns[[".__NAMESPACE__."]][["exports"]])
  names <- grep("^future_", exports, value = TRUE)
  for (name in names) {
    basename <- sub("^future_", "", name)

    transpiler <- eval(bquote(function(expr) {
      expr[[1]] <- make_call(.(name))
      expr
    }))
    body(transpiler) <- body(transpiler)

    transpilers[[basename]] <- list(
      label = sprintf("%s::%s() -> %s::%s()", from_package, basename, to_package, name),
      transpiler = transpiler
    )
  }

  transpilers <- list(transpilers)
  names(transpilers) <- from_package
  transpilers
} ## make_addon_transpilers()


transpiler_db <- list(
  builtin = list(),
  addon = list()
)

transpiler_db[["addon"]] <- c(
  transpiler_db[["addon"]],
  make_addon_transpilers("base", "future.apply"),
  make_addon_transpilers("purrr", "furrr")
)




known_fcns <- list()
known_fcns[["base"]] <- list(
  apply = c,
  by = c,
  eapply = c,              ## done
  lapply = c,              ## done
  .mapply = c,
  mapply = c,
  Map = c,
  replicate = c,
  sapply = c,              ## done
  tapply = c,
  vapply = c              ## done
)

registry <- list()
registry[["built-in"]] <- known_fcns


futurize_base <- function(expr, fcn_name, fcn, ..., stdout = TRUE, conditions = "condition", envir = parent.frame()) {
  defaults <- formals(fcn)

  fcns <- known_fcns[["base"]]

  names <- names(expr)
  if (fcn_name %in% c("eapply")) {
    idx_env <- which(names == "env")
    stopifnot(length(idx_env) == 1L)
    idx_FUN <- which(names == "FUN")
    stopifnot(length(idx_FUN) == 1L)
    FUN <- expr[[idx_FUN]]

    ## Reduce by calling the same function again with the same arguments,
    ## except that 'env' is the collected future values, and 'FUN = identity'
    expr_reduce <- expr
    expr_reduce[[idx_env]] <- quote(as.environment(env))
    expr_reduce[[idx_FUN]] <- quote(identity)
    expr_reducer <- bquote(function(...) {
      env <- list(...)
      .(expr_reduce)
    })
    reducer <- eval(expr_reducer, envir = parent.frame())
    expr[[1]] <- quote(lapply)
    names(expr)[idx_env] <- "X"

    idx_all.names <- which(names == "all.names")
    if (length(idx_all.names) == 1L) {
      all.names <- eval(expr[[idx_all.names]], envir = envir)
    } else {
      all.names <- FALSE
    }
    ## NOTE: We need to use ls(..., sorted = FALSE) here, in order to emulate
    ## "that the order of the components is arbitrary for hashed environments"
    ## Source: help("eapply", package = "base")
    expr_env <- bquote(
      mget(base::ls(envir = .(expr[[idx_env]]), all.names = .(all.names), sorted = FALSE), envir = .(expr[[idx_env]]), inherits = FALSE)
    )
    expr[[idx_env]] <- expr_env

    ## Drop unused arguments
    for (name in c("all.names", "USE.NAMES")) {
      idx <- which(names == name)
      if (length(idx) == 1L) {
        expr[[idx]] <- NULL
        names <- names(expr)
        idx_FUN <- which(names == "FUN")
      }
    }
  } else if (fcn_name %in% c("lapply", "sapply", "vapply")) {
    idx_X <- which(names == "X")
    stopifnot(length(idx_X) == 1L)
    idx_FUN <- which(names == "FUN")
    stopifnot(length(idx_FUN) == 1L)
    FUN <- expr[[idx_FUN]]
  
    ## Reduce by calling the same function again with the same arguments,
    ## except that 'X' is the collected future values, and 'FUN = identity'
    expr_reduce <- expr
    expr_reduce[[idx_X]] <- quote(x)
    expr_reduce[[idx_FUN]] <- quote(identity)
    expr_reducer <- bquote(function(...) {
      x <- list(...)
      .(expr_reduce)
    })
    reducer <- eval(expr_reducer, envir = parent.frame())
    
    if (fcn_name %in% c("vapply")) {
      expr[[1]] <- quote(lapply)
      ## Drop unused arguments
      for (name in c("FUN.VALUE", "USE.NAMES")) {
        idx <- which(names == name)
        if (length(idx) == 1L) {
          expr[[idx]] <- NULL
          names <- names(expr)
          idx_FUN <- which(names == "FUN")
        }
      }
    }
  } else if (fcn_name %in% c("replicate")) {
    stop("Not implemented")
  } else {
    idx_FUN <- which(names == "FUN")
    stopifnot(length(idx_FUN) == 1L)
    FUN <- expr[[idx_FUN]]
    reducer <- fcns[[fcn_name]]
  }

  f_FUN <- bquote(function(...) future::future(
    expr = .(FUN)(...),
    substitute = TRUE,
    globals = TRUE,
    stdout = .(stdout),
    conditions = .(conditions),
    lazy = TRUE
  ))

  f_expr <- expr
  f_expr[[idx_FUN]] <- f_FUN

  list(f_expr = f_expr, reducer = reducer)
} ## futurize_base()

