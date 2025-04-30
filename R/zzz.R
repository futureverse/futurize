.onLoad <- function(libname, pkgname) {
  appendTranspilers("addon", make_addon_transpilers("base", "future.apply"))
  appendTranspilers("addon", make_addon_transpilers("purrr", "furrr"))
}
