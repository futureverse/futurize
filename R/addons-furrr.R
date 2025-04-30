#' @importFrom furrr future_map
append_transpilers_for_furrr <- function() {
  append_transpilers("add-on", make_addon_transpilers(
    "purrr", "furrr", make_options = function(options, fcn) {
      keep <- intersect(names(formals(furrr::furrr_options)), names(options))
      options <- options[keep]
      options <- do.call(furrr::furrr_options, args = options)
      options <- list(.options = options)
      options
    })
  )
}
