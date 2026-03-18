make_options_for_doFuture <- local({
  defaults_base <- NULL

  function(options, defaults = NULL, wrap = TRUE) {
    ## Nothing to do?
    if (length(options) == 0 && length(defaults) == 0) return(options)

    if (is.null(defaults_base)) {
      ## The 'doFuture' package already imports 'future.apply'
      defaults_base <<- names(formals(future.apply::future_lapply))
    }

    if (length(defaults) > 0) {
      names <- setdiff(names(defaults), attr(options, "specified"))
      for (name in names) options[[name]] <- defaults[[name]]
    }

    ## Remap chunk_size -> chunk.size
    names(options) <- sub("^chunk_size$", "chunk.size", names(options))

    ## Remap future options for doFuture
    names <- sprintf("future.%s", names(options))

    ## Silently drop unknown future options
    keep <- intersect(defaults_base, names)
    idxs <- match(keep, table = names)
    options <- options[idxs]
    
    if (wrap) options <- list(.options.future = options)

    options
  }
})
