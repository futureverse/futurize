# base::lapply(xs, fcn, ...) =>
#
# future.apply::future_lapply(xs, fcn, ..., <future.* arguments>)
#
append_transpilers_for_future.apply <- function() {
  ## base::apply(), ...
  append_transpilers("futurize::add-on", make_addon_transpilers(
    "base", "future.apply", make_options = make_options_for_future.apply)
  )

  ## stats::kernapply()
  append_transpilers("futurize::add-on", make_addon_transpilers(
    "stats", "future.apply", make_options = make_options_for_future.apply)
  )

  ## Return required packages
  c("future.apply")
}
