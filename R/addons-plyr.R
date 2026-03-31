# plyr::llply(xs, fcn) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), 
#   plyr::llply(xs, fcn,
#     .parallel = TRUE,
#     .paropts = list(.options.future = <future arguments>)
#   )
# )
#
append_transpilers_for_plyr <- function() {
  template <- bquote_compile(
    with(doFuture::registerDoFuture(flavor = "%dofuture%"), (.(EXPR)))
  )

  template2 <- bquote_compile(function(expr, options = NULL) {
    defaults <- list(label = sprintf("fz:plyr::%s-%%d", .(NAME)))
    options <- make_options_for_doFuture(options, defaults = defaults, wrap = TRUE)
    expr <- append_call_arguments(expr,
      .parallel = TRUE,
      .paropts = options
    )
    bquote_apply(template, EXPR = expr)
  })

  transpilers <- make_package_transpilers("plyr", FUN = function(fcn, name) {
    if (".parallel" %in% names(formals(fcn))) {
      transpiler <- eval(bquote_apply(template2, NAME = name))
      list(
        label = sprintf("plyr::%s() ~> plyr::%s(..., parallel = TRUE)", name, name),
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("plyr", "doFuture")
}
