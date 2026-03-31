# SimDesign::runSimulation(...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   SimDesign::runSimulation(..., parallel = TRUE, ncores = 2L, cl = cl)
# })
#
append_transpilers_for_SimDesign <- function() {
  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'SimDesign' functions requires R (>= 4.4.0)", getRversion()))
  }

  transpilers <- make_package_transpilers("SimDesign", FUN = function(fcn, name) {
    if (all(c("parallel", "ncores", "cl") %in% names(formals(fcn)))) {
      transpiler <- make_futurize_for_makeClusterFuture(args = list(
        parallel = TRUE,
        ncores = 2L,   ## only used for test ncores > 1
        cl = quote(cl)
      ), defaults = list(label = sprintf("fz:SimDesign::%s", name)))

      list(
        label = sprintf("SimDesign::%s() ~> SimDesign::%s(..., parallel = TRUE)", name, name),
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("SimDesign", "future")
}
