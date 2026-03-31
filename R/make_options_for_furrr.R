#' @noRd
make_options_for_furrr <- local({
  defaults_base <- NULL
  
  function(options, fcn, defaults = NULL) {
    ## Nothing to do?
    if (length(options) == 0L) return(options)

    if (is.null(defaults_base)) {
      defaults_base <<- setdiff(names(formals(furrr::furrr_options)), "...")
    }

    ## Set default 'prefix'?
    if (!"prefix" %in% names(options) && "prefix" %in% names(defaults)) {
      options[["prefix"]] <- defaults[["prefix"]]
    }

    ## Silently drop unknown future options
    keep <- intersect(defaults_base, names(options))
    options <- options[keep]

    options <- do.call(furrr::furrr_options, args = options)
    options <- list(.options = options)
    
    options
  }
})
