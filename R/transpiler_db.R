transpiler_db <- list()

append_transpilers <- function(flavor = c("add-on", "built-in"), ...) {
  flavor <- match.arg(flavor, several.ok = FALSE)
  transpiler_db[[flavor]] <<- c(transpiler_db[[flavor]], ...)
}
