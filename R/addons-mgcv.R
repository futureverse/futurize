# mgcv::bam(...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   mgcv::bam(..., cluster = cl)
# })
#
append_transpilers_for_mgcv <- function() {
  package <- "mgcv"

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
      cluster = quote(cl)
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
    if ("cluster" %in% names(formals(fcn))) {
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
