# strucchange::breakpoints(...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), local({
#   options(future.disposable = structure(OPTS, dispose = FALSE))
#   on.exit(options(future.disposable = NULL))
#   strucchange::breakpoints(..., hpc = "foreach")
# }))
#
append_transpilers_for_strucchange <- function() {
  transpilers <- make_package_transpilers("strucchange", FUN = function(fcn, name) {
    if (name == "breakpoints.formula") {
      list(
        label = sprintf("strucchange::%s() ~> strucchange::%s()", name, name),
        transpiler = make_futurize_for_doFuture(args = list(hpc = "foreach"))
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("strucchange", "doFuture")
}
