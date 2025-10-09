# base::lapply(xs, fcn, ...) =>
#
# future.apply::future_lapply(xs, fcn, ..., <future.* arguments>)
#
append_transpilers_for_future.apply <- function() {
  get_defaults <- function(fcn) {
    defaults <- formals(fcn)
    names <- setdiff(names(defaults), "future.envir")
    keep <- grep("^future[.]", names, value = TRUE)
    defaults[keep]
  }
  
  defaults_future_lapply <- get_defaults(future.apply::future_lapply)

  make_options <- function(options, fcn) {
    ## Default future.* arguments
    defaults <- c(defaults_future_lapply, get_defaults(fcn))
    keep <- !duplicated(names(defaults), fromLast = TRUE)
    defaults <- defaults[keep]
    
    ## Specified future.* arguments
    specified <- sprintf("future.%s", attr(options, "specified"))
    names <- setdiff(names(defaults), specified)
    names(options) <- sprintf("future.%s", names(options))
    for (name in names) options[[name]] <- defaults[[name]]

    ## Non-existing future.* arguments
    keep <- intersect(names(options), names(defaults))
    options <- options[keep]
    
    options
  }
    
  ## base::apply(), ...
  append_transpilers("futurize", "add-on", make_addon_transpilers(
    "base", "future.apply", make_options = make_options)
  )

  ## stats::kernapply()
  append_transpilers("futurize", "add-on", make_addon_transpilers(
    "stats", "future.apply", make_options = make_options)
  )

  ## Return required packages
  c("future.apply")
}
