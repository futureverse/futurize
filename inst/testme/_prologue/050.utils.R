## Local functions for test scripts
printf <- function(...) cat(sprintf(...))
mstr <- function(...) message(paste(capture.output(str(...)), collapse = "\n"))

## Call futurize() + validates that at least one future was created
futurize_and_verify <- function(expr, substitute = TRUE, ..., when = TRUE, eval = TRUE, envir = parent.frame()) {
  if (substitute) expr <- substitute(expr)
  if (!when || !eval) {
    res <- futurize::futurize(expr, substitute = FALSE, ..., when = when, eval = eval, envir = envir)
    return(res)
  }
  
  backend <- future::plan("backend")
  counters <- backend[["counters"]]
  
  res <- futurize::futurize(expr, substitute = FALSE, ..., when = when, eval = eval, envir = envir)
  
  delta <- backend[["counters"]] - counters

  ## Assert that at least one future was created
  if (delta[["created"]] == 0L) {
    e <- simpleError(sprintf("futurize() test did not result in futures being created"))
    class(e) <- c("FuturizeTestAssertionError", class(e))
    stop(e)
  }

  res
}
