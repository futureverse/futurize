# crossmap::xmap_dbl(...) =>
#
# crossmap::future_xmap_dbl(..., .options = <future arguments>)
#
append_transpilers_for_crossmap <- function() {
  append_transpilers("futurize::add-on", make_addon_transpilers(
    "crossmap", "crossmap", make_options = function(options, fcn) {
      keep <- intersect(names(formals(furrr::furrr_options)), names(options))
      options <- options[keep]
      options <- do.call(furrr::furrr_options, args = options)
      options <- list(.options = options)
      options
    })
  )

  ## Return required packages
  c("crossmap")
}
