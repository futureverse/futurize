if (requireNamespace("future.apply")) {
library(futurize)
library(stats)
library(datasets)
options(future.rng.onMisuse = "error")

plan(multisession)

y <- lapply(X = 1:3, FUN = function(x) { print(x) }) |> futurize(stdout = FALSE)
print(y)


xs <- list(aa = 1, bb = 1:2, cc = 1:10, dd = 1:5, .ee = -6:6)

X <- EuStockMarkets[,1:2]
k <- kernel("daniell", m = 50L)
stopifnot(inherits(X, "matrix"), inherits(X, "ts"), inherits(k, "tskernel"))

FUN_no_rng <- function(x, na.rm = TRUE) {
  a <- 1:5
  add <- NULL
  if (length(x) == 2) add <- list(C = 42)
  median(c(a, x), na.rm = na.rm)
}

FUN_rng <- function(x, na.rm = TRUE) {
  dummy <- sample.int(10L)
  a <- 1:5
  add <- NULL
  if (length(x) == 2) add <- list(C = 42)
  median(c(a, x), na.rm = na.rm)
}

es <- as.environment(xs)


exprs <- list(
     lapply = quote( lapply(X = xs, FUN = FUN) ),
     lapply = quote( base::lapply(X = xs, FUN = FUN) ),
     sapply = quote( sapply(X = xs, FUN = FUN) ),
     sapply = quote( base::sapply(X = xs, FUN = FUN) ),
     sapply = quote( base::sapply(X = xs, FUN = FUN, simplify = FALSE) ),
     sapply = quote( base::sapply(X = xs, FUN = FUN, USE.NAMES = FALSE) ),
     vapply = quote( base::vapply(X = xs, FUN.VALUE = NA_real_, FUN = FUN) ),
     vapply = quote( base::vapply(X = xs, FUN.VALUE = NA_real_, FUN = FUN, USE.NAMES = FALSE) ),
     eapply = quote( base::eapply(env = es, FUN = FUN) ),
     eapply = quote( base::eapply(env = es, FUN = FUN, all.names = TRUE) ),
     eapply = quote( base::eapply(env = es, FUN = FUN, USE.NAMES = FALSE) ),
  replicate = quote( replicate(2, 42) ),
  replicate = quote( base::replicate(2, 42) ),
  kernapply = quote( kernapply(x = X, k = k) )
)

flavors <- c("add-on", "built-in")

for (flavor in flavors) {
  for (kk in seq_along(exprs)) {
    name <- names(exprs)[kk]
    expr <- exprs[[kk]]
    message()
    message(sprintf("=== %s ==========================", name))
    print(expr)
    message(sprintf("---------------------------------"))
    
    if (flavor == "built-in") {
      if (name %in% c("replicate", "kernapply")) {
        message(sprintf("Skipping %s() - not yet implemented for flavor = %s", name, sQuote(flavor)))
        next
      }
    }
  
    FUN <- FUN_no_rng
    truth <- eval(expr)
    named_truth <- !is.null(names(truth))
  
    ## SPECIAL CASE: eapply() does not guarantee the order. To compare results
    ## later, we sort the results by name if they exist, otherwise by value.
    ## From ?eapply: "Note that the order of the components is arbitrary
    ## for hashed environments."
    if (name == "eapply" && !named_truth) {
      truth <- truth[order(unlist(truth))]
    }
    
    FUN <- FUN_no_rng
    
    expr_f <- bquote(.(expr) |> futurize(flavor = .(flavor)))
    res <- eval(expr_f)
  
    if (name == "eapply") {
      res <- res[if (named_truth) names(truth) else order(unlist(res))]
    }
    stopifnot(identical(res, truth))
  
    out <- utils::capture.output({
      expr_f2 <- bquote(.(expr) |> futurize(stdout = FALSE, conditions = character(0L), flavor = .(flavor)))
      res2 <- eval(expr_f2)
    })
    print(out)
  
    if (name == "eapply") {
      res2 <- res2[if (named_truth) names(truth) else order(unlist(res2))]
    }
    stopifnot(
      identical(res2, truth),
      identical(res2, res),
      identical(out, character(0L))
    )
    
    expr_f3 <- bquote(.(expr) |> futurize(chunk.size = 1L, flavor = .(flavor)))
    res3 <- eval(expr_f3)
    if (name == "eapply") {
      res3 <- res3[if (named_truth) names(truth) else order(unlist(res3))]
    }
    stopifnot(
      identical(res3, truth),
      identical(res3, res)
    )
    
    message("Test with RNG:")
    FUN <- FUN_rng
    expr_f4 <- bquote(.(expr) |> futurize(seed = TRUE, flavor = .(flavor)))
    print(expr_f4)
    res4 <- local({
      opts <- options(future.rng.onMisuse = "error")
      on.exit(options(opts))
      eval(expr_f4)
    })
  
    if (name == "eapply") {
      res4 <- res4[if (named_truth) names(truth) else order(unlist(res4))]
    }
    stopifnot(
      identical(res4, truth),
      identical(res4, res)
    )
  } ## for (kk ...)
} ## for (flavor ...)

message("futurize() for replicate() should default to seed = TRUE")
y <- replicate(2, rnorm(1)) |> futurize()

## Switch to 'sequential' already here to avoid detritus files on Windows
plan(sequential)

message("futurize(seed = FALSE) gives RNG error with replicate()")
y <- tryCatch(replicate(2, rnorm(1)) |> futurize(seed = FALSE), error = identity)
stopifnot(inherits(y, "error"))

} ## if (requireNamespace("future.apply"))
