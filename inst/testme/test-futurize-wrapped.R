if (requireNamespace("future.apply")) {
library(futurize)

truth <- future.apply::future_lapply(1, identity)

## Wrapped in { ... }
y <- { lapply(1, identity) } |> futurize()
stopifnot(identical(y, truth))

## Wrapped in ( ... )
y <- ( lapply(1, identity) ) |> futurize()
stopifnot(identical(y, truth))

## Wrapped in local( ... )
y <- local( lapply(1, identity) ) |> futurize()
stopifnot(identical(y, truth))

## Wrapped in identity( ... )
y <- identity( lapply(1, identity) ) |> futurize()
stopifnot(identical(y, truth))

## Wrapped in I( ... )
y <- I( lapply(1, identity) ) |> futurize()
stopifnot(identical(y, I(truth)))

## Wrapped in { { ... } }
y <- { { lapply(1, identity) } } |> futurize()
stopifnot(identical(y, truth))

## Wrapped in { ( ... ) }
y <- { ( lapply(1, identity) ) } |> futurize()
stopifnot(identical(y, truth))

## Wrapped in ( ( ... ) )
y <- ( ( lapply(1, identity) ) ) |> futurize()
stopifnot(identical(y, truth))

## Wrapped in local({ ... })
y <- local({ lapply(1, identity) }) |> futurize()
stopifnot(identical(y, truth))

## Wrapped in { local({ ... }) }
y <- { local({ lapply(1, identity) }) } |> futurize()
stopifnot(identical(y, truth))

truth2 <- list(-1, 2, -3)

## Wrapped in { x <- truth2; local({ ... }) }
y <- { x <- truth2; lapply(x, identity) } |> futurize()
stopifnot(identical(y, truth2))

## Wrapped in { { { x <- truth2; local({ ... }) } } }
y <- { { { x <- truth2; lapply(x, identity) } } } |> futurize()
stopifnot(identical(y, truth2))

## Wrapped in { ( { x <- truth2; local({ ... }) ) } }
y <- { ( { x <- truth2; lapply(x, identity) } ) } |> futurize()
stopifnot(identical(y, truth2))

## Wrapped in { local({ x <- truth2; local({ ... }) }) }
y <- { local({ x <- truth2; lapply(x, identity) }) } |> futurize()
stopifnot(identical(y, truth2))

## Wrapped in { local({ 42; x <- truth2; local({ ... }) } })
y <- { local({ 42; x <- truth2; lapply(x, identity) }) } |> futurize()
stopifnot(identical(y, truth2))

## Wrapped in { 3.14; local({ 42; x <- truth2; local({ ... }) } })
y <- { 3.14; local({ 42; x <- truth2; lapply(x, identity) }) } |> futurize()
stopifnot(identical(y, truth2))

## Wrapped in { 3.14; local({ 42; x <- truth2; local({ ... }) } })
y <- { 3.14; local({ 42; x <- truth2; lapply(x, identity) }) } |> futurize()
stopifnot(identical(y, truth2))


truth3 <- !sapply(truth2, \(x) { x > 0 })
y <- !sapply(truth2, \(x) { x > 0 }) |> futurize()
stopifnot(identical(y, truth3))

y <- { !sapply(truth2, \(x) { x > 0 }) } |> futurize()
stopifnot(identical(y, truth3))

y <- { 42; !sapply(truth2, \(x) { x > 0 }) } |> futurize()
stopifnot(identical(y, truth3))


} ## if (requireNamespace("future.apply"))
