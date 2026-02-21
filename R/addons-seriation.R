# seriation::train(...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), local({
#   options(future.disposable = structure(OPTS, dispose = FALSE))
#   on.exit(options(future.disposable = NULL))
#   seriation::seriate_best(...)
# }))
#
append_transpilers_for_seriation <- function() {
  transpilers <- make_package_transpilers("seriation", FUN = function(fcn, name) {
    if ("parallel" %in% names(formals(fcn))) {
      list(
        label = sprintf("seriation::%s() ~> seriation::%s()", name, name),
        transpiler = make_futurize_for_doFuture(args = list(parallel = TRUE), defaults = list(seed = TRUE))
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("seriation", "doFuture")
}
