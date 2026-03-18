if (requireNamespace("future.apply")) {
library(futurize)

plan(multisession)

truth <- future.apply::future_lapply(1, identity)

## Wrapped in { ... }
counters <- plan("backend")[["counters"]]
y <- { lapply(1, identity) } |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth))

## Wrapped in ( ... )
counters <- plan("backend")[["counters"]]
y <- ( lapply(1, identity) ) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth))

## Wrapped in local( ... )
counters <- plan("backend")[["counters"]]
y <- local( lapply(1, identity) ) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth))

## Wrapped in identity( ... )
counters <- plan("backend")[["counters"]]
y <- identity( lapply(1, identity) ) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth))

## Wrapped in I( ... )
counters <- plan("backend")[["counters"]]
y <- I( lapply(1, identity) ) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, I(truth)))

## Wrapped in { { ... } }
counters <- plan("backend")[["counters"]]
y <- { { lapply(1, identity) } } |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth))

## Wrapped in { ( ... ) }
counters <- plan("backend")[["counters"]]
y <- { ( lapply(1, identity) ) } |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth))

## Wrapped in ( ( ... ) )
counters <- plan("backend")[["counters"]]
y <- ( ( lapply(1, identity) ) ) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth))

## Wrapped in local({ ... })
counters <- plan("backend")[["counters"]]
y <- local({ lapply(1, identity) }) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth))

## Wrapped in { local({ ... }) }
counters <- plan("backend")[["counters"]]
y <- { local({ lapply(1, identity) }) } |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth))

truth2 <- list(-1, 2, -3)

## Wrapped in { x <- truth2; local({ ... }) }
counters <- plan("backend")[["counters"]]
y <- { x <- truth2; lapply(x, identity) } |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth2))

## Wrapped in { { { x <- truth2; local({ ... }) } } }
counters <- plan("backend")[["counters"]]
y <- { { { x <- truth2; lapply(x, identity) } } } |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth2))

## Wrapped in { ( { x <- truth2; local({ ... }) ) } }
counters <- plan("backend")[["counters"]]
y <- { ( { x <- truth2; lapply(x, identity) } ) } |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth2))

## Wrapped in { local({ x <- truth2; local({ ... }) }) }
counters <- plan("backend")[["counters"]]
y <- { local({ x <- truth2; lapply(x, identity) }) } |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth2))

## Wrapped in { local({ 42; x <- truth2; local({ ... }) } })
counters <- plan("backend")[["counters"]]
y <- { local({ 42; x <- truth2; lapply(x, identity) }) } |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth2))

## Wrapped in { 3.14; local({ 42; x <- truth2; local({ ... }) } })
counters <- plan("backend")[["counters"]]
y <- { 3.14; local({ 42; x <- truth2; lapply(x, identity) }) } |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth2))

## Wrapped in { 3.14; local({ 42; x <- truth2; local({ ... }) } })
counters <- plan("backend")[["counters"]]
y <- { 3.14; local({ 42; x <- truth2; lapply(x, identity) }) } |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth2))

truth3 <- !sapply(truth2, \(x) { x > 0 })
counters <- plan("backend")[["counters"]]
y <- !sapply(truth2, \(x) { x > 0 }) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth3))

counters <- plan("backend")[["counters"]]
y <- { !sapply(truth2, \(x) { x > 0 }) } |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth3))

counters <- plan("backend")[["counters"]]
y <- { 42; !sapply(truth2, \(x) { x > 0 }) } |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth3))


## Wrapped in local(..., envir = ...) - not the last element
e <- new.env()
truth4 <- local(lapply(1:3, identity), envir = e)
counters <- plan("backend")[["counters"]]
y <- local({ lapply(1:3, identity) }, envir = e) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth4))

e <- new.env()
truth5 <- local({ lapply(1:3, identity) }, envir = e)
counters <- plan("backend")[["counters"]]
y <- local({ lapply(1:3, identity) }, envir = e) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth5))


## Wrapped in suppressWarnings(..., classes = ...) - not the last element
truth6 <- suppressWarnings({ lapply(1:3, identity) }, classes = "warning")
counters <- plan("backend")[["counters"]]
y <- suppressWarnings({ lapply(1:3, identity) }, classes = "warning") |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(identical(y, truth6))


plan(sequential)
} ## if (requireNamespace("future.apply"))
