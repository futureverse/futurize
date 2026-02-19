#' Create a futurize transpiler based on 'future.apply'
#' 
#' @param expr An \R call expression.
#'
#' @param \ldots,.args Named arguments to be appended to the call expression.
#'
#' @returns
#' A transpiler function.
#'
#' @noRd
make_futurize_for_future.apply <- function(defaults = list(), args = list(), fcn = future.apply::future_lapply) {
  template <- bquote_compile(
   local({
      ## This will be automatically consumed and removed by 'future.apply'
      options(future.disposable = structure(.(OPTS), dispose = FALSE))
      on.exit(options(future.disposable = NULL))
      .(EXPR)
    })
  )
  
  function(expr, options = NULL) {
    expr <- append_call_arguments(expr, .args = args)
    opts <- make_options_for_future.apply(options, defaults = defaults, fcn = fcn)
    names(opts) <- sub("^future[.]", "", names(opts))
    
    bquote_apply(template,
      CALL = call,
      OPTS = opts,
      EXPR = expr
    )
  }
} ## make_futurize_for_future.apply()
