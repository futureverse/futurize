#' @importFrom future.apply future_lapply
append_transpilers_for_future.apply <- function() {
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
}
