#' Create a futurize transpiler based on makeClusterFuture()
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
    local({
      cl <- do.call(.(CALL), args = .(OPTS))
      oopts <- options(future.ClusterFuture.clusterEvalQ = "error")
      on.exit(options(oopts))
      .(EXPR)
    })
  )

  ## To please 'R CMD check' on R (< 4.4.0), where
  ## future::makeClusterFuture() is not available
  call <- as.call(lapply(c("::", "future", "makeClusterFuture"), as.name))

  function(expr, options = NULL) {
    expr <- append_call_arguments(expr, .args = args)
    opts <- make_options_for_makeClusterFuture(options, defaults = defaults)
    bquote_apply(template,
      CALL = call,
      OPTS = opts,
      EXPR = expr
    )
  }
} ## make_futurize_for_makeClusterFuture()
