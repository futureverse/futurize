# Rsolnp::gosolnp(...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   Rsolnp::gosolnp(..., cluster = cl)
# })
#
append_transpilers_for_Rsolnp <- function() {
  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'Rsolnp' functions requires R (>= 4.4.0)", getRversion()))
  }

  ## Rsolnp::gosolnp() and startpars() internally call
  ## clusterEvalQ(cluster, require(Rsolnp)), which is not
  ## supported by FutureCluster clusters. We silence this,
  ## because the future framework handles package loading.
  template <- bquote_compile(
    local({
      cl <- do.call(.(CALL), args = .(OPTS))
      oopts <- options(future.ClusterFuture.clusterEvalQ = "ignore")
      on.exit(options(oopts))
      .(EXPR)
    })
  )

  transpiler <- make_futurize_for_makeClusterFuture(args = list(
    cluster = quote(cl)
  ), template = template)

  transpilers <- make_package_transpilers("Rsolnp", FUN = function(fcn, name) {
    if ("cluster" %in% names(formals(fcn))) {
      list(
        label = sprintf("Rsolnp::%s() ~> Rsolnp::%s(..., cluster = cl)", name, name),
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("Rsolnp", "future")
}
