# Version 0.0.2 (2025-05-19)

 * The **futurize** package unifies our current **future.apply**,
   **furrr**, and **doFuture** solutions into a minimal, unified
   API. This means you no longer need to learn those future-specific
   packages and their APIs, and all you need to know is the `... |>
   futurize()` syntax.  The default behavior of `futurize()` is
   sufficient for most use cases and users, but, if needed, it comes
   with one unifying, unique set of arguments that can be used to
   configure how the futures are resolved, how they are partitioned
   into chunks, and how output and conditions are relayed, among other
   things.

 * Add support for base R, e.g. `y <- lapply(xs, fcn) |> futurize()`.

 * Add support for **purrr**, e.g. `y <- map(xs, fcn) |> futurize()`.
 
 * Add support for **foreach**, e.g. `y <- foreach(x = xs) %do% {
   fcn(x) } |> futurize()`.
 
 * Add support for **plyr**, e.g. `y <- llply(xs, fcn) |>
   futurize()`.
 
 * Add support for **BiocParallel**, e.g. `y <- bplapply(xs, fcn) |>
   futurize()`.

 * Add support for **glmnet**, e.g. `cv <- cv.glmnet(x, y) |>
   futurize()`.

 * Argument `flavor = "add-on"` is the default for `futurize()`, which
   transpiles the apply-like calls into corresponding
   **future.apply**, **furrr**, and **doFuture** calls. This is the
   current default, because those packages are very well tested, which
   in turns means that using the `... |> futurize()` syntax is
   effectively just syntactic sugar that guarantes identical behavior
   to directly using the API of those packages. In contrast, the
   `flavor = "built-in"` method do not rely on these
   packages. Instead, they rely on a new powerful, generic mechanism
   for partitioning a set of futures into chunks, where the futures in
   each chunk are merged into a single future, which then are resolved
   in parallel. This new approach makes it easier to stay true to, and
   agile with original packages. For instance, the built-in transpiler
   for **purrr** relies on **purrr** to generate the original set of
   futures, and the only thing we have to implement is how to reduce
   the results back to what **purrr** would return. When the built-in
   implementation have proven to work well, we will consider making
   them the new default, and we can start thinking about deprecated
   **future.apply** and **furrr**.
   
 
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
