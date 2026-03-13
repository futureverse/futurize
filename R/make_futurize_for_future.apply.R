#' Create a futurize transpiler based on 'future.apply'
#' 
#' @inheritParams make_futurize_for_makeClusterFuture
#'
#' @param fcn The \pkg{future.apply} function to generate options for.
#'
#' @returns
#' A transpiler function.
#'
#' @noRd
make_futurize_for_future.apply <- function(defaults = list(), args = list(), template = NULL, fcn = future.apply::future_lapply) {
  if (is.null(template)) {
    template <- bquote_compile(
     local({
        ## This will be automatically consumed and removed by 'future.apply'
        options(future.disposable = structure(.(OPTS), dispose = FALSE))
        on.exit(options(future.disposable = NULL))
        .(EXPR)
      })
    )
  }
  
  function(expr, options = NULL) {
    expr <- append_call_arguments(expr, .args = args)
    opts <- make_options_for_future.apply(options, defaults = defaults, fcn = fcn)
    names(opts) <- sub("^future[.]", "", names(opts))
    
    bquote_apply(template,
      OPTS = opts,
      EXPR = expr
    )
  }
} ## make_futurize_for_future.apply()
