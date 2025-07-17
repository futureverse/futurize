if (requireNamespace("crossmap")) {
library(futurize)
library(crossmap)
options(future.rng.onMisuse = "error")

plan(multisession)

xs <- list(1:5, 1:5)

exprs <- list(
  xmap_dbl = quote( xmap_dbl(xs, ~ .y * .x) ),
  xmap_chr = quote( xmap_chr(xs, ~ paste(.y, "*", .x, "=", .y * .x)) )
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
  
  if (!identical(res, truth)) {
    str(list(truth = truth, res = res))
    stop("Not identical")
  } else {
    str(res)
  }
}

plan(sequential)
} ## if (requireNamespace("crossmap"))
