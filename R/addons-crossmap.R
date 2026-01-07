# crossmap::xmap_dbl(...) =>
#
# crossmap::future_xmap_dbl(..., .options = <future arguments>)
#
append_transpilers_for_crossmap <- function() {
  append_transpilers("futurize::add-on", make_addon_transpilers(
    "crossmap", "crossmap", make_options = make_options_for_furrr)
  )

  ## Return required packages
  c("crossmap")
}
