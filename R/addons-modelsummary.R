# modelsummary::modelsummary(...) =>
#
# local({
#   ## This will be automatically consumed and removed by 'future.apply'
#   options(future.disposable = structure(<future options>, dispose = FALSE))
#   on.exit(options(future.disposable = NULL))
#   modelsummary::modelsummary(...)
# })
#
append_transpilers_for_modelsummary <- function() {
  transpilers <- make_package_transpilers("modelsummary", FUN = function(fcn, name) {
    if (name %in% c("modelsummary", "msummary", "modelplot")) {
      defaults <- list(
        future.seed = TRUE,
        future.label = sprintf("fz:modelsummary::%s-%%d", name)
      )
      list(
        label = sprintf("modelsummary::%s() ~> modelsummary::%s()", name, name),
        transpiler = make_futurize_for_future.apply(defaults = defaults)
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("modelsummary", "future.apply")
}
