transpiler_db <- list()

#' @importFrom future.apply future_lapply
#' @importFrom furrr future_map
append_transpilers <- function(flavor = c("add-on", "built-in"), ...) {
  flavor <- match.arg(flavor, several.ok = FALSE)
  transpiler_db[[flavor]] <<- c(transpiler_db[[flavor]], ...)
}
