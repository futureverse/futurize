# pvclust::pvclust(..., parallel = FALSE) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   pvclust::pvclust(..., parallel = cl)
# })
#
append_transpilers_for_pvclust <- function() {
  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'pvclust' functions requires R (>= 4.4.0)", getRversion()))
  }

  template_ignore_clusterEvalQ <- bquote_compile(
    local({
      cl <- do.call(.(CALL), args = .(OPTS))
      oopts <- options(future.ClusterFuture.clusterEvalQ = "ignore")
      on.exit(options(oopts))
      .(EXPR)
    })
  )

  transpilers <- make_package_transpilers("pvclust", FUN = function(fcn, name) {
    if (name == "pvclust") {
      base_transpiler <- make_futurize_for_makeClusterFuture(
        template = template_ignore_clusterEvalQ,
        args = list(
          parallel = quote(cl)
        ), defaults = list(
          label = "fz:pvclust::pvclust",
          seed = TRUE
        )
      )

      transpiler <- eval(bquote(function(expr, options = NULL) {
        expr <- match.call(definition = .(fcn), call = expr)
        expr$parallel <- NULL
        .(base_transpiler)(expr, options = options)
      }))

      list(
        label = "pvclust::pvclust() ~> pvclust::pvclust(..., parallel = cl)",
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("pvclust", "future")
}
