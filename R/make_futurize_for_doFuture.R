#' Create a futurize transpiler based on %dofuture%
#'
#' @inheritParams make_futurize_for_makeClusterFuture
#'
#' @returns
#' A transpiler function.
#'
#' @noRd
make_futurize_for_doFuture <- function(defaults = list(), args = list(), template = NULL) {
  if (is.null(template)) {
    template <- bquote_compile(
      with(doFuture::registerDoFuture(flavor = "%dofuture%"),
        local({
          options(future.disposable = structure(.(OPTS), dispose = FALSE))
          on.exit(options(future.disposable = NULL))
          .(EXPR)
        })
      )
    )
  }

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
} ## make_futurize_for_doFuture()

