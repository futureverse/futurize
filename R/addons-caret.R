# caret::train(...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   caret::train(..., parallel = TRUE)
# })
#
append_transpilers_for_caret <- function() {
  template <- bquote_compile(
    with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
      ## This will be automatically removed by doFuture
      options(future.disposable = .(OPTS))
      .(EXPR)
    })
  )

  make_transpiler <- function(name, args = list(parallel = TRUE), defaults = list(seed = TRUE)) {
    function(expr, options = NULL) {
      expr <- append_call_arguments(expr,
        .args = args
      )

      opts <- make_options_for_doFuture(options, defaults = defaults, wrap = FALSE)
      
      ## Update 'OPTS'
      bquote_apply(template,
        OPTS = opts,
        EXPR = expr
      )
    }
  }

  transpilers <- make_package_transpilers("caret", FUN = function(fcn, name) {
    ## nnnControl()
    if ("allowParallel" %in% names(formals(fcn))) {
      if (name == "nearZeroVar") {
        list(
          label = sprintf("caret::%s() ~> caret::%s()", name, name),
          transpiler = make_transpiler(name, args = list(foreach = TRUE))
        )
      } else {
        ## nnnControl() -> nnn()
        basename <- sub("Control$", "", name)
        if (exists(basename, mode = "function", envir = getNamespace("caret"), inherits = FALSE)) {
          list(
            label = sprintf("caret::%s() ~> caret::%s()", basename, basename),
            transpiler = make_transpiler(basename, args = list(parallel = TRUE))
          )
        }
      }
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("caret", "doFuture")
}
