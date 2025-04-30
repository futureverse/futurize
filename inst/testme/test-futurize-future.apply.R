library(futurize)

plan(multisession)

y <- lapply(X = 1:3, FUN = function(x) { print(x) }) |> futurize(stdout = FALSE)
print(y)


xs <- list(aa = 1, bb = 1:2, cc = 1:10, dd = 1:5, .ee = -6:6)
FUN <- function(x, na.rm = TRUE) {
  a <- 1:5
  add <- NULL
  if (length(x) == 2) add <- list(C = 42)
  median(c(a, x), na.rm = na.rm)
}

es <- as.environment(xs)


exprs <- list(
  lapply = quote(lapply(X = xs, FUN = FUN) ),
  lapply = quote(base::lapply(X = xs, FUN = FUN) ),
  sapply = quote(sapply(X = xs, FUN = FUN) ),
  sapply = quote(base::sapply(X = xs, FUN = FUN) ),
  sapply = quote(base::sapply(X = xs, FUN = FUN, simplify = FALSE) ),
  sapply = quote(base::sapply(X = xs, FUN = FUN, USE.NAMES = FALSE) ),
  vapply = quote(base::vapply(X = xs, FUN.VALUE = NA_real_, FUN = FUN) ),
  vapply = quote(base::vapply(X = xs, FUN.VALUE = NA_real_, FUN = FUN, USE.NAMES = FALSE) ),
  eapply = quote(base::eapply(env = es, FUN = FUN) ),
  eapply = quote(base::eapply(env = es, FUN = FUN, all.names = TRUE) ),
  eapply = quote(base::eapply(env = es, FUN = FUN, USE.NAMES = FALSE) )
)

for (kk in seq_along(exprs)) {
  name <- names(exprs)[kk]
  expr <- exprs[[kk]]
  message()
  message(sprintf("=== %s ==========================", name))
  print(expr)
  message(sprintf("---------------------------------"))
  
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

  expr_f2 <- bquote(.(expr) |> futurize(stdout = FALSE, conditions = character(0L)))
  res2 <- eval(expr_f2)
  stopifnot(identical(res2, res))


  expr_f3 <- bquote(.(expr) |> futurize(chunk.size = 1L))
  res3 <- eval(expr_f3)
  stopifnot(identical(res3, res))
}


plan(sequential)
