# Sim.DiffProc::MCM.sde(...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   options(future.ClusterFuture.clusterEvalQ = "ignore")
#   on.exit(options(oopts))
#   Sim.DiffProc::MCM.sde(..., parallel = "snow", ncpus = 2L, cl = cl)
# })
#
append_transpilers_for_Sim.DiffProc <- function() {
  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'Sim.DiffProc' functions requires R (>= 4.4.0)", getRversion()))
  }

  template_ignore_clusterEvalQ <- bquote_compile(
    local({
      cl <- do.call(.(CALL), args = .(OPTS))
      oopts <- options(future.ClusterFuture.clusterEvalQ = "ignore")
      on.exit(options(oopts))
      .(EXPR)
    })
  )

  transpilers <- make_package_transpilers("Sim.DiffProc", FUN = function(fcn, name) {
    if ("cl" %in% names(formals(fcn))) {
      transpiler <- make_futurize_for_makeClusterFuture(
        template = template_ignore_clusterEvalQ,
        args = list(
          parallel = "snow",
          ncpus = 2L,   ## only used for test ncpus > 1
          cl = quote(cl)
        ), defaults = list(
          packages = "Sim.DiffProc",
          seed = TRUE,
          label = sprintf("fz:Sim.DiffProc::%s", name)
        )
      )

      list(
        label = sprintf("Sim.DiffProc::%s() ~> Sim.DiffProc::%s(..., parallel = TRUE)", name, name),
        transpiler = transpiler
      )
    }
  })

  ## Register both generic and method calls
  transpiler_generic <- make_futurize_for_makeClusterFuture(
    template = template_ignore_clusterEvalQ,
    args = list(
      parallel = "snow",
      ncpus = 2L,
      cl = quote(cl)
    ), defaults = list(
      packages = "Sim.DiffProc",
      seed = TRUE,
      label = "fz:Sim.DiffProc::MCM.sde"
    )
  )

  transpilers[["Sim.DiffProc"]][["MCM.sde"]] <- list(
    label = "Sim.DiffProc::MCM.sde() ~> Sim.DiffProc::MCM.sde(..., parallel = TRUE)",
    transpiler = transpiler_generic
  )

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("Sim.DiffProc", "future")
}
