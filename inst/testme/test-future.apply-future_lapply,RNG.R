#' @tags pkg-future.apply
#' @tags future_lapply
#' @tags sequential multisession multicore

if (requireNamespace("future.apply", quietly = TRUE)) {

library(futurize)



message("*** future_lapply() and RNGs ...")

options(future.debug = FALSE)

message("* lapply(x, ..., future.seed = <invalid>) |> futurize() ...")

res <- tryCatch({
  y <- lapply(1:3, FUN = identity, future.seed = as.list(1:2) |> futurize_and_verify())
}, FuturizeTestAssertionError = stop, error = identity)
print(res)
stopifnot(inherits(res, "simpleError"))

res <- tryCatch({
  y <- lapply(1:3, FUN = identity, future.seed = list(1, 2, 3:4) |> futurize_and_verify())
}, FuturizeTestAssertionError = stop, error = identity)
print(res)
stopifnot(inherits(res, "simpleError"))

res <- tryCatch({
  y <- lapply(1:3, FUN = identity, future.seed = as.list(1:3) |> futurize_and_verify())
}, FuturizeTestAssertionError = stop, error = identity)
print(res)
stopifnot(inherits(res, "simpleError"))

seeds <- lapply(1:3, FUN = as_lecyer_cmrg_seed)
res <- tryCatch({
  y <- lapply(1:3, FUN = identity, future.seed = lapply(seeds, FUN = as.numeric) |> futurize_and_verify())
}, FuturizeTestAssertionError = stop, error = identity)
print(res)
stopifnot(inherits(res, "simpleError"))

seeds[[1]][1] <- seeds[[1]][1] + 1L
res <- tryCatch({
  y <- lapply(1:3, FUN = identity, future.seed = seeds) |> futurize_and_verify()
}, FuturizeTestAssertionError = stop, error = identity)
print(res)
stopifnot(inherits(res, "simpleError"))

message("* lapply(x, ..., future.seed = <invalid>) |> futurize() ... DONE")


## Iterate of the same set in all tests
x <- 1:5

seed_sets <- list(
  A = TRUE,
##  B = NA,
  C = 42L,
  D = as_lecyer_cmrg_seed(42L),
  E = list(),
  F = vector("list", length = length(x))
)

## Generate sequence of seeds of the current RNGkind()
## NOTE: This is NOT a good way to generate random seeds!!!
seeds <- lapply(seq_along(x), FUN = function(i) {
  set.seed(i)
  globalenv()$.Random.seed
})
seed_sets$E <- seeds

## Generate sequence of L'Ecyer CMRG seeds
seeds <- seed_sets$F
seeds[[1]] <- seed_sets$D
for (kk in 2:length(x)) seeds[[kk]] <- parallel::nextRNGStream(seeds[[kk - 1]])
seed_sets$F <- seeds

rm(list = "seeds")

labels <- vapply(names(seed_sets), FUN.VALUE = character(1L), FUN = function(name) {
  future.seed <- seed_sets[[name]]
  if (is.list(future.seed)) {
    sprintf("<list of %d seeds each being a %d-int seed>",
            length(future.seed), length(future.seed[[1]]))
  } else {
    hpaste(future.seed)
  }
})

message("* lapply(x, ..., future.seed = FALSE) |> futurize() ...")
for (name in names(seed_sets)) {
  message(sprintf("* lapply(x, ..., future.seed = %s) |> futurize() ...", labels[[name]]))
}

## A single plan(strategy) per (cores, strategy) combination, covering
## the 'seed = FALSE' scenario and all 'seed_sets' scenarios below,
## instead of separately sweeping through all (cores, strategy)
## combinations for each of the 7 scenarios in turn. Same assertions,
## same per-scenario truth memoization (established on the first
## (cores, strategy) encountered for that scenario, compared against
## on every later one), just far fewer (de facto costly on some
## backends) plan() switches.
y0_false <- seed00_false <- y0_nested <- NULL
y0_list <- seed00_list <- vector("list", length(seed_sets))
names(y0_list) <- names(seed00_list) <- names(seed_sets)

for (cores in 1:availCores) {
  message(sprintf("  - Testing with %d cores ...", cores))
  options(mc.cores = cores)

  for (strategy in supportedStrategies(cores)) {
    message(sprintf("* plan('%s') ...", strategy))
    plan(strategy)

    ## --- future.seed = FALSE ---
    set.seed(0xBEEF)
    seed0 <- get_random_seed()
    y <- lapply(x, FUN = function(i) i) |> futurize_and_verify(seed = FALSE)
    y <- unlist(y)
    seed <- get_random_seed()
    if (is.null(y0_false)) {
      y0_false <- y
      seed00_false <- seed
    }
    str(list(y = y))
    stopifnot(identical(seed, seed0), identical(seed, seed00_false))
    ## NOTE: We cannot guarantee the same random numbers, because
    ## future.seed = FALSE.

    ## --- seed_sets ---
    for (name in names(seed_sets)) {
      future.seed <- seed_sets[[name]]
      label <- labels[[name]]

      y0 <- y0_list[[name]]
      seed00 <- seed00_list[[name]]

      set.seed(0xBEEF)
      seed0 <- get_random_seed()
      y <- lapply(x, FUN = function(i) {
        rnorm(1L)
      }) |> futurize_and_verify(seed = future.seed)
      y <- unlist(y)
      seed <- get_random_seed()
      if (is.null(y0)) {
        y0 <- y
        seed00 <- seed
        y0_list[[name]] <- y0
        seed00_list[[name]] <- seed00
      }
      str(list(y = y))
      stopifnot(!identical(seed, seed0), identical(seed, seed00),
                identical(y, y0))

      ## RNG-based results should also be identical regardless of
      ## load-balance scheduling.
      for (scheduling in list(FALSE, TRUE, 0, 0.5, 2.0, Inf)) {
        set.seed(0xBEEF)
        seed0 <- get_random_seed()
        y <- lapply(x, FUN = function(i) {
          rnorm(1L)
        }) |> futurize_and_verify(seed = future.seed, scheduling = scheduling)
        seed <- get_random_seed()
        y <- unlist(y)
        str(list(y = y))
        stopifnot(!identical(seed, seed0), identical(seed, seed00),
                  identical(y, y0))
      }
    } ## for (name ...)

    ## Nested future_lapply():s
    for (scheduling in list(FALSE, TRUE)) {
      y <- lapply(x, FUN = function(i) {
        .seed <- globalenv()$.Random.seed

        z <- lapply(1:3, FUN = function(j) {
          list(j = j, seed = globalenv()$.Random.seed)
        }) |> futurize_and_verify(seed = .seed)

        ## Assert that all future seeds are unique
        seeds <- lapply(z, FUN = function(x) x$seed)
        for (kk in 2:length(seeds)) stopifnot(!all(seeds[[kk]] == seeds[[1]]))

        list(i = i, seed = .seed, sample = rnorm(1L), z = z)
      }) |> futurize_and_verify(seed = 42L, scheduling = scheduling)

      if (is.null(y0_nested)) y0_nested <- y
      str(list(y = y))

      ## Assert that all future seeds (also nested ones) are unique
      seeds <- Reduce(c, lapply(y, FUN = function(x) {
        c(list(seed = x$seed), lapply(x$z, FUN = function(x) x$seed))
      }))
      for (kk in 2:length(seeds)) stopifnot(!all(seeds[[kk]] == seeds[[1]]))

      stopifnot(identical(y, y0_nested))
    }

    message(sprintf("* plan('%s') ... DONE", strategy))
  }  ## for (strategy ...)
  message(sprintf("  - Testing with %d cores ... DONE", cores))
} ## for (cores ...)

message("* lapply(x, ..., future.seed = FALSE) |> futurize() ... DONE")
for (name in names(seed_sets)) {
  message(sprintf("* lapply(x, ..., future.seed = %s) |> futurize() ... DONE", labels[[name]]))
}


message("*** future_lapply() and RNGs ... DONE")



} ## if (requireNamespace("future.apply", quietly = TRUE))
