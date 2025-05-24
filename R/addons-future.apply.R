append_transpilers_for_future.apply <- function() {
  ## base::apply(), ...
  append_transpilers("add-on", make_addon_transpilers(
    "base", "future.apply", make_options = function(options, fcn) {
      names(options) <- sprintf("future.%s", names(options))
      names <- c(names(formals(fcn)),
                 names(formals(future.apply::future_lapply)))
      keep <- intersect(names, names(options))
      options <- options[keep]
      options
    })
  )

  ## stats::kernapply()
  append_transpilers("add-on", make_addon_transpilers(
    "stats", "future.apply", make_options = function(options, fcn) {
      names(options) <- sprintf("future.%s", names(options))
      names <- c(names(formals(fcn)),
                 names(formals(future.apply::future_lapply)))
      keep <- intersect(names, names(options))
      options <- options[keep]
      options
    })
  )

  ## Return required packages
  c("future.apply")
}
