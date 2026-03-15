# vegan::mrpp(...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   vegan::mrpp(..., cluster = cl)
# })
#
append_transpilers_for_vegan <- function() {
  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'vegan' functions requires R (>= 4.4.0)", getRversion()))
  }

  template <- bquote_compile(
    local({
      cl <- do.call(.(CALL), args = .(OPTS))
      
      ## WORKAROUND: https://github.com/vegandevs/vegan/issues/771
      base_attach <- base::attach # silence R CMD check
      base_attach(list(cl = cl), name = "vegan:patch")
      on.exit(detach("vegan:patch"))
      
      oopts <- options(future.ClusterFuture.clusterEvalQ = "error")
      on.exit(options(oopts), add = TRUE)
      .(EXPR)
    })
  )

  transpilers <- make_package_transpilers("vegan", FUN = function(fcn, name) {
    ## vegan 2.8.0: simper() ignores argument 'parallel' with warning
    ## "argument 'parallel' is not used (yet)"
    if (name %in% c("simper")) return()

    ## FIXME: S3 methods with the generic function defined in another
    ## package are currently not supported
    if (name %in% c("anova.cca")) return()



    defaults <- list()
    if (name %in% ("cascadeKM")) defaults$seed <- TRUE

    if ("parallel" %in% names(formals(fcn))) {
      list(
        label = sprintf("vegan::%s() ~> vegan::%s(..., parallel = <cluster>)", name, name),
        transpiler = make_futurize_for_makeClusterFuture(
          args = list(
            parallel = quote(cl)
          ),
          defaults = defaults,
          template = if (name == "cascadeKM") template else NULL
        )
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("vegan", "future")
}
