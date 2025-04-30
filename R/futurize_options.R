#' Options for how futures are partitioned and resolved
#'
#' @inheritParams future::future
#'
#' @param scheduling Average number of futures ("chunks") per worker.
#'        If `0.0`, then a single future is used to process all elements
#'        of `X`.
#'        If `1.0` or `TRUE`, then one future per worker is used.
#'        If `2.0`, then each worker will process two futures
#'        (if there are enough elements in `X`).
#'        If `Inf` or `FALSE`, then one future per element of
#'        `X` is used.
#'        Only used if `future.chunk.size` is `NULL`.
#'
#' @param chunk.size The average number of elements per future ("chunk").
#'        If `Inf`, then all elements are processed in a single future.
#'        If `NULL`, then argument `future.scheduling` is used.
#
#' @param \ldots Additional named options.
#'
#' @return
#' A named list of future options.
#'
#' @export
futurize_options <- function(seed = FALSE, globals = TRUE, packages = NULL, stdout = TRUE, conditions = "condition", gc = FALSE, earlySignal = FALSE, scheduling = 1.0, chunk.size = NULL, ...) {
  args <- list(
    seed = seed,
    globals = globals,
    packages = packages,
    stdout = stdout,
    conditions = conditions,
    gc = gc,
    earlySignal = earlySignal,
    ...
  )
  args
}
