.onLoad <- function(libname, pkgname) {
  ## future.apply
  appendTranspilers("add-on", make_addon_transpilers(
    "base", "future.apply", make_options = function(options, fcn) {
      names(options) <- sprintf("future.%s", names(options))
      names <- c(names(formals(fcn)),
                 names(formals(future.apply::future_lapply)))
      keep <- intersect(names, names(options))
      options <- options[keep]
      options
    })
  )

  ## furrr
  appendTranspilers("add-on", make_addon_transpilers(
    "purrr", "furrr", make_options = function(options, fcn) {
      keep <- intersect(names(formals(furrr::furrr_options)), names(options))
      options <- options[keep]
      options <- do.call(furrr::furrr_options, args = options)
      options <- list(.options = options)
      options
    })
  )
}
