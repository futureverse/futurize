#' @noRd
make_options_for_future.apply <- local({
  get_defaults <- function(fcn) {
    defaults <- formals(fcn)
    names <- setdiff(names(defaults), "future.envir")
    keep <- grep("^future[.]", names, value = TRUE)
    defaults[keep]
  }
  
  defaults_base <- NULL

  function(options, fcn, defaults = NULL) {
    ## Nothing to do?
    if (length(options) == 0L) return(options)

    if (is.null(defaults_base)) {
      defaults_base <<- get_defaults(future.apply::future_lapply)
    }

    ## Default future.* arguments
    defaults <- c(defaults_base, get_defaults(fcn), defaults)
    keep <- !duplicated(names(defaults), fromLast = TRUE)
    defaults <- defaults[keep]
   
    ## Specified future.* arguments
    specified <- attr(options, "specified")

    ## Remap chunk_size -> chunk.size
    if (length(specified) > 0) {
      specified <- sub("^chunk_size$", "chunk.size", specified)
      names(options) <- sub("^chunk_size$", "chunk.size", names(options))
    }

    ## Remap future options for future.apply
    specified <- sprintf("future.%s", specified)

    names <- setdiff(names(defaults), specified)
    names(options) <- sprintf("future.%s", names(options))
    for (name in names) options[[name]] <- defaults[[name]]

    ## Silently drop non-existing future options
    keep <- intersect(names(options), names(defaults))
    options <- options[keep]
    
    options
  }
})
