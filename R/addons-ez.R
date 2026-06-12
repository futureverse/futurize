# ez::ezBoot(...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   ez::ezBoot(..., parallel = TRUE)
# })
#
# and similar for ezPerm(), ezPlot2()
#
append_transpilers_for_ez <- function() {
  transpilers <- make_package_transpilers("ez", FUN = function(fcn, name) {
    if ("parallel" %in% names(formals(fcn))) {
      defaults <- list(label = sprintf("fz:ez::%s-%%d", name))
      if (name %in% c("ezBoot", "ezPerm")) {
        defaults[["seed"]] <- TRUE
      }
      
      list(
        label = sprintf("ez::%s() ~> ez::%s(..., parallel = TRUE)", name, name),
        transpiler = make_futurize_for_doFuture(defaults = defaults, args = list(parallel = TRUE))
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("ez", "doFuture")
}
