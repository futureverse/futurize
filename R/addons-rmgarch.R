# rmgarch::dccfit(spec, data, ...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   rmgarch::dccfit(spec, data, ..., cluster = cl)
# })
#
append_transpilers_for_rmgarch <- function() {
  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'rmgarch' functions requires R (>= 4.4.0)", getRversion()))
  }

  ## rmgarch functions internally call
  ## clusterEvalQ(cluster, require(rmgarch)) and
  ## clusterEvalQ(cluster, loadNamespace('rugarch')), which
  ## is not supported by FutureCluster clusters. We silence
  ## this, because the future framework handles package
  ## loading.
  template <- bquote_compile(
    local({
      cl <- do.call(.(CALL), args = .(OPTS))
      oopts <- options(future.ClusterFuture.clusterEvalQ = "ignore")
      on.exit(options(oopts))
      .(EXPR)
    })
  )

  transpiler <- make_futurize_for_makeClusterFuture(
    defaults = list(packages = "rmgarch"),
    args = list(
      cluster = quote(cl)
    ), template = template)

  transpilers <- make_package_transpilers("rmgarch", FUN = function(fcn, name) {
    if ("cluster" %in% names(formals(fcn))) {
      list(
        label = sprintf("rmgarch::%s() ~> rmgarch::%s(..., cluster = cl)", name, name),
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("rmgarch", "future")
}
