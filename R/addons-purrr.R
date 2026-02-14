# purrr::map(...) =>
#
# furrr::future_map(..., .options = <future.* arguments>)
#
append_transpilers_for_furrr <- function() {
  append_transpilers("futurize::add-on", make_addon_transpilers(
    "purrr", "furrr", make_options = make_options_for_furrr)
  )

  ## Return required packages
  c("purrr", "furrr")
}
