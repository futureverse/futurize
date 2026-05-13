#' @tags pkg-future.apply
if (requireNamespace("future.apply")) {
library(futurize)

plan(multisession)

truth <- future.apply::future_lapply(1, identity)

## Wrapped in { ... }
y <- { lapply(1, identity) } |> futurize_and_verify()
stopifnot(identical(y, truth))

## Wrapped in ( ... )
y <- ( lapply(1, identity) ) |> futurize_and_verify()
stopifnot(identical(y, truth))

## Wrapped in local( ... )
y <- local( lapply(1, identity) ) |> futurize_and_verify()
stopifnot(identical(y, truth))

## Wrapped in identity( ... )
y <- identity( lapply(1, identity) ) |> futurize_and_verify()
stopifnot(identical(y, truth))

## Wrapped in I( ... )
y <- I( lapply(1, identity) ) |> futurize_and_verify()
stopifnot(identical(y, I(truth)))

## Wrapped in { { ... } }
y <- { { lapply(1, identity) } } |> futurize_and_verify()
stopifnot(identical(y, truth))

## Wrapped in { ( ... ) }
y <- { ( lapply(1, identity) ) } |> futurize_and_verify()
stopifnot(identical(y, truth))

## Wrapped in ( ( ... ) )
y <- ( ( lapply(1, identity) ) ) |> futurize_and_verify()
stopifnot(identical(y, truth))

## Wrapped in local({ ... })
y <- local({ lapply(1, identity) }) |> futurize_and_verify()
stopifnot(identical(y, truth))

## Wrapped in { local({ ... }) }
y <- { local({ lapply(1, identity) }) } |> futurize_and_verify()
stopifnot(identical(y, truth))

truth2 <- list(-1, 2, -3)

## Wrapped in { x <- truth2; local({ ... }) }
y <- { x <- truth2; lapply(x, identity) } |> futurize_and_verify()
stopifnot(identical(y, truth2))

## Wrapped in { { { x <- truth2; local({ ... }) } } }
y <- { { { x <- truth2; lapply(x, identity) } } } |> futurize_and_verify()
stopifnot(identical(y, truth2))

## Wrapped in { ( { x <- truth2; local({ ... }) ) } }
y <- { ( { x <- truth2; lapply(x, identity) } ) } |> futurize_and_verify()
stopifnot(identical(y, truth2))

## Wrapped in { local({ x <- truth2; local({ ... }) }) }
y <- { local({ x <- truth2; lapply(x, identity) }) } |> futurize_and_verify()
stopifnot(identical(y, truth2))

## Wrapped in { local({ 42; x <- truth2; local({ ... }) } })
y <- { local({ 42; x <- truth2; lapply(x, identity) }) } |> futurize_and_verify()
stopifnot(identical(y, truth2))

## Wrapped in { 3.14; local({ 42; x <- truth2; local({ ... }) } })
y <- { 3.14; local({ 42; x <- truth2; lapply(x, identity) }) } |> futurize_and_verify()
stopifnot(identical(y, truth2))

## Wrapped in { 3.14; local({ 42; x <- truth2; local({ ... }) } })
y <- { 3.14; local({ 42; x <- truth2; lapply(x, identity) }) } |> futurize_and_verify()
stopifnot(identical(y, truth2))

truth3 <- !sapply(truth2, \(x) { x > 0 })
y <- !sapply(truth2, \(x) { x > 0 }) |> futurize_and_verify()
stopifnot(identical(y, truth3))

y <- { !sapply(truth2, \(x) { x > 0 }) } |> futurize_and_verify()
stopifnot(identical(y, truth3))

y <- { 42; !sapply(truth2, \(x) { x > 0 }) } |> futurize_and_verify()
stopifnot(identical(y, truth3))

## Wrapped in with(data, ...)
data <- data.frame(a = 1:3)
truth_with <- future.apply::future_lapply(data$a, identity)
y <- with(data, lapply(a, identity)) |> futurize_and_verify()
stopifnot(identical(y, truth_with))

## Wrapped in { with(data, ...) }
y <- { with(data, lapply(a, identity)) } |> futurize_and_verify()
stopifnot(identical(y, truth_with))

## Wrapped in with(data, { ... })
y <- with(data, { lapply(a, identity) }) |> futurize_and_verify()
stopifnot(identical(y, truth_with))

## Wrapped in local(..., envir = ...) - not the last element
e <- new.env()
truth4 <- local(lapply(1:3, identity), envir = e)
y <- local({ lapply(1:3, identity) }, envir = e) |> futurize_and_verify()
stopifnot(identical(y, truth4))

e <- new.env()
truth5 <- local({ lapply(1:3, identity) }, envir = e)
y <- local({ lapply(1:3, identity) }, envir = e) |> futurize_and_verify()
stopifnot(identical(y, truth5))

## Wrapped in suppressWarnings(..., classes = ...) - not the last element
truth6 <- suppressWarnings({ lapply(1:3, identity) }, classes = "warning")
y <- suppressWarnings({ lapply(1:3, identity) }, classes = "warning") |> futurize_and_verify()
stopifnot(identical(y, truth6))

plan(sequential)
} ## if (requireNamespace("future.apply"))
