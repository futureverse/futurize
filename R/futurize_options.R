#' Options controlling resources, scheduling and evaluation of futures
#'
#' Some futures require specific **resources** and capabilities (e.g., RNG,
#' packages, and globals) in order to be evaluated. These can be declared
#' via this function.
#' In addition, this function can control how futures are **evaluated**,
#' including what is collected from futures (e.g., standard output and
#' conditions).
#' It can also control how future are **scheduled**, including how a set
#' of futures are partitioned (e.g. chunking).
#'
#' @inheritParams future::future
#'
#' @param scheduling (scheduling) Average number of futures ("chunks") per
#'        worker.
#'        If `0.0`, then a single future is used to process all elements.
#'        If `1.0` or `TRUE`, then one future per worker is used.
#'        If `2.0`, then each worker will process two futures
#'        (if there are enough elements).
#'        If `Inf` or `FALSE`, then one future per element
#'        is used.
#'        Only used if `chunk_size` is `NULL`.
#'
#' @param chunk_size (scheduling) The average number of elements per future
#'        ("chunk").
#'        If `Inf`, then all elements are processed in a single future.
#'        If `NULL`, then argument `scheduling` is used.
#
#' @param \ldots Additional named options.
#'
#' @return
#' A named list of future options.
#' Attribute `specified` is a character vector of future options
#' that were explicitly specified.
#'
#' @examples
#' # Default futurize options
#' str(futurize_options())
#'
#' @export
futurize_options <- function(seed = FALSE, globals = TRUE, packages = NULL, stdout = TRUE, conditions = "condition", scheduling = 1.0, chunk_size = NULL, ...) {
  args <- list(
     # Resources:
           seed = seed,
        globals = globals,
       packages = packages,
     # Evaluation:
         stdout = stdout,
     conditions = conditions,
     # Scheduling:
     scheduling = scheduling,
     chunk_size = chunk_size,
                  ...
  )
  specified <- character(0L)
  if (!missing(seed)) specified <- c(specified, "seed")
  if (!missing(globals)) specified <- c(specified, "globals")
  if (!missing(packages)) specified <- c(specified, "packages")
  if (!missing(stdout)) specified <- c(specified, "stdout")
  if (!missing(conditions)) specified <- c(specified, "conditions")
  if (!missing(scheduling)) specified <- c(specified, "scheduling")
  if (!missing(chunk_size)) specified <- c(specified, "chunk_size")
  specified <- c(specified, ...names())
  attr(args, "specified") <- specified
  args
}
