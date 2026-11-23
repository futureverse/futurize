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
#' @param rng (resources) If TRUE, parallel-safe random number generation
#'        (RNG) is set up such that each element is processed with its own,
#'        statistically sound RNG stream. This is needed whenever the code
#'        uses random numbers, e.g. via `rnorm()` or `sample()`. The results
#'        are reproducible given a fixed `set.seed()`, regardless of how
#'        and where the elements are processed. Currently, the L'Ecuyer-CMRG
#'        RNG is used for this.
#'        If FALSE (default), then no RNG streams are set up, and you will be
#'        warned if random numbers are still generated.
#'        If NA, then no RNG streams are set up, and there is no check for
#'        random numbers being generated. This can be used to silence
#'        false-positive RNG warnings, e.g. when the code uses random numbers
#'        in a way that does not affect the results. If in doubt, use
#'        `rng = TRUE`, which is always statistically sound.
#'        Currently, only `TRUE`, `FALSE`, and `NA` are supported; other
#'        types of values are reserved for future extensions.
#'        If `rng` is specified, then `seed` must not be specified.
#'
#' @param seed (resources) Superseded by `rng`, but kept for backward
#'        compatibility. `seed = TRUE`, `seed = FALSE`, and `seed = NULL` are
#'        equivalent to `rng = TRUE`, `rng = FALSE`, and `rng = NA`.
#'        For other values, see the `seed`
#'        argument of [future::future()].
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
#' # Declare that parallel random number generation is needed
#' str(futurize_options(rng = TRUE))
#'
#' @export
futurize_options <- function(rng = FALSE, seed = FALSE, globals = TRUE, packages = NULL, stdout = TRUE, conditions = "condition", scheduling = 1.0, chunk_size = NULL, ...) {
  if (!missing(rng)) {
    if (!missing(seed)) {
      stop("futurize() options 'rng' and 'seed' must not be specified at the same time; use only 'rng'", call. = FALSE)
    }
    seed <- parse_rng(rng)
  }

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
  if (!missing(rng) || !missing(seed)) specified <- c(specified, "seed")
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


#' Parse the 'rng' option into a 'seed' value understood by future
#'
#' @param rng The value of the futurize() `rng` option.
#'
#' @return
#' A value to be used for the `seed` argument of [future::future()].
#'
#' @details
#' Currently, only `TRUE`, `FALSE`, and `NA` are supported, where `NA`
#' corresponds to `seed = NULL`, i.e. no RNG streams and no RNG checks. This is where support
#' for additional types of RNG declarations, e.g. alternative parallel RNG
#' methods, will be added in the future.
#'
#' @noRd
parse_rng <- function(rng) {
  if (is.logical(rng) && length(rng) == 1L) {
    ## rng = NA: no RNG streams and no RNG checks
    if (is.na(rng)) return(NULL)
    return(rng)
  }
  value <- if (is.null(rng)) "NULL" else paste(deparse(rng), collapse = " ")
  stop(sprintf("futurize() option 'rng' must be TRUE, FALSE, or NA: %s", value), call. = FALSE)
}
