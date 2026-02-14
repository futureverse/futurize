#' @noRd
make_options_for_makeClusterFuture <- local({
  get_defaults <- function(fcn) {
    defaults <- names(formals(fcn))
    excl <- c("expr", "substitute", "envir", "earlySignal", "gc", "...")
    setdiff(defaults, excl)
  }
  
  defaults_base <- NULL

  function(options, defaults = NULL) {
    ## Nothing to do?
    if (length(options) == 0L && length(defaults) == 0L) return(options)

    if (is.null(defaults_base)) {
      defaults_base <<- get_defaults(future::future)
    }

    if (length(defaults) > 0) {
      names <- setdiff(names(defaults), attr(options, "specified"))
      for (name in names) {
        if (name == "packages") {
          options[[name]] <- c(options[[name]], defaults[[name]])
        } else {
          options[[name]] <- defaults[[name]]
        }
      }
    }

    options <- options[names(options) %in% defaults_base]

    options
  }
})
