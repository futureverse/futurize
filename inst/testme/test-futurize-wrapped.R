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

} ## if (requireNamespace("future.apply"))
