# boot::boot(...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   boot::boot(..., parallel = "snow", ncpus = 2L, cl = cl)
# })
#
append_transpilers_for_boot <- function() {
  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'boot' functions requires R (>= 4.4.0)", getRversion()))
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

  transpilers <- make_package_transpilers("boot", FUN = function(fcn, name) {
    if ("parallel" %in% names(formals(fcn))) {
      list(
        label = sprintf("boot::%s() ~> boot::%s(..., parallel = TRUE)",  name, name),
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("boot", "future")
}
