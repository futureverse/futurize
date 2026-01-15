# boot::boot(...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   boot::boot(..., parallel = "snow", ncpus = 2L, cl = cl)
# })
#
append_transpilers_for_boot <- function() {
  package <- "boot"

  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of '%s' functions requires R (>= 4.4.0)", getRversion(), package))
  }

  template <- quote(
    local({
      cl <- do.call(makeClusterFuture, args = OPTS)
      oopts <- options(future.ClusterFuture.clusterEvalQ = "error")
      on.exit(options(oopts))
      EXPR
    })
  )
  idx_OPTS <- c(2, 2, 3, 3)
  idx_EXPR <- c(2, 5)

  ## To please 'R CMD check' on R (< 4.4.0), where
  ## future::makeClusterFuture() is not available
  call <- as.call(lapply(c("::", "future", "makeClusterFuture"), as.name))
  template[[c(2,2,3,2)]] <- call


  transpiler <- eval(bquote(function(expr, options = NULL) {
    
    ## Update 'OPTS'
    template[[idx_OPTS]] <- make_options_for_makeClusterFuture(options)

    ## Update 'EXPR'
    parts <- c(
      as.list(expr),
      parallel = "snow",
      ncpus = 2L,   ## only used for test ncpus > 1
      cl = quote(cl)
    )
    template[[idx_EXPR]] <- as.call(parts)
    
    template
  }))
  body(transpiler) <- body(transpiler)

  transpilers <- list()

  ns <- getNamespace(package)
  exports <- names(ns[[".__NAMESPACE__."]][["exports"]])
  names <- exports
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = FALSE)) {
      fcn <- get(name, mode = "function", envir = ns, inherits = FALSE)
      if ("parallel" %in% names(formals(fcn))) {
        transpilers[[name]] <- list(
          label = sprintf("%s::%s() ~> %s::%s(..., parallel = TRUE)", package, name, package, name),
          transpiler = transpiler
        )
      }
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- package

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c(package, "future")
}


make_options_for_makeClusterFuture <- local({
  get_defaults <- function(fcn) {
    defaults <- names(formals(fcn))
    excl <- c("expr", "substitute", "envir", "earlySignal", "gc", "...")
    setdiff(defaults, excl)
  }
  
  defaults_base <- NULL

  function(options, defaults = NULL) {
    ## Nothing to do?
    if (length(options) == 0L && length(defaults) == 0L) return(options)

    if (is.null(defaults_base)) {
      defaults_base <<- get_defaults(future::future)
    }

    if (length(defaults) > 0) {
      names <- setdiff(names(defaults), attr(options, "specified"))
      for (name in names) {
        if (name == "packages") {
          options[[name]] <- c(options[[name]], defaults[[name]])
        } else {
          options[[name]] <- defaults[[name]]
        }
      }
    }

    options <- options[names(options) %in% defaults_base]

    options
  }
})

