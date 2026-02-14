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

  template <- bquote_compile(
    local({
      cl <- do.call(.(CALL), args = .(OPTS))
      oopts <- options(future.ClusterFuture.clusterEvalQ = "error")
      on.exit(options(oopts))
      .(EXPR)
    })
  )


  ## To please 'R CMD check' on R (< 4.4.0), where
  ## future::makeClusterFuture() is not available
  
  call <- as.call(lapply(c("::", "future", "makeClusterFuture"), as.name))

  transpiler <- function(expr, options = NULL) {
    expr <- append_call_arguments(expr,
      parallel = "snow",
      ncpus = 2L,   ## only used for test ncpus > 1
      cl = quote(cl)
    )

    opts <- make_options_for_makeClusterFuture(options)

    bquote_apply(template,
      CALL = call,
      OPTS = opts,
      EXPR = expr
    )
  }
  body(transpiler) <- body(transpiler)

  transpilers <- make_package_transpilers(package, FUN = function(fcn, package, name) {
    if ("parallel" %in% names(formals(fcn))) {
      list(
        label = sprintf("%s::%s() ~> %s::%s(..., parallel = TRUE)", package, name, package, name),
        transpiler = transpiler
      )
    }
  })

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

