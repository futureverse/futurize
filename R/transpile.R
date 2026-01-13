#' Transpile an R expression
#'
#' @param expr An \R expression, typically a function call to transpile.
#' If FALSE, then the transpiler is disabled, and if TRUE, it is re-enabled.
#' If NA, then TRUE is returned if the transpiler is enabled, otherwise FALSE.
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
#' @param type Type of the transpiler to use.
#'
#' @param unwrap (optional) A list of functions that should be considered
#' wrapping function, that the transpiler should unwrap ("enter"). This
#' Allows us to transpile expressions within `{ ... }` and `local( ... )`.
#'
#' @returns
#' Returns the value of the evaluated expression `expr` if `eval = TRUE`,
#' otherwise the transpiled expression.
#' If `expr` is NA, then TRUE is returned if the transpiler is enabled,
#' otherwise FALSE.
#'
#' @keywords internal
transpile <- local({
  .enabled <- list()
  
  function(expr, options = list(...), ..., when = TRUE, eval = TRUE, envir = parent.frame(), type = "built-in", what = "transpile", unwrap = list(base::`{`, base::`(`, base::`!`, base::local, base::I, base::identity, base::invisible, base::suppressMessages, base::suppressWarnings, base::suppressPackageStartupMessages), debug = FALSE) {
    if (debug) {
      mdebug_push("transpile() ...")
      on.exit(mdebug_pop())
    }
  
    stopifnot(
      is.logical(when), length(when) == 1L, !is.na(when)
    )
  
    ## Enable or disable transpiler, or query its state?
    enabled <- .enabled[[type]]
    if (is.null(enabled)) {
      enabled <- TRUE
      .enabled[[type]] <<- enabled
    }
    
    ## e.g. transpile(TRUE), transpile(FALSE), or transpile(NA)?
    if (is.logical(expr) && length(expr) == 1L) {
      if (is.na(expr)) return(enabled)
      old_enabled <- enabled
      .enabled[[type]] <<- expr
      return(invisible(old_enabled))
    }
  
    ## Don't transpile, i.e. evaluate as-is?
    if (!enabled || !when) {
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
      transpiler <- get_transpiler(expr, envir = envir, type = type, what = what, unwrap = unwrap, debug = debug)
    
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
    class(expr_transpiled) <- c("transpiled_call", class(expr_transpiled))
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
})
class(transpile) <- c("transpiler", class(transpile))



#' Get a registered transpiler for an R expression
#' 
#' @inheritParams transpile
#' @inheritParams parse_call
#' 
#' @param expr The R expression, which contains an R symbol or an R call,
#' to be transpiled.
#'
#' @return
#' A transpiler, which is a named list with elements:
#'
#'  * `label` - a character string describing the transpiler
#'
#'  * `transpiler` - a function that takes an R expression and
#'                   an optional argument `options`
#' 
get_transpiler <- function(expr, envir = parent.frame(), unwrap = list(), type, what, debug = FALSE) {
  if (debug) {
    mdebug_push("get_transpiler() ...")
    on.exit(mdebug_pop())
  }
  
  mdebug_push("Finding call to be transpiled ...")
  call_pos <- decend_wrappers(expr, envir = envir, unwrap = unwrap, what = what, debug = debug)

  call <- expr[[call_pos]]
  call_info <- parse_call(call, envir = envir, what = what, debug = debug)
  fcn <- call_info[["fcn"]]
  fcn_name <- call_info[["fcn_name"]]
  ns_name <- call_info[["ns_name"]]

  if (debug) {
    mdebugf("Position of call to be transpiled in expression: c(%s)", comma(call_pos))
    mprint(call)
    mdebug_pop()   
    mdebugf_push("Locating %s transpiler for %s::%s() of class %s ...", sQuote(type), ns_name, fcn_name, sQuote(class(fcn)[1]))
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

  transpiler_sets <- get_transpilers(type)
  transpilers <- transpiler_sets[[ns_name]]
  if (is.null(transpilers)) {
    if (!requireNamespace(ns_name, quietly = TRUE)) {
      info <- if (grepl("^%.*%$", fcn_name)) {
        sprintf("%s::`%s`", ns_name, fcn_name)
      } else {
        sprintf("%s::%s()", ns_name, fcn_name)
      }
      stop(sprintf("Please install %s in order to %s %s",
           sQuote(ns_name), what, info))
    }

    ## Get transpiler package addons
    req_pkgs <- transpilers_for_package(type = type, package = ns_name, action = "make", debug = debug)
    if (debug) {
      mdebugf("Required packages: [n=%d] %s", length(req_pkgs), commaq(req_pkgs))
    }

    okay <- vapply(req_pkgs, FUN.VALUE = NA, FUN = requireNamespace, quietly = TRUE)
    if (!all(okay)) {
      pkgs <- req_pkgs[!okay]
      info <- if (grepl("^%.*%$", fcn_name)) {
        sprintf("%s::`%s`", ns_name, fcn_name)
      } else {
        sprintf("%s::%s()", ns_name, fcn_name)
      }
      stop(sprintf("Please install %s in order to %s %s",
           commaq(pkgs), what, info))
    }
    transpiler_sets <- get_transpilers(type)
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
    stopifnot(is.list(transpiler), "label" %in% names(transpiler), "transpiler" %in% names(transpiler))
    mdebugf("Transpiler description: %s", transpiler[["label"]])
    mdebug("Transpiler function:")
    mprint(transpiler[["transpiler"]])
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

get_transpilers <- function(type) {
  transpiler_db <- .env[["transpiler_db"]]
  transpiler_db[[type]]
}

append_transpilers <- function(type, ...) {
  transpiler_db <- .env[["transpiler_db"]]
  transpilers <- transpiler_db[[type]]
  transpilers <- c(transpilers, ...)
  transpiler_db[[type]] <- transpilers
  .env[["transpiler_db"]] <- transpiler_db
}


list_transpilers <- function(pattern = NULL, class) {
  data <- list()
  transpiler_db <- .env[["transpiler_db"]]
  db <- transpiler_db[[class]]
  if (is.null(db)) db <- list()
  types <- names(db)
  if (!is.null(pattern)) {
    types <- grep(pattern, types, value = TRUE)
  }
  for (type in types) {
    transpilers <- db[[type]]
    fcns <- unique(names(transpilers))
    for (fcn in fcns) {
      idxs <- which(fcn == names(transpilers))
      if (length(idxs) == 1) {
        transpilers_fcn <- transpilers[idxs]
      } else {
        ## length(idxs) > 1 should not happend, but in case ...
        transpilers_fcn <- list()
        for (idx in idxs) {
          transpilers_fcn <- c(transpilers_fcn, transpilers[[idx]])
        }
        drop <- duplicated(names(transpilers_fcn), fromLast = TRUE)
        transpilers_fcn <- transpilers_fcn[!drop]
      }
      transpilers_fcn <- transpilers_fcn[order(names(transpilers_fcn))]
      names <- names(transpilers_fcn)
      labels <- vapply(transpilers_fcn, FUN = function(t) t$label, FUN.VALUE = "")
      dd <- data.frame(type = type, fcn = names, description = labels)
      data <- c(data, list(dd))
    }
  }
  data <- Reduce(rbind, data)
  rownames(data) <- NULL
  data
}


transpilers_for_package <- local({
  .db <- list()
  
  function(type = "default", package, fcn, action = c("add", "make", "get", "list", "reset"), debug = FALSE) {
    stopifnot(is.character(type), length(type) == 1L, !is.na(type))
    action <- match.arg(action, several.ok = FALSE)
    
    if (debug) {
      mdebugf_push("transpilers_for_package(action = %s, type = %s) ...", sQuote(action), sQuote(type))
      on.exit(mdebug_pop())
    }

    db <- .db[[type]]
    if (is.null(db)) db <- list()
    
    if (action == "add") {
      stopifnot(
        is.character(package), length(package) == 1L,
        is.function(fcn)
      )
      if (debug) {
        mdebugf(" - package: %s", sQuote(package))
      }
      fcns <- old_fcns <- db[[package]]
      fcns <- if (length(fcns) == 0) list(fcn) else c(fcns, list(fcn))
      db[[package]] <- fcns
      .db[[type]] <<- db
      invisible(old_fcns)
    } else if (action == "get") {
      if (debug) {
        mdebugf(" - package: %s", sQuote(package))
      }
      stopifnot(
        is.character(package), length(package) == 1L
      )
      if (debug) mdebugf(" - package: %s", sQuote(package))
      db[[package]]
    } else if (action == "make") {
      stopifnot(
        is.character(package), length(package) == 1L
      )
      if (debug) {
        mdebugf(" - package: %s", sQuote(package))
      }
      fcns <- db[[package]]
      if (debug) mprint(list(fcns = fcns))
      if (length(fcns) == 0L) {
        stop(sprintf("There are no factory functions for creating %s transpilers for package %s", sQuote(type), sQuote(package)))
      }
      req_pkgs <- lapply(fcns, FUN = function(fcn) fcn())
      req_pkgs <- unlist(req_pkgs, use.names = FALSE)
      req_pkgs <- sort(unique(req_pkgs))
      req_pkgs
    } else if (action == "list") {
      .db
    } else if (action == "reset") {
      old_db <- db
      db <- list()
      .db[[type]] <<- db
      invisible(old_db)
    }
  }
})


transpiler_packages <- function(classes = NULL) {
  db <- transpilers_for_package(action = "list")
  if (!is.null(classes)) {
    db <- db[names(db) %in% classes]
  }
  transpilers <- data.frame(class = character(0L), package = character(0L))
  for (class in names(db)) {
    set <- db[[class]]
    pkgs <- names(set)
    transpilers <- rbind(transpilers, data.frame(class = class, package = pkgs))
  }
  transpilers
}
