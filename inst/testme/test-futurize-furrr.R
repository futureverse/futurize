if (requireNamespace("purrr") && requireNamespace("furrr")) {
library(futurize)
library(purrr)
options(future.rng.onMisuse = "error")

plan(multisession)

y <- map(1:3, function(x) { print(x) }) |> futurize(stdout = FALSE)
print(y)


xs <- list(aa = 1, bb = 1:2, cc = 1:10, dd = 1:5, .ee = -6:6)
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
      map = quote(map(xs, FUN) ),
  map_dbl = quote(map_dbl(xs, FUN) )
)

for (kk in seq_along(exprs)) {
  name <- names(exprs)[kk]
  expr <- exprs[[kk]]
  message()
  message(sprintf("=== %s ==========================", name))
  print(expr)
  message(sprintf("---------------------------------"))

  FUN <- FUN_no_rng
  truth <- eval(expr)
  expr_f <- bquote(.(expr) |> futurize())
  res <- eval(expr_f)

  ## From ?eapply: "Note that the order of the components is arbitrary
  ## for hashed environments."
  if (name == "eapply" && !is.null(names(truth))) res <- res[names(truth)]

  validate <- TRUE
  if (name == "eapply") {
    if (is.null(names(truth))) {
      validate <- FALSE
    } else {
      res <- res[names(truth)]
    }
  }
  
  if (validate && !identical(res, truth)) {
    str(list(truth = truth, res = res))
    stop("Not identical")
  } else {
    str(res)
  }

  out <- utils::capture.output({
    expr_f2 <- bquote(.(expr) |> futurize(stdout = FALSE, conditions = character(0L)))
    res2 <- eval(expr_f2)
  })
  print(out)
  stopifnot(
    identical(out, character(0L)),
    identical(res2, res),
    identical(res2, truth)
  )

  expr_f3 <- bquote(.(expr) |> futurize(chunk.size = 1L))
  res3 <- eval(expr_f3)
  stopifnot(
    identical(res3, res),
    identical(res3, truth)
  )

  message("Test with RNG:")
  FUN <- FUN_rng
  expr_f4 <- bquote(.(expr) |> futurize(seed = TRUE))
  print(expr_f4)
  res4 <- local({
    opts <- options(future.rng.onMisuse = "error")
    on.exit(options(opts))
    eval(expr_f4)
  })
  stopifnot(
    identical(res4, res),
    identical(res4, truth)
  )
}

plan(sequential)
} ## if (requireNamespace("purrr") && requireNamespace("furrr"))
