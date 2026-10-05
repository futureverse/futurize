## Arguments that futurize() appends to the call must not already be
## specified by the user, which should give an informative error
library(futurize)

exprs <- list()

if (requireNamespace("future.apply", quietly = TRUE)) {
  exprs$lapply <- list(
    expr = quote(lapply(1:2, identity, future.seed = TRUE)),
    arg  = "future.seed"
  )
}

if (requireNamespace("purrr", quietly = TRUE) && requireNamespace("furrr", quietly = TRUE)) {
  exprs$map <- list(
    expr = quote(purrr::map(1:2, identity, .options = NULL)),
    arg  = ".options"
  )
}

if (requireNamespace("pbapply", quietly = TRUE)) {
  exprs$pblapply <- list(
    expr = quote(pbapply::pblapply(1:2, identity, cl = NULL)),
    arg  = "cl"
  )
}

if (requireNamespace("BiocParallel", quietly = TRUE) && requireNamespace("doFuture", quietly = TRUE)) {
  exprs$bplapply <- list(
    expr = quote(BiocParallel::bplapply(1:2, identity, BPPARAM = BiocParallel::SerialParam())),
    arg  = "BPPARAM"
  )
}

if (getRversion() >= "4.4.0" && requireNamespace("boot", quietly = TRUE)) {
  exprs$boot <- list(
    expr = quote(boot::boot(1:10, function(d, i) mean(d[i]), R = 10L, parallel = "multicore")),
    arg  = "parallel"
  )
}

for (name in names(exprs)) {
  message(sprintf("*** %s()", name))
  expr <- exprs[[name]]$expr
  arg <- exprs[[name]]$arg
  print(expr)
  res <- tryCatch({
    futurize(expr, substitute = FALSE, eval = FALSE)
  }, error = identity)
  print(res)
  stopifnot(
    inherits(res, "error"),
    grepl("is controlled by futurize()", conditionMessage(res), fixed = TRUE),
    grepl(arg, conditionMessage(res), fixed = TRUE)
  )
}
