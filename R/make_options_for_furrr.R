#' @noRd
make_options_for_furrr <- local({
  defaults_base <- NULL
  
  function(options, fcn, defaults = NULL) {
    if (is.null(defaults_base)) {
      defaults_base <<- setdiff(names(formals(furrr::furrr_options)), "...")
    }

    names <- names(options)
    if ("label" %in% names) {
      names[names == "label"] <- "prefix"
      names(options) <- names
    }
    
    ## Set default 'prefix'?
    if (!"prefix" %in% names && "prefix" %in% names(defaults)) {
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
