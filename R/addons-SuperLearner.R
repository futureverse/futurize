# SuperLearner::CV.SuperLearner(...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   SuperLearner::CV.SuperLearner(..., parallel = cl)
# })
#
append_transpilers_for_SuperLearner <- function() {
  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'SuperLearner' functions requires R (>= 4.4.0)", getRversion()))
  }

  transpilers <- make_package_transpilers("SuperLearner", FUN = function(fcn, name) {
    if ("parallel" %in% names(formals(fcn)) && name == "CV.SuperLearner") {
      transpiler <- make_futurize_for_makeClusterFuture(
        args = list(
          parallel = quote(cl)
        ), defaults = list(
          packages = "SuperLearner",
          seed = TRUE,
          label = sprintf("fz:SuperLearner::%s", name)
        )
      )

      list(
        label = sprintf("SuperLearner::%s() ~> SuperLearner::%s(..., parallel = cl)", name, name),
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("SuperLearner", "future")
}
