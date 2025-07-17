# lme4::allFit(...) =>
#
# local({
#   cl <- future::makeClusterFuture(OPTS)
#   lme4::allFit(..., parallel = "snow", ncpus = 2L, cl = cl)
# })
#
append_transpilers_for_lme4 <- function() {
  package <- "lme4"
  
  template <- quote(
    local({
      cl <- do.call(makeClusterFuture, args = OPTS)
      EXPR
    })
  )
  idx_OPTS <- c(2, 2, 3, 3)
  idx_EXPR <- c(2, 3)

  ## To please 'R CMD check' until makeClusterFuture() is
  ## in a publicly available package
  call <- as.call(lapply(c("::", "future", "makeClusterFuture"), as.name))
  template[[c(2,2,3,2)]] <- call


  make_options <- function(options, defaults = NULL) {
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
    options
  }
  
  make_transpiler <- function(name) {
    defaults <- list()
    if (name == "allFit") {
      defaults <- list(packages = "lme4")
    }
    

    transpiler <- eval(bquote(function(expr, options = NULL) {
      ## Update 'OPTS'
      template[[idx_OPTS]] <- make_options(options, defaults = .(defaults))
  
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
    
    transpiler
  }

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
          transpiler = make_transpiler(name)
        )
      }
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- package

  append_transpilers("add-on", transpilers)

  ## Return required packages
  c(package, "future")
}
