#' Create a futurize transpiler based of %dofuture%
#' 
#' @param expr An \R call expression.
#'
#' @param \ldots,.args Named arguments to be appended to the call expression.
#'
#' @returns
#' A transpiler function.
#'
#' @noRd
make_futurize_for_makeClusterFuture <- function(defaults = list(), args = list()) {
  template <- bquote_compile(
    with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
      ## This will be automatically removed by doFuture
      options(future.disposable = .(OPTS))
      .(EXPR)
    })
  )

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
} ## make_futurize_for_makeClusterFuture()

