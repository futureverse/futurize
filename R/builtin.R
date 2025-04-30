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

