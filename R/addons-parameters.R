# parameters::bootstrap_model(...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   parameters::bootstrap_model(..., parallel = "snow", ncpus = 2L, cluster = cl)
# })
#
# parameters::bootstrap_parameters(...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   parameters::bootstrap_parameters(..., parallel = "snow", ncpus = 2L, cluster = cl)
# })
#
append_transpilers_for_parameters <- function() {
  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'parameters' functions requires R (>= 4.4.0)", getRversion()))
  }

  template_ignore_clusterEvalQ <- bquote_compile(
    local({
      cl <- do.call(.(CALL), args = .(OPTS))
      oopts <- options(future.ClusterFuture.clusterEvalQ = "ignore")
      on.exit(options(oopts))
      .(EXPR)
    })
  )

  transpilers <- make_package_transpilers("parameters", FUN = function(fcn, name) {
    if (name %in% c("bootstrap_model", "bootstrap_parameters")) {
      transpiler <- make_futurize_for_makeClusterFuture(
        template = template_ignore_clusterEvalQ,
        args = list(
          parallel = "snow",
          n_cpus = 2L,   ## only used for test ncpus > 1
          cluster = quote(cl)
        ), defaults = list(
          label = sprintf("fz:parameters::%s", name),
          seed = TRUE
        )
      )

      list(
        label = sprintf("parameters::%s() ~> parameters::%s(..., parallel = 'snow', cluster = cl)",  name, name),
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("parameters", "future")
}
