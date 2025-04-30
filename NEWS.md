# Version 0.0.2 (2025-04-30)

 * Implement `futurize()`, which transpiles common apply-like,
   map-reduce calls, of base R, **purrr** and **foreach**, into a
   "futurized" version that automatically parallelizes the call via
   future and the Futureverse ecosystem. For example, a base R call `y
   <- lapply(xs, fcn) |> futurize()` transpiles the call to `y <-
   future.apply::future_lapply(xs, fcn))`. Similarly, `y <-
   purrr::map(xs, fcn) |> futurize()` becomes `furrr::future_map(xs,
   fcn)`, and `y <- foreach::foreach(x = xs) %do% { fcn(x) }` becomes
   `y <- foreach::foreach(x = xs) %dofuture% { fcn(x) }` (of the
   **doFuture**).

 * The `futurize()` unifies our current **future.apply**, **furrr**,
   and **doFuture** solutions into a minimal, unified API. This means
   you no longer need to learn those future-specific packages and
   their APIs, and all you need to know is the `... |> futurize()`
   syntax.  The default behavior of `futurize()` is sufficient for
   most use cases and users, but if needed, it comes with one
   unifying, unique set of arguments that can be used to configure how
   the futures are resolved, how they are partitioned into chunks, and
   how output and conditions are relayed, among other things.
   
 * Argument `flavor = "add-on"` is the default for `futurize()`,
   mainly because **future.apply**, **furrr**, and **doFuture** are
   very well tested. In a future version (pun intended), when the
   built-in transpilers have been equally well tested, and they can
   superseed these packages, then the default will switch to `flavor =
   "built-in"`.

 
# Version 0.0.1 (2025-03-07)

## New Features

 * Implemented a working proof-of-concept of a `futurize()` function
   that takes a call expression to any base-R apply function and
   transpiles it such that it runs in parallel via futures. This works
   by the original map-reduce call is transpiled to evaluate each
   iteration via a lazy, vanilla future. These futures are then
   partitioned into chunks, where the number of chunks defaults to the
   number of parallel workers. The futures in each chunk are merged
   into a single future. These futures are then launched in parallel
   on the current future backend. When resolved, the results are
   reduced back to the structure that the original base R apply
   function would return.
