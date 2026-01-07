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


make_options_for_furrr <- local({
  defaults_base <- NULL
  
  function(options, fcn) {
    ## Nothing to do?
    if (length(options) == 0L) return(options)

    if (is.null(defaults_base)) {
      defaults_base <<- setdiff(names(formals(furrr::furrr_options)), "...")
    }

    ## Silently drop unknown future options
    keep <- intersect(defaults_base, names(options))
    options <- options[keep]

    options <- do.call(furrr::furrr_options, args = options)
    options <- list(.options = options)
    
    options
  }
})