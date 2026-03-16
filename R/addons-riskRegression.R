# riskRegression::Score(...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), local({
#   options(future.disposable = structure(OPTS, dispose = FALSE))
#   on.exit(options(future.disposable = NULL))
#   riskRegression::Score(..., parallel = "as.registered",
#                         progress.bar = NULL)
# }))
#
append_transpilers_for_riskRegression <- function() {
  template <- bquote_compile(
    with(doFuture::registerDoFuture(flavor = "%dofuture%"),
      local({
        options(future.disposable = structure(.(OPTS), dispose = FALSE))
        on.exit(options(future.disposable = NULL))
        .(EXPR)
      })
    )
  )

  transpiler <- function(expr, options = NULL) {
    defaults <- list(seed = TRUE)
    expr <- append_call_arguments(expr,
      parallel = "as.registered"
    )
    ## NOTE: We cannot use append_call_arguments() for progress.bar,
    ## because c() drops NULL elements
    expr["progress.bar"] <- list(NULL)

    opts <- make_options_for_doFuture(options, defaults = defaults, wrap = FALSE)
    bquote_apply(template,
      OPTS = opts,
      EXPR = expr
    )
  }

  transpilers <- make_package_transpilers("riskRegression", FUN = function(fcn, name) {
    if ("parallel" %in% names(formals(fcn))) {
      list(
        label = sprintf("riskRegression::%s() ~> riskRegression::%s(..., parallel = \"as.registered\")", name, name),
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("riskRegression", "doFuture")
}
