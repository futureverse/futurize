transpiler_db <- list()

#' @importFrom future.apply future_lapply
#' @importFrom furrr future_map
appendTranspilers <- function(flavor, ...) {
  transpiler_db[[flavor]] <<- c(transpiler_db[[flavor]], ...)
}
