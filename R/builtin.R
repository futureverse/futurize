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

#' @inheritParams futurize
#'
#' @param fcn_name The name of the 'base' package function to futurize.
#'
#' @param fcn The 'base' package function to futurize.
#'
futurize_base <- function(expr, fcn_name, fcn, options, envir = parent.frame()) {
  defaults <- formals(fcn)

  fcns <- known_fcns[["base"]]

  names <- names(expr)
  if (is.null(names)) names <- rep("", length.out = length(expr))
  names <- names[-1]
  target_names <- names(formals(fcn))[seq_along(names)]
  unnamed <- setdiff(target_names, names)
  names[names == ""] <- unnamed
  names <- c("", names)

  f_expr_comment <- "## Generate futures"
  reducer_comment <- "## Reduce values"

  if (fcn_name %in% c("eapply")) {
    ## ARGUMENTS
    ## Locate and get eapply() arguments
    idx_env <- which(names == "env")
    stopifnot(length(idx_env) == 1L)
    idx_FUN <- which(names == "FUN")
    stopifnot(length(idx_FUN) == 1L)
    FUN <- expr[[idx_FUN]]
    idx_all.names <- which(names == "all.names")
    if (length(idx_all.names) == 1L) {
      all.names <- eval(expr[[idx_all.names]], envir = envir)
    } else {
      all.names <- FALSE
    }

    ## REDUCE FUNCTION
    ## Generate reduce function by calling the same function again with the
    ## same arguments, except that 'env' is the collected future values,
    ## and 'FUN = identity'
    reducer_comment <- sprintf("## Reduce values using %s()", fcn_name)
    expr_reduce <- expr
    expr_reduce[[idx_env]] <- quote(as.environment(env))
    expr_reduce[[idx_FUN]] <- quote(identity)
    expr_reducer <- bquote(function(...) {
      env <- list(...)
      .(expr_reduce)
    })
    reducer <- eval(expr_reducer, envir = parent.frame())

    ## MAP FUNCTION
    ## Generate lapply()-based map function
    f_expr_comment <- "## Generate futures using lapply()-based map function"
    expr[[1]] <- quote(lapply)
    names(expr)[idx_env] <- "X"

    ## NOTE: We need to use ls(..., sorted = FALSE) here, in order to emulate
    ## "that the order of the components is arbitrary for hashed environments"
    ## Source: help("eapply", package = "base")
    expr_env <- bquote(
      mget(base::ls(envir = .(expr[[idx_env]]), all.names = .(all.names), sorted = FALSE), envir = .(expr[[idx_env]]), inherits = FALSE)
    )
    expr[[idx_env]] <- expr_env

    ## Drop unused arguments, if existing
    for (name in c("all.names", "USE.NAMES")) {
      idx <- which(names == name)
      if (length(idx) == 1L) {
        expr[[idx]] <- NULL
        names <- names(expr)
        idx_FUN <- which(names == "FUN")
      }
    }
  } else if (fcn_name %in% c("lapply", "sapply", "vapply")) {
    ## ARGUMENTS
    ## Locate lapply(), sapply(), and vapply() arguments
    idx_X <- which(names == "X")
    stopifnot(length(idx_X) == 1L)
    idx_FUN <- which(names == "FUN")
    stopifnot(length(idx_FUN) == 1L)
    FUN <- expr[[idx_FUN]]
  
    ## REDUCE FUNCTION
    ## Reduce by calling the same function again with the same arguments,
    ## except that 'X' is the collected future values, and 'FUN = identity'
    reducer_comment <- sprintf("## Reduce values using %s()", fcn_name)
    expr_reduce <- expr
    expr_reduce[[idx_X]] <- quote(x)
    expr_reduce[[idx_FUN]] <- quote(identity)
    expr_reducer <- bquote(function(...) {
      x <- list(...)
      .(expr_reduce)
    })
    reducer <- eval(expr_reducer, envir = parent.frame())
    
    ## MAP FUNCTION
    if (fcn_name %in% c("vapply")) {
      f_expr_comment <- "## Generate futures using lapply()-based map function"
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
    } else {
      f_expr_comment <- sprintf("## Generate futures using %s()-based map function", fcn_name)
    }
  } else if (fcn_name %in% c("replicate")) {
    ## ARGUMENTS
    ## Locate replicate() arguments
    idx_n <- which(names == "n")
    stopifnot(length(idx_n) == 1L)
    idx_expr <- which(names == "expr")
    stopifnot(length(idx_expr) == 1L)
    idx_simplify <- which(names == "simplify")
    if (length(idx_simplify) == 1L) {
      simplify <- eval(expr[[idx_simplify]], envir = envir)
    } else {
      simplify <- "array"
    }
    
    ## MAP FUNCTION
    f_expr_comment <- "## Reduce values using lapply()"
    expr[[1]] <- quote(lapply)
    n <- expr[[idx_n]]
    expr[[idx_n]] <- bquote(integer(.(n)))
    FUN <- expr[[idx_expr]]
    FUN <- bquote(function(...) .(FUN))
    expr[[idx_expr]] <- FUN
    names(expr) <- c("", "X", "FUN")
    idx_FUN <- idx_expr
    ## Drop unused arguments, if existing
    for (name in c("simplify")) {
      idx <- which(names == name)
      if (length(idx) == 1L) {
        expr[[idx]] <- NULL
        names <- names(expr)
      }
    }
    
    ## REDUCE FUNCTION
    reducer_comment <- "## Reduce values using sapply()"
    expr_reducer <- bquote(function(...) {
      x <- list(...)
      sapply(x, identity, simplify = .(simplify))
    })
    reducer <- eval(expr_reducer, envir = parent.frame())
  } else {
    ## In all other cases, assume there is a 'FUN' arguments
    idx_FUN <- which(names == "FUN")
    stopifnot(length(idx_FUN) == 1L)
    FUN <- expr[[idx_FUN]]
    
    reducer <- fcns[[fcn_name]]
  }

  f_FUN <- bquote(function(...) future::future(
    expr = .(FUN)(...),
    substitute = TRUE,
    globals = .(options[["globals"]]),
    packages = .(options[["packages"]]),
    stdout = .(options[["stdout"]]),
    conditions = .(options[["conditions"]]),
    seed = .(options[["seed"]]),
    label = .(options[["label"]]),
    lazy = TRUE
  ))

  f_expr <- expr
  f_expr[[idx_FUN]] <- f_FUN

  list(
    f_expr = f_expr,
    f_expr_comment = f_expr_comment,
    reducer = reducer,
    reducer_comment = reducer_comment
  )
} ## futurize_base()

