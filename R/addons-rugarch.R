# rugarch::arfimacv(..., cluster = cl) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   oopts <- options(future.ClusterFuture.clusterEvalQ = "ignore")
#   on.exit(options(oopts))
#   rugarch::arfimacv(..., cluster = cl)
# })
#
append_transpilers_for_rugarch <- function() {
  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'rugarch' functions requires R (>= 4.4.0)", getRversion()))
  }

  template_ignore_clusterEvalQ <- bquote_compile(
    local({
      cl <- do.call(.(CALL), args = .(OPTS))
      ## rugarch uses clusterEvalQ() for library(rugarch), which
      ## is already taken care of by the future framework
      oopts <- options(future.ClusterFuture.clusterEvalQ = "ignore")
      on.exit(options(oopts))
      .(EXPR)
    })
  )

  transpilers <- make_package_transpilers("rugarch", FUN = function(fcn, name) {
    if ("cluster" %in% names(formals(fcn))) {
      transpiler <- make_futurize_for_makeClusterFuture(
        template = template_ignore_clusterEvalQ,
        args = list(
          cluster = quote(cl)
        ),
        defaults = list(
          label = sprintf("fz:rugarch::%s", name),
          seed = TRUE
        )
      )
      
      list(
        label = sprintf("rugarch::%s() ~> rugarch::%s(..., cluster = cl)", name, name),
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("rugarch", "future")
}
