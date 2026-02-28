# TSP::solve_TSP(...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), local({
#   options(future.disposable = structure(OPTS, dispose = FALSE))
#   on.exit(options(future.disposable = NULL))
#   TSP::solve_TSP(...)
# }))
#
append_transpilers_for_TSP <- function() {
  transpilers <- make_package_transpilers("TSP", FUN = function(fcn, name) {
    if (name %in% c("solve_TSP")) {
      list(
        label = sprintf("TSP::%s() ~> TSP::%s()", name, name),
        transpiler = make_futurize_for_doFuture(defaults = list(seed = TRUE))
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("TSP", "doFuture")
}