futurize_base_expr <- function(expr, fcn_name, fcn, options, envir = parent.frame()) {
  config <- futurize_base(expr, fcn_name = fcn_name, fcn = fcn, options = options, envir = parent.frame())
  f_expr <- config[["f_expr"]]
  f_expr_comment <- config[["f_expr_comment"]]
  reducer <- config[["reducer"]]
  reducer_comment <- config[["reducer_comment"]]
  
  bquote({
    .(f_expr_comment)
    fs <- .(f_expr)

    '## Partition futures'
    fs_chunks <- futurize::partition(fs)

    '## Collect partioned values from partitioned futures'
    vs_chunks <- future::value(fs_chunks)

    '## Combine partioned values into flat list of values'
    vs_chunks <- do.call(c, args = vs_chunks)
    
    .(reducer_comment)
    do.call(.(reducer), args = vs_chunks)
  })
}

append_builtin_transpilers_for_base <- function() {
  ## base::apply(), ...
  transpilers <- list()

  ## Create all transpilers
  fcns <- known_fcns[["base"]]
  for (fcn_name in names(fcns)) {
    reducer <- fcns[[fcn_name]]
    label <- sprintf("base::%s() transpiler", fcn_name)
    make_transpiler_expr <- bquote(function(expr, options) {
      fcn_name <- .(fcn_name)
      fcn <- get(fcn_name, mode = "function", envir = baseenv())
      futurize_base_expr(expr, fcn_name = fcn_name, fcn = fcn, options = options, envir = parent.frame())
    })
    transpiler <- eval(make_transpiler_expr)
    transpilers[[fcn_name]] <- list(
      label = label,
      transpiler = transpiler
    )
  } ## for (fcn_name ...)
  
  append_transpilers("futurize::built-in", list(base = transpilers))
  
  ## Return required packages
  character(0L)
}
