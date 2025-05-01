.onLoad <- function(libname, pkgname) {
  append_transpilers_for_pkg("doFuture")
  append_transpilers_for_pkg("future.apply")
  append_transpilers_for_pkg("furrr")
  append_transpilers_for_pkg("plyr")
}
