# glmnet::cv.glmnet(...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   glmnet::cv.glmnet(..., parallel = TRUE)
# })
#
append_transpilers_for_glmnet <- function() {
  template <- bquote_compile(
    with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
      ## This will be automatically removed by doFuture
      options(future.disposable = .(OPTS))
      .(EXPR)
    })
  )

  make_transpiler <- function(name, defaults = list()) {
    function(expr, options = NULL) {
      expr <- append_call_arguments(expr,
        parallel = TRUE
      )

      opts <- make_options_for_doFuture(options, defaults = defaults, wrap = FALSE)
      
      ## Update 'OPTS'
      bquote_apply(template,
        OPTS = opts,
        EXPR = expr
      )
    }
  }

  transpilers <- make_package_transpilers("glmnet", FUN = function(fcn, name) {
    if ("parallel" %in% names(formals(fcn))) {
      if (name == "cv.glmnet") {
        defaults <- list(seed = TRUE)
      } else {
        defaults <- list()
      }
      
      list(
        label = sprintf("glmnet::%s() ~> glmnet::%s(..., parallel = TRUE)", name, name),
        transpiler = make_transpiler(name, defaults = defaults)
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("glmnet", "doFuture")
}
