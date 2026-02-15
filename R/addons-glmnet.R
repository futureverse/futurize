# glmnet::cv.glmnet(...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   glmnet::cv.glmnet(..., parallel = TRUE)
# })
#
append_transpilers_for_glmnet <- function() {
  transpilers <- make_package_transpilers("glmnet", FUN = function(fcn, name) {
    if ("parallel" %in% names(formals(fcn))) {
      if (name == "cv.glmnet") {
        defaults <- list(seed = TRUE)
      } else {
        defaults <- list()
      }
      
      list(
        label = sprintf("glmnet::%s() ~> glmnet::%s(..., parallel = TRUE)", name, name),
        transpiler = make_futurize_for_makeClusterFuture(defaults = defaults, args = list(parallel = TRUE))
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("glmnet", "doFuture")
}
