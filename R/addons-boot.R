# boot::boot(...) =>
#
# local({
#   cl <- future.ideas::makeClusterFuture(OPTS)
#   boot::boot(..., parallel = "snow", ncpus = 2L, cl = cl)
# })
#
append_transpilers_for_boot <- function() {
  template <- quote(
    local({
      cl <- do.call(future.ideas::makeClusterFuture, args = OPTS)
      EXPR
    })
  )
  idx_OPTS <- c(2, 2, 3, 3)
  idx_EXPR <- c(2, 3)

  make_options <- function(options) {
    options
  }

  transpiler <- eval(bquote(function(expr, options = NULL) {
    
    ## Update 'OPTS'
    template[[idx_OPTS]] <- make_options(options)
    
    ## Update 'EXPR'
    parts <- c(
      as.list(expr),
      parallel = "snow",
      ncpus = 2L,
      cl = quote(cl)
    )
    template[[idx_EXPR]] <- as.call(parts)
    
    template
  }))
  body(transpiler) <- body(transpiler)

  transpilers <- list()

  ns <- getNamespace("boot")
  exports <- names(ns[[".__NAMESPACE__."]][["exports"]])
  names <- exports
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = FALSE)) {
      fcn <- get(name, mode = "function", envir = ns, inherits = FALSE)
      if ("parallel" %in% names(formals(fcn))) {
        transpilers[[name]] <- list(
          label = sprintf("boot::%s() ~> boot::%s(..., parallel = TRUE)", name, name),
          transpiler = transpiler
        )
      }
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- "boot"

  append_transpilers("add-on", transpilers)

  ## Return required packages
  c("boot", "doFuture")
}
