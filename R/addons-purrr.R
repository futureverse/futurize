# purrr::map(...) =>
#
# furrr::future_map(..., .options = <future.* arguments>)
#
append_transpilers_for_furrr <- function() {
  defaults <- formals(furrr::furrr_options)
  defaults <- setdiff(names(defaults), "...")

  append_transpilers("futurize::add-on", make_addon_transpilers(
    "purrr", "furrr", make_options = function(options, fcn) {
      keep <- intersect(defaults, names(options))
      options <- options[keep]
      options <- do.call(furrr::furrr_options, args = options)
      options <- list(.options = options)
      options
    })
  )

  ## Return required packages
  c("purrr", "furrr")
}
