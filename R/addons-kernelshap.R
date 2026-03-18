# kernelshap::kernelshap(...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   kernelshap::kernelshap(..., parallel = TRUE)
# })
#
append_transpilers_for_kernelshap <- function() {
  transpilers <- make_package_transpilers("kernelshap", FUN = function(fcn, name) {
    if (name %in% c("kernelshap", "permshap")) {
      list(
        label = sprintf("kernelshap::%s() ~> kernelshap::%s(..., parallel = TRUE)", name, name),
        transpiler = make_futurize_for_doFuture(defaults = list(seed = TRUE), args = list(parallel = TRUE))
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("kernelshap", "doFuture")
}
