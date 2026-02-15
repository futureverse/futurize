# caret::train(...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   caret::train(..., parallel = TRUE)
# })
#
append_transpilers_for_caret <- function() {
  transpilers <- make_package_transpilers("caret", FUN = function(fcn, name) {
    ## nnnControl()
    if ("allowParallel" %in% names(formals(fcn))) {
      if (name == "nearZeroVar") {
        list(
          label = sprintf("caret::%s() ~> caret::%s()", name, name),
          transpiler = make_futurize_for_makeClusterFuture(defaults = list(seed = TRUE), args = list(foreach = TRUE))
        )
      } else {
        ## nnnControl() -> nnn()
        basename <- sub("Control$", "", name)
        if (exists(basename, mode = "function", envir = getNamespace("caret"), inherits = FALSE)) {
          list(
            label = sprintf("caret::%s() ~> caret::%s()", basename, basename),
            transpiler = make_futurize_for_makeClusterFuture(defaults = list(seed = TRUE), args = list(parallel = TRUE))
          )
        }
      }
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("caret", "doFuture")
}
