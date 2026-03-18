# metafor::profile.rma.uni(...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   metafor::profile.rma.uni(..., parallel = "snow", ncpus = 2L, cl = cl)
# })
#
append_transpilers_for_metafor <- function() {
  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'metafor' functions requires R (>= 4.4.0)", getRversion()))
  }

  transpiler <- make_futurize_for_makeClusterFuture(args = list(
    parallel = "snow",
    ncpus = 2L,   ## only used for test ncpus > 1
    cl = quote(cl)
  ))

  transpilers <- make_package_transpilers("metafor", FUN = function(fcn, name) {
    if ("parallel" %in% names(formals(fcn))) {
      list(
        label = sprintf("metafor::%s() ~> metafor::%s(..., parallel = \"snow\")", name, name),
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("metafor", "future")
}
