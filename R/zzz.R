.onLoad <- function(libname, pkgname) {
  ## future.apply
  append_transpilers_for_future.apply()

  ## furrr
  append_transpilers_for_furrr()

  ## doFuture
  append_transpilers_for_doFuture()
}
