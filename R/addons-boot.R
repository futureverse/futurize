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

  ## censboot() calls clusterEvalQ(cl, library(...)), which is not
  ## supported by future (< 1.76.0)
  old_future <- (packageVersion("future") < "1.76.0")
  template <- NULL
  if (old_future) {
    template <- bquote_compile(
      local({
        cl <- do.call(.(CALL), args = .(OPTS))
        oopts <- options(future.ClusterFuture.clusterEvalQ = "ignore")
        on.exit(options(oopts))
        .(EXPR)
      })
    )
  }

  transpilers <- make_package_transpilers("boot", FUN = function(fcn, name) {
    if ("parallel" %in% names(formals(fcn))) {
      transpiler <- make_futurize_for_makeClusterFuture(
        template = template,
        args = list(
          parallel = "snow",
          ncpus = 2L,   ## only used for test ncpus > 1
          cl = quote(cl)
        ), defaults = list(
          packages = if (old_future && name == "censboot") "survival",
          label = sprintf("fz:boot::%s", name)
        )
      )

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
