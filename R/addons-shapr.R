# shapr::explain(...) =>
#
# local({
#   ## This will be automatically consumed and removed by 'future.apply'
#   options(future.disposable = structure(<future options>, dispose = FALSE))
#   on.exit(options(future.disposable = NULL))
#   shapr::explain(...)
# })
#
append_transpilers_for_shapr <- function() {
  transpilers <- make_package_transpilers("shapr", FUN = function(fcn, name) {
    if (name %in% c("explain", "explain_forecast")) {
      defaults <- list(
        future.seed = TRUE,
        future.label = sprintf("fz:shapr::%s-%%d", name)
      )
      list(
        label = sprintf("shapr::%s() ~> shapr::%s()", name, name),
        transpiler = make_futurize_for_future.apply(defaults = defaults)
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("shapr", "future.apply")
}
