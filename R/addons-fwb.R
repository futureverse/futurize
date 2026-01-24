# fwb::fwb(...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   fwb::fwb(..., cl = "future")
# })
#
append_transpilers_for_fwb <- function() {
  package <- "fwb"

  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of '%s' functions requires R (>= 4.4.0)", getRversion(), package))
  }

  template <- quote(
    local({
      oopts <- options(future.ClusterFuture.clusterEvalQ = "error")
      on.exit(options(oopts))
      EXPR
    })
  )

  idx_EXPR <- c(2, 4)

  ## To please 'R CMD check' on R (< 4.4.0), where
  ## future::makeClusterFuture() is not available

  transpiler <- eval(bquote(function(expr, options = NULL) {
    ## Update 'EXPR'
    parts <- c(
      as.list(expr),
      cl = "future"
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
      if ("cl" %in% names(formals(fcn))) {
        transpilers[[name]] <- list(
          label = sprintf("%s::%s() ~> %s::%s(..., cl = \"future\")", package, name, package, name),
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
