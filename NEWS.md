# Version 0.0.2 (2025-04-29)

 * Implement `futurize(flavor = "addon")`, which transpiles common
   map-reduce calls of base R and the **purrr** package, into
   **future.apply** and **furrr** counterparts.  If you already use
   **future.apply** or **furrr**, you can now replace your
   `future_*()` calls with the futurized alternatives. For example,
   instead of `y <- future_lapply(xs, fcn)` you can use `y <-
   lapply(xs, fcn) | futurize()`, and instead of `future_map(xs, fcn)`
   you can use `y <- map(xs, fcn) |> futurize()`.
   
 * Initially, `flavor = "addon"` will be the default, because
   **future.apply** and **furrr** are well tested. In a future version
   (pun intended), when the built-in transpilers have been equally
   well tested, the default will switch to `flavor = "built-in"`.
   
 
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
