# lme4::allFit(...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   lme4::allFit(..., parallel = "snow", ncpus = 2L, cl = cl)
# })
#
append_transpilers_for_lme4 <- function() {
  package <- "lme4"

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

  make_transpiler <- function(name) {
    defaults <- list()
    if (name == "allFit") {
      defaults <- list(packages = "lme4")
    }
    
    transpiler <- function(expr, options = NULL) {
      expr <- append_call_arguments(expr,
        parallel = "snow",
        ncpus = 2L,   ## only used for test ncpus > 1
        cl = quote(cl)
      )

      opts <- make_options_for_doFuture(options, defaults = defaults, wrap = FALSE)
      
      bquote_apply(template,
        CALL = call, 
        OPTS = opts,
        EXPR = expr
      )
    }
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

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c(package, "future")
}
